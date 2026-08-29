"""
FastAPI Routes for Running and Fetching MIRA Evaluation Suite Metrics.
"""

from typing import Optional
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
import sys
import os

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "..")))

from ml_pipeline.database.db_config import get_db
from ml_pipeline.database.models import SyntheticRecord, EvaluationMetric
from ml_pipeline.evaluator.mira_evaluator import MiraEvaluator

router = APIRouter(prefix="/api/v1/mira/evaluation", tags=["MIRA Evaluation Metrics"])

@router.post("/run")
def run_evaluation(
    split_type: Optional[str] = Query("test", description="Dataset split to evaluate (test, val, train)"),
    db: Session = Depends(get_db)
):
    """Executes evaluation suite against synthetic test set in DB and returns performance report."""
    query = db.query(SyntheticRecord)
    if split_type:
        query = query.filter(SyntheticRecord.split_type == split_type)

    records = query.all()
    if not records:
        # Fallback to loading local benchmark JSON
        benchmark_path = "ml_pipeline/data/benchmark_20_cases.json"
        if os.path.exists(benchmark_path):
            import json
            with open(benchmark_path, "r") as f:
                dataset = json.load(f)
        else:
            raise HTTPException(status_code=404, detail=f"No synthetic records found for split '{split_type}'")
    else:
        dataset = [r.payload for r in records]

    report = MiraEvaluator.evaluate_dataset(dataset, db_session=db)
    return report

@router.get("/metrics")
def get_latest_metrics(db: Session = Depends(get_db)):
    """Retrieves the latest evaluation run metrics from database."""
    latest = db.query(EvaluationMetric).order_by(EvaluationMetric.created_at.desc()).first()
    if not latest:
        return {
            "message": "No evaluation metrics recorded yet.",
            "metrics": None
        }

    return {
        "evaluation_run_id": latest.evaluation_run_id,
        "dataset_size": latest.dataset_size,
        "symptom_extraction_accuracy": latest.symptom_extraction_accuracy,
        "red_flag_sensitivity": latest.red_flag_sensitivity,
        "priority_classification_accuracy": latest.priority_classification_accuracy,
        "false_negative_rate": latest.false_negative_rate,
        "details": latest.details_json,
        "created_at": latest.created_at.isoformat()
    }
