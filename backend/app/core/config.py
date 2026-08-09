from pydantic import field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    # ==========================
    # Application
    # ==========================
    APP_NAME: str = "Adhvar API"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = True

    HOST: str = "0.0.0.0"
    PORT: int = 8000

    # ==========================
    # Database
    # ==========================
    DB_HOST: str = "localhost"
    DB_PORT: int = 5432
    DB_NAME: str = "adhvar"
    DB_USER: str = "postgres"
    DB_PASSWORD: str = ""

    DATABASE_URL: str = "postgresql+psycopg://postgres:Aashish%40123@127.0.0.1:5432/adhvar"

    @field_validator("DATABASE_URL", mode="before")
    @classmethod
    def assemble_db_connection(cls, v: str | None) -> str:
        if not v:
            return "postgresql+psycopg://postgres:Aashish%40123@127.0.0.1:5432/adhvar"
        # Render / Railway provide postgres:// instead of postgresql+psycopg://
        if v.startswith("postgres://"):
            return v.replace("postgres://", "postgresql+psycopg://", 1)
        if v.startswith("postgresql://") and not v.startswith("postgresql+psycopg://"):
            return v.replace("postgresql://", "postgresql+psycopg://", 1)
        return v

    # ==========================
    # JWT
    # ==========================
    SECRET_KEY: str = "adhvar_super_secret_key_change_in_production_2026"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60

    # ==========================
    # Password Reset
    # ==========================
    RESET_TOKEN_EXPIRE_MINUTES: int = 15

    # ==========================
    # OTP
    # ==========================
    OTP_EXPIRE_MINUTES: int = 10

    # ==========================
    # SMTP
    # ==========================
    SMTP_SERVER: str = "smtp.gmail.com"
    SMTP_PORT: int = 587
    SMTP_EMAIL: str = "adhvar2026@gmail.com"
    SMTP_PASSWORD: str = "raci upko moxz xnwq"

    # ==========================
    # Frontend
    # ==========================
    FRONTEND_URL: str = "http://localhost:3000"

    # ==========================
    # Logging
    # ==========================
    LOG_LEVEL: str = "INFO"

    model_config = SettingsConfigDict(
        env_file=".env",
        case_sensitive=True,
        extra="ignore",
    )


settings = Settings()