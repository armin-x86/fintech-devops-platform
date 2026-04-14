from fastapi.testclient import TestClient

from app.main import app


client = TestClient(app)


def test_health() -> None:
    res = client.get("/health")
    assert res.status_code == 200
    data = res.json()
    assert data["status"] == "healthy"


def test_assets() -> None:
    res = client.get("/assets")
    assert res.status_code == 200
    assets = res.json()
    assert isinstance(assets, list)
    assert len(assets) > 0
    assert {"id", "nominal_value", "status", "due_date"} <= set(assets[0].keys())


def test_insights() -> None:
    res = client.get("/insights")
    assert res.status_code == 200
    insights = res.json()
    assert isinstance(insights, list)
    assert len(insights) > 0
    assert {"id", "name", "value"} <= set(insights[0].keys())
