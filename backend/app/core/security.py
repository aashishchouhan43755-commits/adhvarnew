import hashlib
from datetime import datetime, timedelta, timezone
from typing import Any

from jose import JWTError, jwt
from passlib.context import CryptContext

from app.core.config import settings

# Passlib context configured to disable strict 72-byte error throw
pwd_context = CryptContext(
    schemes=["bcrypt"],
    deprecated="auto",
    bcrypt__truncate_error=False,
)


def _hash_password_input(password: str) -> str:
    """Consistently SHA256 pre-hash password to a fixed 64-char string.
    Guarantees it never exceeds bcrypt's 72-byte limit on any platform.
    """
    return hashlib.sha256(password.encode("utf-8")).hexdigest()


def verify_password(plain_password: str, hashed_password: str) -> bool:
    prepared = _hash_password_input(plain_password)
    try:
        return pwd_context.verify(prepared, hashed_password)
    except Exception:
        # Fallback check for raw plain password if previously stored
        try:
            return pwd_context.verify(plain_password[:72], hashed_password)
        except Exception:
            return False


def get_password_hash(password: str) -> str:
    prepared = _hash_password_input(password)
    return pwd_context.hash(prepared)


def create_access_token(subject: Any, expires_delta: timedelta | None = None) -> str:
    if expires_delta:
        expire = datetime.now(timezone.utc) + expires_delta
    else:
        expire = datetime.now(timezone.utc) + timedelta(
            minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES
        )

    payload = {
        "sub": str(subject),
        "exp": expire,
    }

    return jwt.encode(
        payload,
        settings.SECRET_KEY,
        algorithm=settings.ALGORITHM,
    )


def decode_access_token(token: str) -> dict:
    try:
        payload = jwt.decode(
            token,
            settings.SECRET_KEY,
            algorithms=[settings.ALGORITHM],
        )
        return payload
    except JWTError:
        return {}