import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

from app.core.config import settings


def send_password_reset_email(
    recipient_email: str,
    reset_token: str,
) -> None:
    """
    Send password reset email.
    """

    reset_link = (
        f"{settings.FRONTEND_URL}/reset-password?token={reset_token}"
    )

    subject = "Reset Your Adhvar Password"

    html = f"""
    <html>
        <body style="font-family: Arial, sans-serif;">
            <h2>Adhvar Password Reset</h2>

            <p>Hello,</p>

            <p>
                We received a request to reset your password.
            </p>

            <p>
                Click the button below to reset your password.
            </p>

            <p>
                <a
                    href="{reset_link}"
                    style="
                        background:#2563eb;
                        color:white;
                        padding:12px 24px;
                        border-radius:6px;
                        text-decoration:none;
                    "
                >
                    Reset Password
                </a>
            </p>

            <p>
                This link expires in
                <b>{settings.RESET_TOKEN_EXPIRE_MINUTES} minutes</b>.
            </p>

            <p>
                If you didn't request this password reset,
                you can safely ignore this email.
            </p>

            <hr>

            <p>
                Team Adhvar
            </p>
        </body>
    </html>
    """

    message = MIMEMultipart("alternative")
    message["Subject"] = subject
    message["From"] = settings.SMTP_EMAIL
    message["To"] = recipient_email

    message.attach(MIMEText(html, "html"))

    with smtplib.SMTP(
        settings.SMTP_SERVER,
        settings.SMTP_PORT,
    ) as server:
        server.starttls()
        server.login(
            settings.SMTP_EMAIL,
            settings.SMTP_PASSWORD,
        )
        server.sendmail(
            settings.SMTP_EMAIL,
            recipient_email,
            message.as_string(),
        )


def send_otp_email(recipient_email: str, otp: str) -> None:
    """
    Send a beautiful 6-digit OTP verification email.
    """
    subject = "Your Adhvar Verification Code"

    html = f"""
    <html>
        <body style="margin:0;padding:0;background:#f0f4ff;font-family:'Segoe UI',Arial,sans-serif;">
            <table width="100%" cellpadding="0" cellspacing="0" style="background:#f0f4ff;padding:40px 0;">
                <tr>
                    <td align="center">
                        <table width="480" cellpadding="0" cellspacing="0"
                               style="background:#ffffff;border-radius:16px;
                                      box-shadow:0 4px 24px rgba(37,99,235,0.10);overflow:hidden;">
                            <!-- Header -->
                            <tr>
                                <td style="background:linear-gradient(135deg,#1d4ed8 0%,#7c3aed 100%);
                                           padding:36px 40px 28px;text-align:center;">
                                    <h1 style="margin:0;color:#ffffff;font-size:26px;
                                               font-weight:700;letter-spacing:-0.5px;">
                                        &#x1F4CD; Adhvar
                                    </h1>
                                    <p style="margin:6px 0 0;color:rgba(255,255,255,0.80);
                                              font-size:14px;">Indoor Navigation System</p>
                                </td>
                            </tr>
                            <!-- Body -->
                            <tr>
                                <td style="padding:36px 40px 20px;">
                                    <p style="margin:0 0 8px;font-size:16px;color:#1e293b;
                                              font-weight:600;">Verify your email address</p>
                                    <p style="margin:0 0 28px;font-size:14px;color:#64748b;line-height:1.6;">
                                        Use the code below to complete your registration.
                                        This code expires in
                                        <strong>{settings.OTP_EXPIRE_MINUTES} minutes</strong>.
                                    </p>
                                    <!-- OTP box -->
                                    <div style="background:#f0f4ff;border:2px dashed #818cf8;
                                                border-radius:12px;padding:24px;text-align:center;
                                                margin-bottom:28px;">
                                        <p style="margin:0 0 6px;font-size:12px;color:#6366f1;
                                                  letter-spacing:2px;text-transform:uppercase;
                                                  font-weight:600;">Your verification code</p>
                                        <p style="margin:0;font-size:44px;font-weight:800;
                                                  letter-spacing:12px;color:#1d4ed8;
                                                  font-family:'Courier New',monospace;">
                                            {otp}
                                        </p>
                                    </div>
                                    <p style="margin:0;font-size:13px;color:#94a3b8;line-height:1.6;">
                                        If you did not create an Adhvar account, you can safely
                                        ignore this email.
                                    </p>
                                </td>
                            </tr>
                            <!-- Footer -->
                            <tr>
                                <td style="background:#f8fafc;padding:20px 40px;
                                           border-top:1px solid #e2e8f0;text-align:center;">
                                    <p style="margin:0;font-size:12px;color:#94a3b8;">
                                        &copy; 2026 Adhvar &mdash; Indoor Navigation System
                                    </p>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
        </body>
    </html>
    """

    message = MIMEMultipart("alternative")
    message["Subject"] = subject
    message["From"] = f"Adhvar <{settings.SMTP_EMAIL}>"
    message["To"] = recipient_email

    message.attach(MIMEText(html, "html"))

    with smtplib.SMTP(
        settings.SMTP_SERVER,
        settings.SMTP_PORT,
    ) as server:
        server.starttls()
        server.login(
            settings.SMTP_EMAIL,
            settings.SMTP_PASSWORD,
        )
        server.sendmail(
            settings.SMTP_EMAIL,
            recipient_email,
            message.as_string(),
        )