import datetime
from sqlalchemy import Column, Integer, String, Boolean, Float, DateTime, JSON, Text
from .db_config import Base

class SyntheticRecord(Base):
    """SQLAlchemy model for storing synthetic medical record scenarios."""
    __tablename__ = "synthetic_records"

    id = Column(Integer, primary_key=True, index=True)
    case_id = Column(String(64), unique=True, index=True, nullable=False)
    synthetic = Column(Boolean, default=True, nullable=False)
    category = Column(String(64), index=True, nullable=False)
    severity = Column(String(32), index=True, nullable=False)  # LOW, MODERATE, HIGH, CRITICAL
    split_type = Column(String(32), index=True, default="train") # train, val, test, adversarial
    chief_complaint = Column(Text, nullable=False)
    payload = Column(JSON, nullable=False)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)

class MiraTriageLog(Base):
    """SQLAlchemy model for live MIRA triage assessments and symptom extraction logs."""
    __tablename__ = "mira_triage_logs"

    id = Column(Integer, primary_key=True, index=True)
    session_id = Column(String(64), index=True, nullable=False)
    patient_id = Column(String(64), index=True, nullable=True)
    chief_complaint = Column(Text, nullable=False)
    extracted_symptoms = Column(JSON, nullable=False)
    red_flags = Column(JSON, nullable=False)
    priority_level = Column(String(32), index=True, nullable=False) # LOW, MODERATE, HIGH, CRITICAL
    recommended_action = Column(Text, nullable=False)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)

class EvaluationMetric(Base):
    """SQLAlchemy model for storing synthetic MIRA test suite evaluation results."""
    __tablename__ = "evaluation_metrics"

    id = Column(Integer, primary_key=True, index=True)
    evaluation_run_id = Column(String(64), unique=True, index=True, nullable=False)
    dataset_size = Column(Integer, nullable=False)
    symptom_extraction_accuracy = Column(Float, nullable=False)
    red_flag_sensitivity = Column(Float, nullable=False)
    priority_classification_accuracy = Column(Float, nullable=False)
    false_negative_rate = Column(Float, nullable=False)
    details_json = Column(JSON, nullable=False)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)
