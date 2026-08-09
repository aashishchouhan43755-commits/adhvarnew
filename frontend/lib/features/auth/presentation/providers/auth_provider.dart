import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/user_response.dart';
import '../../data/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<UserResponse?>>(
      (ref) => AuthNotifier(ref.read(authRepositoryProvider)),
    );

class AuthNotifier extends StateNotifier<AsyncValue<UserResponse?>> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AsyncValue.data(null));

  // ── Login ─────────────────────────────────────────────────────────────────

  Future<void> login({required String email, required String password}) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.login(email: email, password: password);
      state = AsyncValue.data(user);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // ── Register ──────────────────────────────────────────────────────────────

  /// Returns the registered email so the UI can navigate to OTP screen.
  /// Does NOT set state to logged-in (user must verify first).
  Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final registeredEmail = await _repository.register(
        name: name,
        email: email,
        password: password,
      );
      state = const AsyncValue.data(null); // still unverified
      return registeredEmail;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return null;
    }
  }

  // ── OTP ───────────────────────────────────────────────────────────────────

  Future<void> verifyOtp({
    required String email,
    required String otp,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.verifyOtp(email: email, otp: otp);
      state = AsyncValue.data(user);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> resendOtp({required String email}) async {
    try {
      await _repository.resendOtp(email: email);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // ── Load current user ────────────────────────────────────────────────────

  Future<void> loadUser() async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.getCurrentUser();
      state = AsyncValue.data(user);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // ── Forgot password ──────────────────────────────────────────────────────

  Future<void> forgotPassword({required String email}) async {
    try {
      await _repository.forgotPassword(email: email);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    await _repository.logout();
    state = const AsyncValue.data(null);
  }
}
