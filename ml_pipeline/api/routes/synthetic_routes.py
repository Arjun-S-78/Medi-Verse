"""
FastAPI Routes for Synthetic Medical Dataset Generation and Querying.
"""

from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
import sys
import os

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "..")))

from ml_pipeline.database.db_config import get_db, engine, Base
from ml_pipeline.database.models import SyntheticRecord
from ml_pipeline.generator.synthetic_generator import SyntheticDataGenerator, save_to_database
from ml_pipeline.validator.quality_control import QualityControlValidator

router = APIRouter(prefix="/api/v1/synthetic", tags=["Synthetic Datasets"])

@router.post("/generate")
def generate_synthetic_records(
    count: int = Query(20, ge=1, le=1000, description="Number of records to generate"),
    seed: Optional[int] = Query(42, description="Random seed"),
    save_to_db: bool = Query(True, description="Persist generated dataset to database"),
    db: Session = Depends(get_db)
):
    """Generates synthetic emergency medical record scenarios."""
    generator = SyntheticDataGenerator(seed=seed)
    records = generator.generate_dataset(count=count)

    # Quality control check
    valid_c, invalid_c, errs = QualityControlValidator.validate_dataset(records)
    if invalid_c > 0:
        raise HTTPException(status_code=422, detail={"message": "Quality control failed", "errors": errs})

    if save_to_db:
        save_to_database(records)

    return {
        "message": f"Successfully generated {len(records)} synthetic medical scenarios.",
        "count": len(records),
        "synthetic_flag": True,
        "records": records[:5]  # Preview first 5
    }

@router.get("/records")
def get_synthetic_records(
    category: Optional[str] = Query(None, description="Filter by category"),
    severity: Optional[str] = Query(None, description="Filter by severity (LOW, MODERATE, HIGH, CRITICAL)"),
    split_type: Optional[str] = Query(None, description="Filter by split (train, val, test)"),
    limit: int = Query(50, ge=1, le=200),
    db: Session = Depends(get_db)
):
    """Retrieves synthetic medical records stored in the database."""
    query = db.query(SyntheticRecord)

    if category:
        query = query.filter(SyntheticRecord.category == category)
    if severity:
        query = query.filter(SyntheticRecord.severity == severity)
    if split_type:
        query = query.filter(SyntheticRecord.split_type == split_type)

    records = query.limit(limit).all()
    return {
        "count": len(records),
        "results": [r.payload for r in records]
    }
