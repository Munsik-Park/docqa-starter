def test_health_returns_ok(client):
    response = client.get("/api/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_health_creates_db_file(client, temp_db):
    assert not temp_db.exists()
    client.get("/api/health")
    assert temp_db.exists()
