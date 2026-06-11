import os
from pathlib import Path


TEST_DB = Path(__file__).resolve().parent.parent / ".pytest_cache" / "test_harvester.db"
os.environ["DATABASE_URL"] = f"sqlite:///{TEST_DB.as_posix()}"


def pytest_sessionstart(session):
    TEST_DB.parent.mkdir(exist_ok=True)
    if TEST_DB.exists():
        TEST_DB.unlink()


def pytest_sessionfinish(session, exitstatus):
    try:
        from app.database import engine
        engine.dispose()
    except Exception:
        pass
    if TEST_DB.exists():
        try:
            TEST_DB.unlink()
        except PermissionError:
            pass
