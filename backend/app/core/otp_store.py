"""
In-memory OTP store with TTL expiry.

Stores: { email -> (otp_code, expires_at) }

For production with multiple workers, replace with Redis.
"""
import secrets
from datetime import datetime, timedelta, timezone
from threading import Lock

from app.core.config import settings


class OtpStore:
    def __init__(self):
        self._store: dict[str, tuple[str, datetime]] = {}
        self._lock = Lock()

    def generate_and_store(self, email: str) -> str:
        """Generate a 6-digit OTP, store it, and return it."""
        otp = f"{secrets.randbelow(1_000_000):06d}"
        expires_at = datetime.now(timezone.utc) + timedelta(
            minutes=settings.OTP_EXPIRE_MINUTES
        )
        with self._lock:
            self._store[email.lower()] = (otp, expires_at)
        return otp

    def verify(self, email: str, otp: str) -> bool:
        """
        Return True if OTP matches and has not expired.
        Removes the entry on success (single-use).
        """
        key = email.lower()
        with self._lock:
            entry = self._store.get(key)
            if entry is None:
                return False
            stored_otp, expires_at = entry
            if datetime.now(timezone.utc) > expires_at:
                del self._store[key]
                return False
            if stored_otp != otp:
                return False
            del self._store[key]  # single-use
            return True

    def has_pending(self, email: str) -> bool:
        key = email.lower()
        with self._lock:
            entry = self._store.get(key)
            if entry is None:
                return False
            _, expires_at = entry
            if datetime.now(timezone.utc) > expires_at:
                del self._store[key]
                return False
            return True


# Singleton instance shared across the app
otp_store = OtpStore()
