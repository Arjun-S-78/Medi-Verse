"""
FastAPI Server for MediVerse MIRA Synthetic Data Engine, Triage API, & Evaluation Metrics.
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import sys
import os

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..")))

from ml_pipeline.database.db_config import engine, Base
from ml_pipeline.api.routes import synthetic_routes, triage_routes, evaluation_routes

# Create DB tables on startup
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="MediVerse MIRA Synthetic Engine & Triage API",
    description="Enterprise API serving synthetic medical datasets, AI nurse triage, and evaluation metrics.",
    version="1.0.0"
)

# Configure CORS for Flutter Web / Localhost access
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include Route Modules
app.include_router(synthetic_routes.router)
app.include_router(triage_routes.router)
app.include_router(evaluation_routes.router)

@app.get("/")
@app.get("/health")
@app.get("/api/v1/mira/health")
def root():
    return {
        "service": "MediVerse MIRA Synthetic Engine & FastAPI Service",
        "status": "online",
        "version": "1.0.0",
        "synthetic_data_pipeline": "active",
        "docs_url": "/docs"
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
