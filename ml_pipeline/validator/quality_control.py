"""
MIRA Quality Control and Validation Engine.
Validates synthetic medical record structure, clinical plausibility, zero PII compliance, and synthetic=true assertion.
"""

import json
import re
import sys
import os

REQUIRED_TOP_LEVEL_KEYS = [
    "case_id",
    "synthetic",
    "patient_demographics",
    "chief_complaint",
    "symptoms",
    "symptom_onset",
    "symptom_duration",
    "severity",
    "vital_signs",
    "medical_history",
    "medications",
    "emergency_red_flags",
    "conversation",
    "structured_clinical_info",
    "expected_triage_category",
    "expected_escalation_action",
    "generation_metadata"
]

ALLOWED_SEVERITIES = ["LOW", "MODERATE", "HIGH", "CRITICAL"]

# Regex patterns for detecting potential PII, API Keys, or Secrets
SECRET_PATTERNS = [
    re.compile(r"AIzaSy[A-Za-z0-9_-]{33}"), # Google API key
    re.compile(r"sk-[A-Za-z0-9]{32,}"),      # OpenAI key pattern
    re.compile(r"\b\d{3}-\d{2}-\d{4}\b"),   # SSN pattern
]

class QualityControlValidator:
    """Validates synthetic medical scenarios for compliance, completeness, and clinical plausibility."""

    @staticmethod
    def validate_record(record: dict) -> tuple[bool, list[str]]:
        """Validates a single synthetic record. Returns (is_valid, list_of_errors)."""
        errors = []

        # 1. Check required top-level keys
        for key in REQUIRED_TOP_LEVEL_KEYS:
            if key not in record:
                errors.append(f"Missing required field: '{key}'")

        if errors:
            return False, errors

        # 2. Check synthetic == True UNCONDITIONALLY
        if record.get("synthetic") is not True:
            errors.append("Validation Failure: 'synthetic' flag MUST be True.")

        # 3. Check Severity and Triage Category validity
        if record.get("severity") not in ALLOWED_SEVERITIES:
            errors.append(f"Invalid severity: '{record.get('severity')}'")

        if record.get("expected_triage_category") not in ALLOWED_SEVERITIES:
            errors.append(f"Invalid expected_triage_category: '{record.get('expected_triage_category')}'")

        # 4. Clinical Plausibility Checks on Vital Signs
        vitals = record.get("vital_signs", {})
        if isinstance(vitals, dict):
            spo2 = vitals.get("spo2")
            if spo2 is not None and (spo2 < 50 or spo2 > 100):
                errors.append(f"Impossible SpO2 value: {spo2}%")

            hr = vitals.get("heart_rate")
            if hr is not None and (hr < 30 or hr > 240):
                errors.append(f"Impossible heart rate value: {hr} bpm")

            bps = vitals.get("bp_systolic")
            bpd = vitals.get("bp_diastolic")
            if bps is not None and bpd is not None:
                if bps <= bpd:
                    errors.append(f"Contradictory blood pressure: Systolic ({bps}) <= Diastolic ({bpd})")

            temp = vitals.get("temp_c")
            if temp is not None and (temp < 34.0 or temp > 43.0):
                errors.append(f"Impossible body temperature: {temp}°C")

        # 5. PII & Secret Scrubbing
        record_str = json.dumps(record)
        for pattern in SECRET_PATTERNS:
            if pattern.search(record_str):
                errors.append("Security Alert: Record contains potential PII or secret key pattern.")

        # 6. Conversation turn validity
        conv = record.get("conversation", [])
        if not isinstance(conv, list) or len(conv) < 2:
            errors.append("Invalid conversation path: Must contain at least 2 turns.")

        return (len(errors) == 0), errors

    @classmethod
    def validate_dataset(cls, dataset: list[dict]) -> tuple[int, int, list[str]]:
        """Validates an entire dataset. Returns (valid_count, invalid_count, error_summary)."""
        valid_count = 0
        invalid_count = 0
        all_errors = []

        for idx, rec in enumerate(dataset):
            is_valid, errs = cls.validate_record(rec)
            if is_valid:
                valid_count += 1
            else:
                invalid_count += 1
                all_errors.append(f"Record #{idx+1} ({rec.get('case_id', 'UNKNOWN')}): {', '.join(errs)}")

        return valid_count, invalid_count, all_errors

def main():
    if len(sys.argv) < 2:
        print("Usage: py ml_pipeline/validator/quality_control.py <file_path.json>")
        sys.exit(1)

    file_path = sys.argv[1]
    with open(file_path, "r") as f:
        data = json.load(f)

    dataset = data if isinstance(data, list) else [data]
    valid_c, invalid_c, errs = QualityControlValidator.validate_dataset(dataset)

    print(f"--- Quality Control Summary for {file_path} ---")
    print(f"Total Scenarios Checked: {len(dataset)}")
    print(f"Passed Validation: {valid_c}")
    print(f"Failed Validation: {invalid_c}")

    if errs:
        print("\nErrors Found:")
        for e in errs:
            print(f" - {e}")
        sys.exit(1)
    else:
        print("\nValidation PASSED 100%! All records strictly compliant.")

if __name__ == "__main__":
    main()
