"""
MIRA Configurable Synthetic Medical Record Generator.
Generates medically plausible emergency scenarios for training and evaluating MIRA AI Triage.
"""

import argparse
import datetime
import json
import random
import sys
import os

# Add root directory to path to enable database imports
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..")))

from ml_pipeline.generator.medically_plausible_templates import (
    CASE_CATEGORIES,
    CONVERSATION_STYLES,
    MEDICAL_HISTORIES,
    MEDICATIONS_MAP,
    generate_vitals,
    generate_patient_utterance
)
from ml_pipeline.database.db_config import engine, SessionLocal
from ml_pipeline.database.models import Base, SyntheticRecord

class SyntheticDataGenerator:
    """Configurable synthetic emergency medical record generator."""

    def __init__(self, seed: int = None):
        if seed is not None:
            random.seed(seed)
        self.seed = seed

    def generate_single_record(self, category: str = None, severity: str = None, case_index: int = 1) -> dict:
        """Generates one comprehensive, validated synthetic medical record."""
        cat = category if category else random.choice(CASE_CATEGORIES)
        sev = severity if severity else random.choice(["LOW", "MODERATE", "HIGH", "CRITICAL"])
        style = random.choice(CONVERSATION_STYLES)

        # Case ID
        case_id = f"SYN-{random.randint(10000000, 99999999)}"

        # Demographics
        age = random.randint(18, 82)
        gender = random.choice(["Male", "Female", "Other"])
        blood_group = random.choice(["A+", "A-", "B+", "B-", "O+", "O-", "AB+", "Unknown"])

        # History & Vitals
        history = random.choice(MEDICAL_HISTORIES)
        meds = []
        for h in history:
            meds.extend(MEDICATIONS_MAP.get(h, []))
        vitals = generate_vitals(sev, cat)

        # Patient utterance & Red flags
        patient_msg, red_flags = generate_patient_utterance(cat, sev, style)

        # Onset & Duration
        onset = "30 minutes ago" if sev in ["CRITICAL", "HIGH"] else "2 days ago"
        duration = "Ongoing"

        # Turn-by-Turn Conversation Path
        conversation = [
            {
                "turn": 1,
                "speaker": "mira",
                "text": "Hello, I am MIRA, your AI nurse assistant. How can I help you today?"
            },
            {
                "turn": 2,
                "speaker": "patient",
                "text": patient_msg
            }
        ]

        # MIRA Follow-up turn
        if "Chest Pain" in cat or "chest" in patient_msg.lower():
            mira_reply = "I understand you have chest discomfort. Are you experiencing shortness of breath, sweating, or radiation to your left arm or jaw?"
            patient_reply = "Yes, I am sweating and my arm feels heavy." if sev in ["CRITICAL", "HIGH"] else "No, it just hurts slightly when I take a deep breath."
        elif "Breathing" in cat or "breath" in patient_msg.lower():
            mira_reply = "I see you are having trouble breathing. Can you speak in full sentences, and do you have asthma or heart disease?"
            patient_reply = "Hard to speak... gasping for air." if sev in ["CRITICAL", "HIGH"] else "Yes, I can speak okay, just feeling winded."
        else:
            mira_reply = "Thank you. On a scale of 0 to 10, how severe is your pain or discomfort right now?"
            patient_reply = f"I'd rate it an {8 if sev in ['CRITICAL', 'HIGH'] else 3} out of 10."

        conversation.extend([
            {"turn": 3, "speaker": "mira", "text": mira_reply},
            {"turn": 4, "speaker": "patient", "text": patient_reply}
        ])

        # Structured Clinical Target (Unknowns MUST be null, not false)
        structured_target = {
            "chestPain": True if "Chest Pain" in cat or "chest" in patient_msg.lower() else False,
            "breathingDifficulty": True if "Breathing" in cat or "breath" in patient_msg.lower() or "air" in patient_msg.lower() else False,
            "unconsciousness": True if "Unconsciousness" in cat or "passed out" in patient_msg.lower() else False,
            "painSeverity": "severe" if sev in ["CRITICAL", "HIGH"] else ("moderate" if sev == "MODERATE" else "mild"),
            "painScore": 9 if sev == "CRITICAL" else (7 if sev == "HIGH" else (4 if sev == "MODERATE" else 2)),
            "suddenOnset": True if sev in ["CRITICAL", "HIGH"] else False,
            "radiationLeftArm": True if ("arm" in patient_msg.lower() or "arm" in patient_reply.lower()) else (None if sev in ["CRITICAL", "HIGH"] else False)
        }

        # Expected Escalation Action
        if sev == "CRITICAL":
            escalation = "Dispatch Immediate ALS Emergency Ambulance & Alert Nearest Trauma Center"
        elif sev == "HIGH":
            escalation = "Dispatch BLS Emergency Ambulance & Reserve Urgent ER Bay"
        elif sev == "MODERATE":
            escalation = "Recommend Urgent Clinic Visit within 2 Hours"
        else:
            escalation = "Routine Tele-consultation & Home Monitoring Advice"

        return {
            "case_id": case_id,
            "synthetic": True, # UNCONDITIONALLY TRUE
            "patient_demographics": {
                "age": age,
                "gender": gender,
                "blood_group": blood_group
            },
            "chief_complaint": patient_msg,
            "symptoms": [cat] + (["Chest Pain"] if "chest" in patient_msg.lower() else []),
            "symptom_onset": onset,
            "symptom_duration": duration,
            "severity": sev,
            "vital_signs": vitals,
            "medical_history": history,
            "medications": meds,
            "emergency_red_flags": red_flags,
            "conversation": conversation,
            "structured_clinical_info": structured_target,
            "expected_triage_category": sev,
            "expected_escalation_action": escalation,
            "generation_metadata": {
                "generator_version": "1.0.0",
                "category": cat,
                "seed": self.seed,
                "created_at": datetime.datetime.utcnow().isoformat()
            }
        }

    def generate_dataset(self, count: int = 20) -> list[dict]:
        """Generates a list of synthetic records ensuring balanced category coverage."""
        records = []
        for i in range(count):
            cat = CASE_CATEGORIES[i % len(CASE_CATEGORIES)]
            sev = ["CRITICAL", "HIGH", "MODERATE", "LOW"][i % 4]
            rec = self.generate_single_record(category=cat, severity=sev, case_index=i+1)
            records.append(rec)
        return records

