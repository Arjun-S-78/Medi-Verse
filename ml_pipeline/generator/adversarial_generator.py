"""
MIRA Adversarial Case Generator.
Generates challenging, non-standard, minimizer, and historical red-flag cases to test MIRA triage edge-case detection.
"""

import json
import os
import random
import datetime

ADVERSARIAL_TEMPLATES = [
    {
        "patient_msg": "I feel fine now but I was unconscious earlier on the bathroom floor.",
        "category": "Unconsciousness",
        "expected_severity": "CRITICAL",
        "red_flag": "Recent Transient Loss of Consciousness",
        "reason": "Historical loss of consciousness requires mandatory emergency evaluation despite transient resolution."
    },
    {
        "patient_msg": "My chest hurt for a few minutes while walking but then it stopped.",
        "category": "Chest Pain",
        "expected_severity": "HIGH",
        "red_flag": "Transient Exertional Angina / Angina Pectoris",
        "reason": "Resolving chest pain can indicate acute coronary syndrome or unstable angina."
    },
    {
        "patient_msg": "I'm not sure if I'm having trouble breathing or if I'm just anxious.",
        "category": "Breathing Difficulty",
        "expected_severity": "MODERATE",
        "red_flag": "Ambiguous Respiratory Symptoms",
        "reason": "Requires active oxygen saturation and speech check to rule out silent hypoxia."
    },
    {
        "patient_msg": "I fell down 10 stairs but I don't think I was hurt badly, just a little dizzy.",
        "category": "Major Trauma",
        "expected_severity": "HIGH",
        "red_flag": "Traumatic Mechanism with Dizziness",
        "reason": "Dizziness after a fall indicates potential concussion, intracranial bleed, or spinal trauma."
    },
    {
        "patient_msg": "My mother suddenly can't speak properly and her smile looks crooked.",
        "category": "Neurological Symptoms",
        "expected_severity": "CRITICAL",
        "red_flag": "Acute FAST Stroke Signs (Speech & Facial Droop)",
        "reason": "Third-party reporter presenting acute stroke symptoms requiring immediate hyperacute stroke team dispatch."
    }
]

def generate_adversarial_dataset(count: int = 10) -> list[dict]:
    """Generates an adversarial dataset of edge cases."""
    records = []
    for i in range(count):
        tmpl = ADVERSARIAL_TEMPLATES[i % len(ADVERSARIAL_TEMPLATES)]
        case_id = f"ADV-{random.randint(10000000, 99999999)}"

        rec = {
            "case_id": case_id,
            "synthetic": True, # UNCONDITIONALLY TRUE
            "patient_demographics": {
                "age": random.choice([55, 68, 72, 45, 61]),
                "gender": random.choice(["Male", "Female"]),
                "blood_group": "O+"
            },
            "chief_complaint": tmpl["patient_msg"],
            "symptoms": [tmpl["category"]],
            "symptom_onset": "Earlier today",
            "symptom_duration": "Transient / Intermittent",
            "severity": tmpl["expected_severity"],
            "vital_signs": {
                "heart_rate": 96,
                "spo2": 95,
                "bp_systolic": 138,
                "bp_diastolic": 86,
                "temp_c": 37.0
            },
            "medical_history": ["Hypertension"],
            "medications": ["Amlodipine 5mg"],
            "emergency_red_flags": [tmpl["red_flag"]],
            "conversation": [
                {
                    "turn": 1,
                    "speaker": "mira",
                    "text": "Hello, I am MIRA. What brings you in today?"
                },
                {
                    "turn": 2,
                    "speaker": "patient",
                    "text": tmpl["patient_msg"]
                },
                {
                    "turn": 3,
                    "speaker": "mira",
                    "text": f"Thank you for sharing. Even if you feel better now, {tmpl['reason']}. Are you experiencing any dizziness or numbness?"
                }
            ],
            "structured_clinical_info": {
                "historicalRedFlagDetected": True,
                "transientResolution": True,
                "adversarialCase": True
            },
            "expected_triage_category": tmpl["expected_severity"],
            "expected_escalation_action": "Emergency Priority Evaluation (Do not dismiss based on symptom resolution)",
            "generation_metadata": {
                "generator_version": "1.0.0-adversarial",
                "category": tmpl["category"],
                "seed": 999,
                "created_at": datetime.datetime.utcnow().isoformat()
            }
        }
        records.append(rec)
    return records

if __name__ == "__main__":
    adv_data = generate_adversarial_dataset(count=10)
    out_file = "ml_pipeline/data/adversarial_dataset.json"
    os.makedirs(os.path.dirname(out_file), exist_ok=True)
    with open(out_file, "w") as f:
        json.dump(adv_data, f, indent=2)
    print(f"Generated {len(adv_data)} adversarial test scenarios in {out_file}")
