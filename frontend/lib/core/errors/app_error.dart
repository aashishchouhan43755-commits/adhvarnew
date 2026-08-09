import 'package:dio/dio.dart';

/// Converts any raw exception into a short, friendly message.
/// No stack traces, no HTTP codes — just plain English.
class AppError {
  AppError._();

  static String parse(Object error) {
    if (error is DioException) return _fromDio(error);
    return _fromString(error.toString().toLowerCase());
  }

  // ── Dio / HTTP errors ─────────────────────────────────────────────────────

  static String _fromDio(DioException e) {
    // Network / timeout errors
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return 'Cannot reach the server. Check your internet connection.';
    }

    final statusCode = e.response?.statusCode;
    final detail = _extractDetail(e.response?.data);

    switch (statusCode) {
      // ── 400: Bad input / business logic ──────────────────────────────────
      // NOTE: "password" must NOT trigger "Incorrect password" here —
      // that's authentication context only (401). A 400 with "password"
      // in the text is a validation or DB error, not an auth failure.
      case 400:
        if (detail.contains('otp') || detail.contains('code')) {
          return 'Incorrect or expired code. Please try again.';
        }
        if (detail.contains('email') && detail.contains('send')) {
          return 'Could not send the verification email. Please try again.';
        }
        if (detail.contains('already verified')) {
          return 'This account is already verified. Please log in.';
        }
        if (detail.contains('no account') || detail.contains('not found')) {
          return 'No account found with that email address.';
        }
        if (detail.contains('already registered') ||
            detail.contains('already exists')) {
          return 'This email is already registered. Try logging in instead.';
        }
        // Generic 400 — safe, neutral message
        return 'Something went wrong. Please check your input and try again.';

      // ── 401: Wrong credentials ────────────────────────────────────────────
      case 401:
        if (detail.contains('not verified') || detail.contains('unverified')) {
          return 'Please verify your email before logging in.';
        }
        return 'Wrong email or password. Please try again.';

      // ── 403: Account/permission issue ─────────────────────────────────────
      case 403:
        if (detail.contains('not verified') ||
            detail.contains('verify') ||
            detail.contains('otp')) {
          return 'Please verify your email before logging in.';
        }
        return 'Access denied. Please check your credentials.';

      // ── 404: Not found ────────────────────────────────────────────────────
      case 404:
        if (detail.contains('user') || detail.contains('email') ||
            detail.contains('account')) {
          return 'No account found with that email address.';
        }
        return 'The requested item was not found.';

      // ── 409: Conflict / already exists ────────────────────────────────────
      case 409:
        if (detail.contains('not verified') || detail.contains('pending')) {
          return 'Account exists but is not verified. A new code has been sent to your email.';
        }
        if (detail.contains('email') || detail.contains('registered') ||
            detail.contains('already')) {
          return 'This email is already registered. Try logging in instead.';
        }
        return 'This item already exists.';

      // ── 422: Validation error ─────────────────────────────────────────────
      case 422:
        if (detail.contains('email')) {
          return 'Please enter a valid email address.';
        }
        return 'Please check your input and try again.';

      // ── 429: Rate limited ─────────────────────────────────────────────────
      case 429:
        return 'Too many attempts. Please wait a moment and try again.';

      // ── 5xx: Server errors ────────────────────────────────────────────────
      case 500:
      case 502:
      case 503:
        return 'Server error. Please try again in a few seconds.';
    }

    // Fallback: try detail string
    if (detail.isNotEmpty) return _fromString(detail);
    return 'Something went wrong. Please try again.';
  }

  // ── Extract detail from response body ────────────────────────────────────

  static String _extractDetail(dynamic data) {
    if (data == null) return '';
    if (data is Map) {
      final d = data['detail'];
      if (d is String) return d.toLowerCase();
      if (d is List && d.isNotEmpty) {
        final first = d.first;
        if (first is Map && first['msg'] is String) {
          return (first['msg'] as String).toLowerCase();
        }
      }
    }
    return data.toString().toLowerCase();
  }

  // ── String-based fallback ─────────────────────────────────────────────────

  static String _fromString(String msg) {
    if (msg.contains('not verified') || msg.contains('unverified')) {
      return 'Please verify your email before logging in.';
    }
    if (msg.contains('already registered') || msg.contains('already exists') ||
        msg.contains('duplicate')) {
      return 'This email is already registered. Try logging in instead.';
    }
    if (msg.contains('not found') || msg.contains('no account')) {
      return 'No account found with that email address.';
    }
    if (msg.contains('expired') && msg.contains('otp')) {
      return 'Your code has expired. Please request a new one.';
    }
    if (msg.contains('invalid') && msg.contains('otp')) {
      return 'Incorrect or expired code. Please try again.';
    }
    if (msg.contains('send') && msg.contains('email')) {
      return 'Could not send the verification email. Please try again.';
    }
    if (msg.contains('network') || msg.contains('socket') ||
        msg.contains('connection')) {
      return 'Cannot reach the server. Check your internet connection.';
    }
    if (msg.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }
    return 'Something went wrong. Please try again.';
  }
}