def save_to_database(records: list[dict]):
    """Persists synthetic records to PostgreSQL / SQLite database via SQLAlchemy."""
    Base.metadata.create_all(bind=engine)
    session = SessionLocal()
    try:
        stored_count = 0
        for rec in records:
            db_record = SyntheticRecord(
                case_id=rec["case_id"],
                synthetic=rec["synthetic"],
                category=rec["generation_metadata"]["category"],
                severity=rec["severity"],
                split_type=rec.get("split_type", "train"),
                chief_complaint=rec["chief_complaint"],
                payload=rec
            )
            session.add(db_record)
            stored_count += 1
        session.commit()
        print(f"[Database] Successfully saved {stored_count} synthetic records to database.")
    except Exception as e:
        session.rollback()
        print(f"[Database Error] Failed to save records: {e}")
    finally:
        session.close()

def main():
    parser = argparse.ArgumentParser(description="MIRA Synthetic Emergency Medical Record Generator")
    parser.add_argument("--count", type=int, default=20, help="Number of synthetic records to generate")
    parser.add_argument("--seed", type=int, default=42, help="Random seed for deterministic output")
    parser.add_argument("--output", type=str, default="ml_pipeline/data/benchmark_20_cases.json", help="Output file path")
    parser.add_argument("--db", action="store_true", help="Store generated records in database")
    args = parser.parse_args()

    # Ensure output directory exists
    os.makedirs(os.path.dirname(args.output), exist_ok=True)

    generator = SyntheticDataGenerator(seed=args.seed)
    dataset = generator.generate_dataset(count=args.count)

    # Save to JSON file
    with open(args.output, "w") as f:
        json.dump(dataset, f, indent=2)

    print(f"Generated {len(dataset)} synthetic medical records in {args.output}")

    if args.db:
        save_to_database(dataset)

if __name__ == "__main__":
    main()
