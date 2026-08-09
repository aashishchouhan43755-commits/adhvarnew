class ApiConstants {
  ApiConstants._();

  /// Live Render HTTPS production backend
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://adhvar-api.onrender.com',
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
