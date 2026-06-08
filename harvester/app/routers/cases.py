from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.database import get_db
from app.models import CaseDraft, ReviewStatus
from app.schemas import ReviewDecision
from app.services import Exporter
import os

router = APIRouter(prefix="/api/cases", tags=["cases"])


@router.get("/")
def list_cases(status: str = "all", db: Session = Depends(get_db)):
    query = db.query(CaseDraft)
    if status != "all":
        query = query.filter(CaseDraft.review_status == status)
    return query.order_by(CaseDraft.created_at.desc()).all()


@router.get("/{case_id}")
def get_case(case_id: str, db: Session = Depends(get_db)):
    return db.query(CaseDraft).filter(CaseDraft.case_id == case_id).first()


@router.post("/review")
def review_case(decision: ReviewDecision, db: Session = Depends(get_db)):
    case = db.query(CaseDraft).filter(CaseDraft.case_id == decision.case_id).first()
    if not case:
        return {"error": "not found"}
    case.review_status = ReviewStatus(decision.decision)
    case.reviewer_note = decision.note
    db.commit()
    return {"status": "ok", "case_id": decision.case_id, "decision": decision.decision}


@router.post("/export")
def export_approved(db: Session = Depends(get_db)):
    approved = db.query(CaseDraft).filter(CaseDraft.review_status == ReviewStatus.approved).all()
    exporter = Exporter()
    output_path = os.path.join("exports", "approved_cases.json")
    count = exporter.export([_case_to_dict(c) for c in approved], output_path)
    return {"exported": count, "path": output_path}


def _case_to_dict(case: CaseDraft) -> dict:
    return {
        "case_id": case.case_id,
        "title_cn": case.title_cn,
        "title_en": case.title_en,
        "display_name": case.display_name if hasattr(case, 'display_name') else case.title_cn,
        "district": case.district,
        "threat_level": case.threat_level,
        "anomaly_type": case.anomaly_type,
        "briefing": case.briefing,
        "objectives": case.objectives,
        "boss_id": case.boss,
        "reward_items": case.reward_items,
        "archive_text": case.archive_text,
    }
