from pydantic import BaseModel
from datetime import datetime
from typing import Optional


class SourceCreate(BaseModel):
    title: str
    url: str
    source_type: Optional[str] = None
    language: Optional[str] = None
    snippet: Optional[str] = None
    raw_text: Optional[str] = None
    license_status: Optional[str] = "unknown"
    risk_level: Optional[int] = 0


class SourceOut(SourceCreate):
    id: int
    collected_at: datetime

    class Config:
        from_attributes = True


class MotifCreate(BaseModel):
    source_id: int
    location: Optional[str] = None
    time_period: Optional[str] = None
    anomaly_type: Optional[list] = None
    core_motif: Optional[dict] = None
    taboo_rule: Optional[str] = None
    horror_point: Optional[str] = None
    game_potential: Optional[str] = None
    risk_tags: Optional[list] = None


class MotifOut(MotifCreate):
    id: int
    created_at: datetime

    class Config:
        from_attributes = True


class Objective(BaseModel):
    type: str
    target: str
    count: int
    text: str


class BossMechanic(BaseModel):
    name_cn: str = ""
    name_en: str = ""
    description_cn: str = ""
    phase_1: list = []
    phase_2: list = []
    phase_3: list = []


class CaseDraftCreate(BaseModel):
    case_id: str
    title_cn: str
    title_en: Optional[str] = None
    district: Optional[str] = None
    threat_level: Optional[int] = 1
    anomaly_type: Optional[list] = None
    briefing: Optional[str] = None
    objectives: Optional[list] = None
    boss: Optional[str] = None
    boss_mechanics: Optional[dict] = None
    reward_items: Optional[list] = None
    archive_text: Optional[str] = None
    source_ids: Optional[list] = None


class CaseDraftOut(CaseDraftCreate):
    id: int
    review_status: str
    created_at: datetime

    class Config:
        from_attributes = True


class ReviewDecision(BaseModel):
    case_id: str
    decision: str
    note: Optional[str] = None
