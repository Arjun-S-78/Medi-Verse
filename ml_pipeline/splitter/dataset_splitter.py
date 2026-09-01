"""
MIRA Synthetic Dataset Splitter and Deduplication Engine.
Splits dataset into train, val, and test splits with semantic hashing to prevent near-duplicate leakage.
"""

import csv
import hashlib
import json
import os
import random
import sys

def compute_semantic_hash(record: dict) -> str:
    """Computes a hash based on chief complaint and symptoms to prevent duplicate leakage."""
    complaint = record.get("chief_complaint", "").lower().strip()
    symptoms = ",".join(sorted([s.lower() for s in record.get("symptoms", [])]))
    normalized = f"{complaint}|{symptoms}"
    return hashlib.sha256(normalized.encode("utf-8")).hexdigest()

class DatasetSplitter:
    """Splits dataset into train, val, test splits with strict deduplication."""

    @staticmethod
    def split_and_export(records: list[dict], base_dir: str = "ml_pipeline/data", seed: int = 42):
        """Splits records into train (70%), val (15%), test (15%) and exports JSON/JSONL/CSV."""
        random.seed(seed)
        
        # Deduplicate based on semantic hash
        seen_hashes = set()
        unique_records = []

        for r in records:
            h = compute_semantic_hash(r)
            if h not in seen_hashes:
                seen_hashes.add(h)
                unique_records.append(r)

        # Shuffle unique records
        random.shuffle(unique_records)

        total = len(unique_records)
        train_end = int(total * 0.70)
        val_end = train_end + int(total * 0.15)

        train_records = unique_records[:train_end]
        val_records = unique_records[train_end:val_end]
        test_records = unique_records[val_end:]

        # Mark split_type in records
        for r in train_records: r["split_type"] = "train"
        for r in val_records: r["split_type"] = "val"
        for r in test_records: r["split_type"] = "test"

        splits = {
            "train": train_records,
            "val": val_records,
            "test": test_records
        }

        for split_name, split_data in splits.items():
            split_folder = os.path.join(base_dir, split_name)
            os.makedirs(split_folder, exist_ok=True)

            # 1. Export JSON
            json_path = os.path.join(split_folder, f"{split_name}_dataset.json")
            with open(json_path, "w") as f:
                json.dump(split_data, f, indent=2)

            # 2. Export JSONL
            jsonl_path = os.path.join(split_folder, f"{split_name}_dataset.jsonl")
            with open(jsonl_path, "w") as f:
                for item in split_data:
                    f.write(json.dumps(item) + "\n")

            # 3. Export CSV
            csv_path = os.path.join(split_folder, f"{split_name}_dataset.csv")
            if split_data:
                fieldnames = ["case_id", "synthetic", "severity", "chief_complaint", "expected_triage_category", "expected_escalation_action"]
                with open(csv_path, "w", newline="", encoding="utf-8") as f:
                    writer = csv.DictWriter(f, fieldnames=fieldnames)
                    writer.writeheader()
                    for item in split_data:
                        writer.writerow({
                            "case_id": item["case_id"],
                            "synthetic": item["synthetic"],
                            "severity": item["severity"],
                            "chief_complaint": item["chief_complaint"],
                            "expected_triage_category": item["expected_triage_category"],
                            "expected_escalation_action": item["expected_escalation_action"]
                        })

        print(f"[Splitter] Exported Datasets -> Train: {len(train_records)}, Val: {len(val_records)}, Test: {len(test_records)}")
        return splits

if __name__ == "__main__":
    src_file = "ml_pipeline/data/train/train_dataset.json"
    if not os.path.exists(src_file):
        src_file = "ml_pipeline/data/benchmark_20_cases.json"
        
    if os.path.exists(src_file):
        with open(src_file, "r", encoding="utf-8") as f:
            data = json.load(f)
        DatasetSplitter.split_and_export(data)
    else:
        print(f"Source file {src_file} not found. Run generator first.")

