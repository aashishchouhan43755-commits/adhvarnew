import logging

from sqlalchemy.orm import Session

from app.core.email import send_otp_email
from app.core.otp_store import otp_store
from app.core.security import (
    create_access_token,
    get_password_hash,
    verify_password,
)
from app.models.user import User
from app.repositories.user_repository import UserRepository

logger = logging.getLogger(__name__)


class AuthService:
    def __init__(self, db: Session):
        self.db = db
        self.user_repo = UserRepository(db)

    # ── Registration ────────────────────────────────────────────────────────

    def register(self, full_name: str, email: str, password: str) -> User:
        """Create an unverified user and trigger 6-digit OTP generation."""
        clean_email = email.lower().strip()
        existing = self.user_repo.get_by_email(clean_email)
        if existing:
            if existing.is_verified:
                raise ValueError("Email already registered")
            # Re-send OTP for unverified users who try registering again
            self._send_otp(clean_email)
            return existing

        user = User(
            full_name=full_name,
            email=clean_email,
            hashed_password=get_password_hash(password),
            is_active=True,
            is_verified=False,  # Unverified until 6-digit OTP is verified
            is_superuser=False,
        )

        user = self.user_repo.create(user)
        self._send_otp(clean_email)
        return user

    # ── OTP ─────────────────────────────────────────────────────────────────

    def send_otp(self, email: str) -> None:
        """Generate and send a fresh 6-digit OTP."""
        clean_email = email.lower().strip()
        user = self.user_repo.get_by_email(clean_email)
        if not user:
            raise ValueError("No account found with that email")
        if user.is_verified:
            raise ValueError("Account is already verified")
        self._send_otp(clean_email)

    def _send_otp(self, email: str) -> None:
        clean_email = email.lower().strip()
        otp = otp_store.generate_and_store(clean_email)
        try:
            send_otp_email(clean_email, otp)
            logger.info("OTP email sent to %s (code: %s)", clean_email, otp)
        except Exception as exc:
            logger.info("OTP generated for %s (code: %s, SMTP note: %s)", clean_email, otp, exc)

    def verify_otp(self, email: str, otp: str) -> str:
        """Verify 6-digit OTP code, set is_verified=True, and issue access token."""
        clean_email = email.lower().strip()
        user = self.user_repo.get_by_email(clean_email)
        if not user:
            raise ValueError("No account found with that email")

        if not otp_store.verify(clean_email, otp):
            raise ValueError("Invalid or expired OTP code")

        # Mark account as verified in DB
        user.is_verified = True
        self.db.commit()
        self.db.refresh(user)

        return create_access_token(subject=user.id)

    # ── Login ────────────────────────────────────────────────────────────────

    def login(self, email: str, password: str) -> str:
        clean_email = email.lower().strip()
        user = self.user_repo.get_by_email(clean_email)

        if not user:
            raise ValueError("Invalid email or password")

        if not verify_password(password, user.hashed_password):
            raise ValueError("Invalid email or password")

        if not user.is_verified:
            self._send_otp(clean_email)
            raise ValueError("EMAIL_NOT_VERIFIED")

        return create_access_token(subject=user.id)