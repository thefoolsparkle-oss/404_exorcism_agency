from fastapi import FastAPI
from app.database import init_db, engine
from app.models import Base
from app.routers import cases, pipeline

Base.metadata.create_all(bind=engine)

app = FastAPI(title="Anomaly Harvester", version="0.1.0")

app.include_router(cases.router)
app.include_router(pipeline.router)


@app.get("/health")
def health():
    return {"status": "ok", "service": "anomaly-harvester"}
