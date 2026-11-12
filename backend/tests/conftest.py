import pytest
from fastapi.testclient import TestClient

from app.main import app


@pytest.fixture(autouse=True)
def temp_db(tmp_path, monkeypatch):
    """테스트마다 임시 폴더의 새 DB를 쓴다. 실제 data/docqa.db는 건드리지 않는다."""
    path = tmp_path / "test.db"
    monkeypatch.setenv("DOCQA_DB_PATH", str(path))
    return path


@pytest.fixture
def client():
    return TestClient(app)
