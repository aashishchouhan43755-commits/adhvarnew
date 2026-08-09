import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  PermissionService._();

  /// Camera Permission
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  static Future<bool> hasCameraPermission() async {
    return await Permission.camera.isGranted;
  }

  /// Location Permission
  static Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  static Future<bool> hasLocationPermission() async {
    return await Permission.location.isGranted;
  }

  /// Storage Permission
  static Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  static Future<bool> hasStoragePermission() async {
    return await Permission.storage.isGranted;
  }

  /// Microphone Permission
  static Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  static Future<bool> hasMicrophonePermission() async {
    return await Permission.microphone.isGranted;
  }

  /// Notification Permission
  static Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  static Future<bool> hasNotificationPermission() async {
    return await Permission.notification.isGranted;
  }

  /// Open App Settings
  static Future<bool> openSettings() async {
    return await openAppSettings();
  }

  /// Check if permission is permanently denied
  static Future<bool> isLocationPermanentlyDenied() async {
    return await Permission.location.isPermanentlyDenied;
  }

  static Future<bool> isCameraPermanentlyDenied() async {
    return await Permission.camera.isPermanentlyDenied;
  }

  static Future<bool> isStoragePermanentlyDenied() async {
    return await Permission.storage.isPermanentlyDenied;
  }

  /// Request all commonly used permissions
  static Future<Map<Permission, PermissionStatus>>
  requestAllPermissions() async {
    return await [
      Permission.location,
      Permission.camera,
      Permission.storage,
      Permission.microphone,
      Permission.notification,
    ].request();
  }
}
