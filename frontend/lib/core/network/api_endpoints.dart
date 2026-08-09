class ApiEndpoints {
  ApiEndpoints._();

  // Base URL
  static const String baseUrl = "http://10.0.2.2:8000/api";

  // Authentication
  static const String login = "/auth/login";
  static const String register = "/auth/register";
  static const String forgotPassword = "/auth/forgot-password";
  static const String logout = "/auth/logout";
  static const String refreshToken = "/auth/refresh-token";

  // User
  static const String profile = "/user/profile";
  static const String updateProfile = "/user/profile/update";

  // Buildings
  static const String buildings = "/buildings";
  static const String buildingDetails = "/buildings/details";

  // Floors
  static const String floors = "/floors";

  // Rooms
  static const String rooms = "/rooms";

  // Indoor Navigation
  static const String shortestPath = "/navigation/path";
  static const String navigationHistory = "/navigation/history";

  // Search
  static const String search = "/search";

  // QR Code
  static const String qrScan = "/qr/scan";

  // Maps
  static const String indoorMap = "/maps/indoor";

  // Health Check
  static const String health = "/health";
}
