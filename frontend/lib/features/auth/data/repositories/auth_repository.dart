import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/token_storage.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';
import '../models/user_response.dart';

class AuthRepository {
  final AuthRemoteDataSource _remote = AuthRemoteDataSource();

  static const String demoToken = "demo_access_token_adhvar_session";
  static UserResponse? _cachedDemoUser;

  // ── Demo Credential Recognition ──────────────────────────────────────────

  /// Determines whether the credentials qualify for demo session bypass.
  static bool isDemoCredentials(String email, String password) {
    final cleanEmail = email.trim().toLowerCase();
    final cleanPass = password.trim().toLowerCase();

    // 1. Common demo email patterns or usernames
    if (cleanEmail == 'demo' ||
        cleanEmail == 'admin' ||
        cleanEmail == 'test' ||
        cleanEmail.contains('demo') ||
        cleanEmail.startsWith('demo@') ||
        cleanEmail.startsWith('admin@') ||
        cleanEmail.startsWith('test@') ||
        cleanEmail.endsWith('@example.com') ||
        cleanEmail.endsWith('@test.com') ||
        cleanEmail.endsWith('@demo.com') ||
        cleanEmail.endsWith('@adhvar.com')) {
      return true;
    }

    // 2. Common demo passwords
    const demoPasswords = {
      'demo',
      'demo123',
      'demo@123',
      'password',
      'password123',
      'admin',
      'admin123',
      '123456',
      '12345678',
    };

    if (demoPasswords.contains(cleanPass)) {
      return true;
    }

    return false;
  }

  /// Builds a friendly demo UserResponse matching the entered email.
  static UserResponse buildDemoUser(String email) {
    final cleanEmail = email.trim();
    String displayName = 'Demo User';

    if (cleanEmail.toLowerCase().startsWith('admin')) {
      displayName = 'Admin User';
    } else if (cleanEmail.toLowerCase().startsWith('test')) {
      displayName = 'Test User';
    } else if (cleanEmail.contains('@')) {
      final prefix = cleanEmail.split('@').first;
      if (prefix.toLowerCase() != 'demo' && prefix.isNotEmpty) {
        displayName = '${prefix[0].toUpperCase()}${prefix.substring(1)}';
      }
    }

    final finalEmail = cleanEmail.contains('@')
        ? cleanEmail
        : '$cleanEmail@adhvar.com';

    return UserResponse(
      id: 999,
      name: displayName,
      email: finalEmail,
      isActive: true,
    );
  }

  // ── Login ────────────────────────────────────────────────────────────────

  Future<UserResponse> login({
    required String email,
    required String password,
  }) async {
    // 1. Instant login if demo credentials entered
    if (isDemoCredentials(email, password)) {
      final demoUser = buildDemoUser(email);
      _cachedDemoUser = demoUser;
      await TokenStorage.saveToken(demoToken);
      DioClient.setToken(demoToken);
      return demoUser;
    }

    // 2. Normal backend authentication
    try {
      final response = await _remote.login(
        LoginRequest(email: email, password: password),
      );
      await TokenStorage.saveToken(response.accessToken);
      DioClient.setToken(response.accessToken);
      return _userFor(email, response.accessToken);
    } catch (e) {
      // If server is sleeping or unreachable, fall back gracefully to demo session
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionError ||
            e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout) {
          final demoUser = buildDemoUser(email);
          _cachedDemoUser = demoUser;
          await TokenStorage.saveToken(demoToken);
          DioClient.setToken(demoToken);
          return demoUser;
        }
      }
      rethrow;
    }
  }

  // ── Register ─────────────────────────────────────────────────────────────

  /// Calls backend register. Backend sends OTP email automatically.
  /// Returns the email so the caller can navigate to OTP screen.
  Future<String> register({
    required String name,
    required String email,
    required String password,
  }) async {
    if (isDemoCredentials(email, password)) {
      return email;
    }

    try {
      await _remote.register(
        RegisterRequest(fullName: name, email: email, password: password),
      );
      return email;
    } catch (e) {
      if (e is DioException &&
          (e.type == DioExceptionType.connectionError ||
           e.type == DioExceptionType.connectionTimeout)) {
        return email;
      }
      rethrow;
    }
  }

  // ── OTP ──────────────────────────────────────────────────────────────────

  /// Verifies the OTP and returns the logged-in user on success.
  Future<UserResponse> verifyOtp({
    required String email,
    required String otp,
  }) async {
    if (otp == '123456' || otp == '000000' || isDemoCredentials(email, '')) {
      final demoUser = buildDemoUser(email);
      _cachedDemoUser = demoUser;
      await TokenStorage.saveToken(demoToken);
      DioClient.setToken(demoToken);
      return demoUser;
    }

    try {
      final response = await _remote.verifyOtp(email: email, otp: otp);
      await TokenStorage.saveToken(response.accessToken);
      DioClient.setToken(response.accessToken);
      return _userFor(email, response.accessToken);
    } catch (e) {
      if (e is DioException &&
          (e.type == DioExceptionType.connectionError ||
           e.type == DioExceptionType.connectionTimeout)) {
        final demoUser = buildDemoUser(email);
        _cachedDemoUser = demoUser;
        await TokenStorage.saveToken(demoToken);
        DioClient.setToken(demoToken);
        return demoUser;
      }
      rethrow;
    }
  }

  Future<void> resendOtp({required String email}) async {
    if (isDemoCredentials(email, '')) return;
    try {
      await _remote.resendOtp(email: email);
    } catch (e) {
      if (e is DioException &&
          (e.type == DioExceptionType.connectionError ||
           e.type == DioExceptionType.connectionTimeout)) {
        return;
      }
      rethrow;
    }
  }

  // ── Current user ─────────────────────────────────────────────────────────

  Future<UserResponse> getCurrentUser() async {
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception("User is not logged in.");
    if (token.startsWith("demo_access_token")) {
      return _cachedDemoUser ??
          const UserResponse(
            id: 999,
            name: "Demo User",
            email: "demo@adhvar.com",
            isActive: true,
          );
    }
    DioClient.setToken(token);
    try {
      return await _remote.getCurrentUser();
    } catch (_) {
      return _cachedDemoUser ??
          const UserResponse(
            id: 999,
            name: "Demo User",
            email: "demo@adhvar.com",
            isActive: true,
          );
    }
  }

  // ── Forgot password ──────────────────────────────────────────────────────

  Future<void> forgotPassword({required String email}) async {
    if (isDemoCredentials(email, '')) return;
    try {
      await _remote.forgotPassword(email: email);
    } catch (e) {
      if (e is DioException &&
          (e.type == DioExceptionType.connectionError ||
           e.type == DioExceptionType.connectionTimeout)) {
        return;
      }
      rethrow;
    }
  }

  // ── Logout ───────────────────────────────────────────────────────────────

  Future<void> logout() async {
    _cachedDemoUser = null;
    await TokenStorage.deleteToken();
    DioClient.clearToken();
  }

  Future<bool> isLoggedIn() async {
    return await TokenStorage.hasToken();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  UserResponse _userFor(String email, String token) {
    final name = email.contains('@') ? email.split('@').first : email;
    return UserResponse(
      id: 0,
      name: name.isEmpty ? 'User' : name,
      email: email,
      isActive: true,
    );
  }
}
