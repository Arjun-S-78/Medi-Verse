"""
FastAPI Routes for MIRA Live Clinical Triage and Symptom Extraction.
"""

import uuid
from typing import Dict, Any, List, Optional
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session
import sys
import os

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "..")))

from ml_pipeline.database.db_config import get_db
from ml_pipeline.database.models import MiraTriageLog
from ml_pipeline.evaluator.mira_evaluator import MiraEvaluator

router = APIRouter(prefix="/api/v1/mira", tags=["MIRA Triage Engine"])

class TriageRequest(BaseModel):
    session_id: Optional[str] = Field(default_factory=lambda: f"SESS-{str(uuid.uuid4())[:8]}")
    patient_id: Optional[str] = "P-GUEST"
    chief_complaint: str = Field(..., example="I have severe crushing chest pain radiating to my left arm")
    conversation_history: List[Dict[str, str]] = Field(default_factory=list)

class TriageResponse(BaseModel):
    session_id: str
    synthetic: bool = True
    priority_level: str  # LOW, MODERATE, HIGH, CRITICAL
    extracted_symptoms: Dict[str, Any]
    emergency_red_flags: List[str]
    recommended_action: str
    mira_reply: str

@router.post("/triage", response_model=TriageResponse)
def process_triage(request: TriageRequest, db: Session = Depends(get_db)):
    """Processes patient text input, extracts symptoms, applies deterministic safety rules, and logs to DB."""
    # Wrap in synthetic test format for evaluation
    sim_record = {
        "chief_complaint": request.chief_complaint,
        "conversation": [{"speaker": "patient", "text": request.chief_complaint}] + request.conversation_history,
        "expected_triage_category": "UNKNOWN"
    }

    eval_result = MiraEvaluator.evaluate_mira_rules(sim_record)
    priority = eval_result["calculated_priority"]
    red_flags = eval_result["detected_red_flags"]

    # Recommended action mapping
    if priority == "CRITICAL":
        action = "Immediate ALS Emergency Ambulance Dispatch & Trauma Center Pre-notification"
        reply = "EMERGENCY ALERT: Your symptoms require immediate medical attention. We are dispatching an emergency ALS ambulance to your location right now. Please stay calm and sit down."
    elif priority == "HIGH":
        action = "Urgent Ambulance Dispatch & Emergency Room Registration"
        reply = "I have recorded your urgent symptoms. An ambulance is being prepared, and an emergency doctor has been notified."
    elif priority == "MODERATE":
        action = "Urgent Clinic Consultation within 2 Hours"
        reply = "Thank you. Based on your symptoms, we recommend visiting an urgent care clinic within 2 hours."
    else:
        action = "Routine Consultation & Self-Monitoring"
        reply = "Your symptoms appear non-urgent right now. Would you like to schedule a tele-consultation with a doctor?"

    extracted_symptoms = {
        "chestPain": "chest" in request.chief_complaint.lower(),
        "breathingDifficulty": "breath" in request.chief_complaint.lower() or "air" in request.chief_complaint.lower(),
        "unconsciousness": "unconscious" in request.chief_complaint.lower() or "passed out" in request.chief_complaint.lower(),
        "armRadiation": "arm" in request.chief_complaint.lower(),
        "sweating": "sweat" in request.chief_complaint.lower()
    }

    # Persist log to DB
    try:
        triage_log = MiraTriageLog(
            session_id=request.session_id,
            patient_id=request.patient_id,
            chief_complaint=request.chief_complaint,
            extracted_symptoms=extracted_symptoms,
            red_flags=red_flags,
            priority_level=priority,
            recommended_action=action
        )
        db.add(triage_log)
        db.commit()
    except Exception as e:
        db.rollback()
        print(f"[DB Log Error] {e}")

    return TriageResponse(
        session_id=request.session_id,
        synthetic=True,
        priority_level=priority,
        extracted_symptoms=extracted_symptoms,
        emergency_red_flags=red_flags,
        recommended_action=action,
        mira_reply=reply
    )
