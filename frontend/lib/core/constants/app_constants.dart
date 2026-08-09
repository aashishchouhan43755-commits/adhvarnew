class AppConstants {
  AppConstants._();

  // App
  static const String appName = "Adhvar";
  static const String appVersion = "1.0.0";
  static const String appTagline = "Navigate Every Space";

  // Routes
  static const String loginRoute = "/";
  static const String registerRoute = "/register";
  static const String forgotPasswordRoute = "/forgot-password";
  static const String homeRoute = "/home";
  static const String buildingRoute = "/buildings";
  static const String floorRoute = "/floor";
  static const String indoorMapRoute = "/map";
  static const String profileRoute = "/profile";
  static const String navigationRoute = "/navigation";
  static const String searchRoute = "/search";

  // Animation
  static const Duration splashDuration = Duration(seconds: 2);
  static const Duration animationDuration = Duration(milliseconds: 300);

  // Validation
  static const int minPasswordLength = 6;

  // Messages
  static const String loginSuccess = "Login Successful";
  static const String registerSuccess = "Registration Successful";
  static const String resetPasswordMessage =
      "Password reset link sent successfully.";

  // Labels
  static const String currentLocation = "Current Location";
  static const String destination = "Destination";

  // Default Values
  static const String defaultBuilding = "Academic Block A";
  static const String defaultFloor = "Ground Floor";
}
