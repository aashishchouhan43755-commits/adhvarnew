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

    DATABASE_URL: str

    # ==========================
    # JWT
    # ==========================
    SECRET_KEY: str
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
    SMTP_EMAIL: str = ""
    SMTP_PASSWORD: str = ""

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