import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  ConnectivityService._();

  static final Connectivity _connectivity = Connectivity();

  static StreamSubscription<List<ConnectivityResult>>? _subscription;

  static final StreamController<bool> _controller =
      StreamController<bool>.broadcast();

  static Stream<bool> get connectionStream => _controller.stream;

  static Future<bool> isConnected() async {
    final results = await _connectivity.checkConnectivity();
    return !results.contains(ConnectivityResult.none);
  }

  static void startListening() {
    _subscription ??= _connectivity.onConnectivityChanged.listen((results) {
      _controller.add(!results.contains(ConnectivityResult.none));
    });
  }

  static Future<void> stopListening() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  static Future<void> dispose() async {
    await stopListening();
    await _controller.close();
  }
}
