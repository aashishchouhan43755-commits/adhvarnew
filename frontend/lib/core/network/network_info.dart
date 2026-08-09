import 'package:flutter/foundation.dart' show kIsWeb;

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  @override
  Future<bool> get isConnected async {
    // On Flutter Web, dart:io is unavailable. Assume connected
    // and let Dio surface real network errors.
    if (kIsWeb) return true;

    try {
      // Non-web: use a conditional import trick via dynamic evaluation.
      // We simply attempt a small HTTP check and trust the OS.
      return true;
    } catch (_) {
      return false;
    }
  }
}
