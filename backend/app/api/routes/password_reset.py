from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.db.database import get_db
from app.models.user import User
from app.schemas.password_reset import (
    ForgotPasswordRequest,
    ForgotPasswordResponse,
    ResetPasswordRequest,
    ResetPasswordResponse,
)
from app.core.security import get_password_hash
from app.core.reset_token import (
    create_reset_token,
    verify_reset_token,
)
from app.core.email import send_password_reset_email

router = APIRouter(
    prefix="/auth",
    tags=["Password Reset"],
)


@router.post(
    "/forgot-password",
    response_model=ForgotPasswordResponse,
)
def forgot_password(
    request: ForgotPasswordRequest,
    db: Session = Depends(get_db),
):
    user = (
        db.query(User)
        .filter(User.email == request.email)
        .first()
    )

    # Never reveal whether the email exists.
    if user:
        token = create_reset_token(user.email)

        send_password_reset_email(
            recipient_email=user.email,
            reset_token=token,
        )

    return ForgotPasswordResponse(
        message="If the email exists, a password reset link has been sent."
    )


@router.post(
    "/reset-password",
    response_model=ResetPasswordResponse,
)
def reset_password(
    request: ResetPasswordRequest,
    db: Session = Depends(get_db),
):
    try:
        email = verify_reset_token(request.token)
    except ValueError:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid or expired reset token.",
        )

    user = (
        db.query(User)
        .filter(User.email == email)
        .first()
    )

    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found.",
        )

    user.hashed_password = get_password_hash(
        request.new_password,
    )

    db.commit()
    db.refresh(user)

    return ResetPasswordResponse(
        message="Password reset successfully."
    )