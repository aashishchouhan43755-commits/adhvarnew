from datetime import datetime, timedelta, timezone

from jose import JWTError, jwt

from app.core.config import settings


def create_reset_token(email: str) -> str:
    """
    Create a password reset JWT token.
    """

    expire = datetime.now(timezone.utc) + timedelta(
        minutes=settings.RESET_TOKEN_EXPIRE_MINUTES,
    )

    payload = {
        "sub": email,
        "type": "password_reset",
        "exp": expire,
    }

    return jwt.encode(
        payload,
        settings.SECRET_KEY,
        algorithm=settings.ALGORITHM,
    )


def verify_reset_token(token: str) -> str:
    """
    Verify password reset JWT token.
    Returns the email stored in the token.
    """

    try:
        payload = jwt.decode(
            token,
            settings.SECRET_KEY,
            algorithms=[settings.ALGORITHM],
        )

        if payload.get("type") != "password_reset":
            raise ValueError("Invalid reset token.")

        email = payload.get("sub")

        if email is None:
            raise ValueError("Invalid reset token.")

        return str(email)

    except JWTError as exc:
        raise ValueError("Reset token has expired or is invalid.") from exc