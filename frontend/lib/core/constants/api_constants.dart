class ApiConstants {
  ApiConstants._();

  /// Defaults to local server, override at build time with:
  /// flutter build web --dart-define=API_URL=https://your-api.onrender.com
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );

  static const String login = "/auth/login";
  static const String register = "/auth/register";
  static const String verifyOtp = "/auth/verify-otp";
  static const String resendOtp = "/auth/resend-otp";

  static const String buildings = "/buildings";
  static const String floors = "/floors";
  static const String rooms = "/rooms";
  static const String roomSearch = "/rooms/search";
  static const String nodes = "/nodes";
  static const String edges = "/edges";

  static const String navigation = "/navigation/path";
  static const String navigationRoute = "/navigation/route";
}
