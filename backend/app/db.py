"""SQLite 연결.

DB 파일 위치는 환경 변수 DOCQA_DB_PATH로 바꿀 수 있다.
지정하지 않으면 backend/data/docqa.db를 쓴다. data/ 폴더는 커밋하지 않는다.
"""

import os
import sqlite3
from pathlib import Path

DEFAULT_DB_PATH = Path(__file__).resolve().parent.parent / "data" / "docqa.db"


def db_path() -> Path:
    return Path(os.environ.get("DOCQA_DB_PATH", DEFAULT_DB_PATH))


def connect() -> sqlite3.Connection:
    path = db_path()
    path.parent.mkdir(parents=True, exist_ok=True)
    conn = sqlite3.connect(path)
    conn.row_factory = sqlite3.Row
    return conn
