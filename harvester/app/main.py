from fastapi import FastAPI
from app.routers import cases, pipeline

app = FastAPI(title="Anomaly Harvester", version="0.1.0")

app.include_router(cases.router)
app.include_router(pipeline.router)


@app.get("/health")
def health():
    return {"status": "ok", "service": "anomaly-harvester"}
