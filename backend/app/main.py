import logging

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.router import api_router

logger = logging.getLogger(__name__)

app = FastAPI(
    title="Adhvar API",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
    openapi_url="/openapi.json",
)

# CORS (Flutter Web & Mobile)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.on_event("startup")
def on_startup():
    """Automatic table creation and multi-building seeding for cloud deployments."""
    try:
        from app.db.database import Base, SessionLocal, engine
        from app.core.seed_data import seed_database

        # Ensure all database tables exist
        Base.metadata.create_all(bind=engine)

        # Seed campus buildings and navigation graph if database is fresh
        db = SessionLocal()
        try:
            seed_database(db)
        finally:
            db.close()

        logger.info("Cloud database startup initialization completed successfully.")
    except Exception as exc:
        logger.error("Startup database initialization error: %s", exc)


# API routes
app.include_router(api_router)


@app.get("/")
def root():
    return {"message": "Welcome to Adhvar API"}


@app.get("/health")
def health():
    return {"status": "healthy"}
