import os
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base

# PostgreSQL database URI with local SQLite fallback for testing environments
DATABASE_URL = os.getenv(
    "DATABASE_URL", 
    "sqlite:///./mediverse_synthetic.db"
)

# Connect args for SQLite if used
connect_args = {"check_same_thread": False} if "sqlite" in DATABASE_URL else {}

engine = create_engine(
    DATABASE_URL,
    connect_args=connect_args,
    pool_pre_ping=True,
    echo=False
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

def get_db():
    """Dependency for obtaining DB session in FastAPI handlers."""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
