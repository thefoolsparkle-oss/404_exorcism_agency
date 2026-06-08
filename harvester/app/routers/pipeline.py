from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.database import get_db
from app.models import Source, Motif, CaseDraft, ReviewStatus
from app.services import SearchService, MotifExtractor, RiskReviewer, CaseGenerator, StyleRewriter
from app import schemas

router = APIRouter(prefix="/api/pipeline", tags=["pipeline"])


@router.post("/run")
def run_pipeline(query: str = "urban legend subway", db: Session = Depends(get_db)):
    search_svc = SearchService()
    extractor = MotifExtractor()
    reviewer = RiskReviewer()
    generator = CaseGenerator()
    rewriter = StyleRewriter()

    sources = search_svc.search(query)
    results = {"sources_found": len(sources), "generated_cases": []}

    for src in sources[:3]:
        existing = db.query(Source).filter(Source.url == src["url"]).first()
        if existing:
            continue

        source = Source(
            title=src["title"],
            url=src["url"],
            source_type=src.get("source_type", ""),
            language=src.get("language", ""),
            snippet=src.get("snippet", ""),
            raw_text=src.get("raw_text", ""),
        )
        db.add(source)
        db.flush()

        motif_data = extractor.extract(src.get("raw_text", ""))
        motif = Motif(
            source_id=source.id,
            location=motif_data.get("location", ""),
            time_period=motif_data.get("time_period", ""),
            anomaly_type=motif_data.get("anomaly_type", []),
            core_motif=motif_data.get("core_motif", {}),
            taboo_rule=motif_data.get("taboo_rule", ""),
            horror_point=motif_data.get("horror_point", ""),
            game_potential=motif_data.get("game_potential", ""),
            risk_tags=motif_data.get("suggested_mechanics", []),
        )
        db.add(motif)
        db.flush()

        risk_result = reviewer.review(src, motif_data)
        risk_tags = risk_result.get("risk_tags", [])
        decision = risk_result.get("decision", "pending")

        if decision == "rejected":
            db.commit()
            continue

        case_data = generator.generate(motif_data, risk_tags)
        if "error" in case_data:
            continue

        rewritten = rewriter.rewrite(case_data)
        if "error" in rewritten:
            rewritten = case_data

        case_id = rewritten.get("case_id", f"AUTO-{source.id:04d}")
        draft = CaseDraft(
            case_id=case_id,
            title_cn=rewritten.get("title_cn", ""),
            title_en=rewritten.get("title_en", ""),
            district=rewritten.get("district", ""),
            threat_level=rewritten.get("threat_level", 1),
            anomaly_type=rewritten.get("anomaly_type", []),
            briefing=rewritten.get("briefing", ""),
            objectives=rewritten.get("objectives", []),
            boss=rewritten.get("boss_id", ""),
            boss_mechanics=rewritten.get("boss_mechanics", {}),
            reward_items=rewritten.get("reward_items", []),
            archive_text=rewritten.get("archive_text", ""),
            source_ids=[source.id],
            review_status=ReviewStatus.pending,
        )
        db.add(draft)
        db.flush()

        results["generated_cases"].append({
            "case_id": case_id,
            "title_cn": rewritten.get("title_cn", ""),
            "review_status": "pending",
        })

    db.commit()
    return results
