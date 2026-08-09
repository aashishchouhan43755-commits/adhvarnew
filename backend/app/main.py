from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.router import api_router

app = FastAPI(
    title="Adhvar API",
    version="1.0.0",
)

# CORS (Flutter Web)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Change to your frontend URL in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# API routes
app.include_router(api_router)


@app.get("/")
def root():
    return {
        "message": "Welcome to Adhvar API"
    }


@app.get("/health")
def health():
    return {
        "status": "healthy"
    }
