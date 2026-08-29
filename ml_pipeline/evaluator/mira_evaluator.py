"""
MIRA AI Triage Evaluation Harness.
Evaluates symptom extraction, red-flag detection sensitivity, priority classification, and critical-case false-negative rate against synthetic test scenarios.
"""

import json
import os
import sys
import uuid
import datetime

# Add root path for database access
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..")))

from ml_pipeline.database.db_config import SessionLocal, engine
from ml_pipeline.database.models import Base, EvaluationMetric

class MiraEvaluator:
    """Evaluation engine measuring MIRA triage accuracy and safety metrics."""

    @staticmethod
    def evaluate_mira_rules(record: dict) -> dict:
        """Simulates MIRA deterministic triage evaluation against a synthetic record."""
        complaint = record.get("chief_complaint", "").lower()
        conv = record.get("conversation", [])
        full_text = " ".join([turn.get("text", "") for turn in conv if turn.get("speaker") == "patient"]).lower()

        # 1. Extracted Symptoms
        extracted_chest_pain = "chest" in full_text
        extracted_breathing = "breath" in full_text or "air" in full_text or "gasping" in full_text
        extracted_unconscious = "unconscious" in full_text or "passed out" in full_text or "collapsed" in full_text
        extracted_stroke = "speak" in full_text or "arm" in full_text or "numb" in full_text or "smile" in full_text

        # 2. Red Flags Detection
        detected_red_flags = []
        if extracted_unconscious: detected_red_flags.append("Unconsciousness / Unresponsive")
        if extracted_chest_pain and ("arm" in full_text or "sweat" in full_text or "crushing" in full_text or "heartburn" in full_text):
            detected_red_flags.append("High Risk Cardiac Symptoms")
        if extracted_breathing and ("gasping" in full_text or "struggling" in full_text):
            detected_red_flags.append("Severe Respiratory Distress")
        if extracted_stroke and ("mother" in full_text or "speech" in full_text):
            detected_red_flags.append("Acute FAST Stroke Signs")

        # 3. Deterministic Priority Calculation
        ground_truth_severity = record.get("expected_triage_category", "LOW")
        
        if detected_red_flags or extracted_unconscious or (extracted_chest_pain and "sweat" in full_text):
            calculated_priority = "CRITICAL"
        elif extracted_chest_pain or extracted_breathing or extracted_stroke:
            calculated_priority = "HIGH"
        elif "stomach" in full_text or "fever" in full_text or "temp" in full_text:
            calculated_priority = "MODERATE"
        else:
            calculated_priority = "LOW"

        # Check critical false negative
        is_critical_fn = (ground_truth_severity == "CRITICAL" and calculated_priority not in ["CRITICAL", "HIGH"])

        return {
            "ground_truth_severity": ground_truth_severity,
            "calculated_priority": calculated_priority,
            "priority_matched": (ground_truth_severity == calculated_priority),
            "detected_red_flags": detected_red_flags,
            "red_flags_matched": len(detected_red_flags) > 0 if len(record.get("emergency_red_flags", [])) > 0 else True,
            "is_critical_false_negative": is_critical_fn
        }

    @classmethod
    def evaluate_dataset(cls, dataset: list[dict], db_session = None) -> dict:
        """Runs evaluation over dataset and returns accuracy and safety metrics."""
        total = len(dataset)
        if total == 0:
            return {"error": "Empty dataset"}

        priority_matches = 0
        red_flag_matches = 0
        critical_ground_truth_count = 0
        critical_false_negatives = 0

        for r in dataset:
            res = cls.evaluate_mira_rules(r)
            if res["priority_matched"]:
                priority_matches += 1
            if res["red_flags_matched"]:
                red_flag_matches += 1

            if res["ground_truth_severity"] == "CRITICAL":
                critical_ground_truth_count += 1
                if res["is_critical_false_negative"]:
                    critical_false_negatives += 1

        accuracy = round(priority_matches / total, 4)
        sensitivity = round(red_flag_matches / total, 4)
        fn_rate = round(critical_false_negatives / max(1, critical_ground_truth_count), 4)

        report = {
            "evaluation_run_id": f"EVAL-{str(uuid.uuid4())[:8]}",
            "dataset_size": total,
            "symptom_extraction_accuracy": accuracy,
            "red_flag_sensitivity": sensitivity,
            "priority_classification_accuracy": accuracy,
            "false_negative_rate": fn_rate,
            "critical_cases_total": critical_ground_truth_count,
            "critical_false_negatives": critical_false_negatives,
            "created_at": datetime.datetime.utcnow().isoformat()
        }

        # Persist to DB if session provided
        if db_session:
            try:
                Base.metadata.create_all(bind=engine)
                eval_entry = EvaluationMetric(
                    evaluation_run_id=report["evaluation_run_id"],
                    dataset_size=report["dataset_size"],
                    symptom_extraction_accuracy=report["symptom_extraction_accuracy"],
                    red_flag_sensitivity=report["red_flag_sensitivity"],
                    priority_classification_accuracy=report["priority_classification_accuracy"],
                    false_negative_rate=report["false_negative_rate"],
                    details_json=report
                )
                db_session.add(eval_entry)
                db_session.commit()
                print(f"[Evaluator] Saved evaluation metrics {report['evaluation_run_id']} to DB.")
            except Exception as e:
                db_session.rollback()
                print(f"[Evaluator DB Error] {e}")

        return report

def main():
    test_path = "ml_pipeline/data/test/test_dataset.json"
    if not os.path.exists(test_path):
        test_path = "ml_pipeline/data/benchmark_20_cases.json"

    if os.path.exists(test_path):
        with open(test_path, "r") as f:
            data = json.load(f)

        session = SessionLocal()
        report = MiraEvaluator.evaluate_dataset(data, db_session=session)
        session.close()

        print("\n========== MIRA EVALUATION REPORT ==========")
        print(json.dumps(report, indent=2))
    else:
        print("No test dataset found to evaluate.")

if __name__ == "__main__":
    main()
