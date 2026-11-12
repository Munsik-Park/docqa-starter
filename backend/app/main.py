from fastapi import FastAPI

from app import db

app = FastAPI(title="문서 Q&A 서비스")


@app.get("/api/health")
def health() -> dict[str, str]:
    """서버가 떠 있고 DB 파일을 열 수 있는지 확인한다."""
    conn = db.connect()
    try:
        conn.execute("SELECT 1")
    finally:
        conn.close()
    return {"status": "ok"}
