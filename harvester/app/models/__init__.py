from app.database import Base
from sqlalchemy import Column, Integer, String, Text, DateTime, ForeignKey, JSON, Enum as SAEnum
from sqlalchemy.sql import func
import enum


class ReviewStatus(str, enum.Enum):
    pending = "pending"
    approved = "approved"
    rejected = "rejected"
    rewrite_needed = "rewrite_needed"


class Source(Base):
    __tablename__ = "sources"
    id = Column(Integer, primary_key=True, autoincrement=True)
    title = Column(String(512), nullable=False)
    url = Column(Text, nullable=False)
    source_type = Column(String(64))
    language = Column(String(32))
    snippet = Column(Text)
    raw_text = Column(Text(16777215))
    license_status = Column(String(64), default="unknown")
    collected_at = Column(DateTime, default=func.now())
    risk_level = Column(Integer, default=0)


class Motif(Base):
    __tablename__ = "motifs"
    id = Column(Integer, primary_key=True, autoincrement=True)
    source_id = Column(Integer, ForeignKey("sources.id"), nullable=False)
    location = Column(String(255))
    time_period = Column(String(255))
    anomaly_type = Column(JSON)
    core_motif = Column(JSON)
    taboo_rule = Column(Text)
    horror_point = Column(Text)
    game_potential = Column(Text)
    risk_tags = Column(JSON)
    created_at = Column(DateTime, default=func.now())


class CaseDraft(Base):
    __tablename__ = "case_drafts"
    id = Column(Integer, primary_key=True, autoincrement=True)
    case_id = Column(String(64), unique=True)
    title_cn = Column(String(255), nullable=False)
    title_en = Column(String(255))
    district = Column(String(255))
    threat_level = Column(Integer)
    anomaly_type = Column(JSON)
    briefing = Column(Text)
    objectives = Column(JSON)
    boss = Column(String(255))
    boss_mechanics = Column(JSON)
    reward_items = Column(JSON)
    archive_text = Column(Text)
    source_ids = Column(JSON)
    similarity_note = Column(Text)
    review_status = Column(SAEnum(ReviewStatus), default=ReviewStatus.pending)
    reviewer_note = Column(Text)
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now())


class Export(Base):
    __tablename__ = "exports"
    id = Column(Integer, primary_key=True, autoincrement=True)
    export_name = Column(String(255))
    file_path = Column(Text)
    case_count = Column(Integer)
    exported_at = Column(DateTime, default=func.now())
