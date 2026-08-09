from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, EmailStr
from sqlalchemy.orm import Session

from app.api.dependencies import get_db
from app.schemas.token import Token
from app.services.auth_service import AuthService

router = APIRouter(prefix="/auth", tags=["Authentication"])


class RegisterRequest(BaseModel):
    full_name: str
    email: EmailStr
    password: str


class LoginRequest(BaseModel):
    email: EmailStr
    password: str


class OtpVerifyRequest(BaseModel):
    email: EmailStr
    otp: str


class ResendOtpRequest(BaseModel):
    email: EmailStr


# ── Register ─────────────────────────────────────────────────────────────────

@router.post("/register", status_code=status.HTTP_201_CREATED)
def register(
    request: RegisterRequest,
    db: Session = Depends(get_db),
):
    service = AuthService(db)
    try:
        user = service.register(
            full_name=request.full_name,
            email=request.email,
            password=request.password,
        )
        return {
            "message": "Registration successful. Check your email for the OTP.",
            "id": user.id,
            "email": user.email,
            "is_verified": False,
        }
    except ValueError as e:
        err = str(e)
        # User exists but is unverified — OTP was resent
        if err == "EMAIL_PENDING_VERIFICATION":
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Account already exists but is not verified. "
                       "A new OTP has been sent to your email.",
            )
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=err,
        )


# ── Resend OTP ────────────────────────────────────────────────────────────────

@router.post("/resend-otp", status_code=status.HTTP_200_OK)
def resend_otp(
    request: ResendOtpRequest,
    db: Session = Depends(get_db),
):
    service = AuthService(db)
    try:
        service.send_otp(email=request.email)
        return {"message": "A new OTP has been sent to your email."}
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e),
        )


# ── Verify OTP ────────────────────────────────────────────────────────────────

@router.post("/verify-otp", response_model=Token)
def verify_otp(
    request: OtpVerifyRequest,
    db: Session = Depends(get_db),
):
    service = AuthService(db)
    try:
        access_token = service.verify_otp(
            email=request.email,
            otp=request.otp,
        )
        return Token(access_token=access_token, token_type="bearer")
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e),
        )


# ── Login ─────────────────────────────────────────────────────────────────────

@router.post("/login", response_model=Token)
def login(
    request: LoginRequest,
    db: Session = Depends(get_db),
):
    service = AuthService(db)
    try:
        access_token = service.login(
            email=request.email,
            password=request.password,
        )
        return Token(access_token=access_token, token_type="bearer")
    except ValueError as e:
        err = str(e)
        if err == "EMAIL_NOT_VERIFIED":
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Email not verified. A new OTP has been sent to your email.",
            )
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=err,
        )