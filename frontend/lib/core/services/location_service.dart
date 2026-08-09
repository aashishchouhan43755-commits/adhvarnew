import 'package:permission_handler/permission_handler.dart';

class AppLocation {
  final double latitude;
  final double longitude;

  const AppLocation({required this.latitude, required this.longitude});

  @override
  String toString() {
    return 'Latitude: $latitude, Longitude: $longitude';
  }
}

class LocationService {
  LocationService._();

  /// Checks whether location permission is granted.
  static Future<bool> hasPermission() async {
    return Permission.location.isGranted;
  }

  /// Requests location permission.
  static Future<bool> requestPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  /// Returns a mock location.
  ///
  /// Replace this implementation with the `geolocator`
  /// package when GPS integration is added.
  static Future<AppLocation> getCurrentLocation() async {
    final granted = await hasPermission() || await requestPermission();

    if (!granted) {
      throw Exception('Location permission denied.');
    }

    // Mock location (PIET Jaipur)
    return const AppLocation(latitude: 26.8497, longitude: 75.8161);
  }

  /// Opens application settings.
  static Future<bool> openSettings() async {
    return openAppSettings();
  }
}
