from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)


def test_health():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "ok"


def test_pipeline_run():
    response = client.post("/api/pipeline/run", params={"query": "test"})
    assert response.status_code == 200
    data = response.json()
    assert "sources_found" in data
    assert "generated_cases" in data
    assert data["sources_found"] > 0
    assert len(data["generated_cases"]) > 0
    generated = data["generated_cases"][0]
    assert generated["case_id"]
    assert generated["title_cn"]


def test_list_cases():
    response = client.get("/api/cases/")
    assert response.status_code == 200


def test_export():
    response = client.post("/api/cases/export")
    assert response.status_code == 200


def test_review_rejects_invalid_decision():
    response = client.post("/api/cases/review", json={"case_id": "missing", "decision": "bad"})
    assert response.status_code == 422
