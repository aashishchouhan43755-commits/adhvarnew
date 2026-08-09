import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/token_storage.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';
import '../models/user_response.dart';

class AuthRepository {
  final AuthRemoteDataSource _remote = AuthRemoteDataSource();

  // ── Login ────────────────────────────────────────────────────────────────

  Future<UserResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _remote.login(
      LoginRequest(email: email, password: password),
    );
    await TokenStorage.saveToken(response.accessToken);
    DioClient.setToken(response.accessToken);
    return _userFor(email, response.accessToken);
  }

  // ── Register ─────────────────────────────────────────────────────────────

  /// Calls backend register. Backend sends OTP email automatically.
  /// Returns the email so the caller can navigate to OTP screen.
  Future<String> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await _remote.register(
      RegisterRequest(fullName: name, email: email, password: password),
    );
    return email;
  }

  // ── OTP ──────────────────────────────────────────────────────────────────

  /// Verifies the OTP and returns the logged-in user on success.
  Future<UserResponse> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final response = await _remote.verifyOtp(email: email, otp: otp);
    await TokenStorage.saveToken(response.accessToken);
    DioClient.setToken(response.accessToken);
    return _userFor(email, response.accessToken);
  }

  Future<void> resendOtp({required String email}) async {
    await _remote.resendOtp(email: email);
  }

  // ── Current user ─────────────────────────────────────────────────────────

  Future<UserResponse> getCurrentUser() async {
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception("User is not logged in.");
    DioClient.setToken(token);
    return await _remote.getCurrentUser();
  }

  // ── Forgot password ──────────────────────────────────────────────────────

  Future<void> forgotPassword({required String email}) async {
    await _remote.forgotPassword(email: email);
  }

  // ── Logout ───────────────────────────────────────────────────────────────

  Future<void> logout() async {
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
