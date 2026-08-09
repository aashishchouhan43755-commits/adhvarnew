import '../../data/models/auth_model.dart';

abstract class AuthRepository {
  /// Login user
  Future<AuthModel> login({required String email, required String password});

  /// Register new user
  Future<AuthModel> register({
    required String name,
    required String email,
    required String password,
  });

  /// Send password reset email
  Future<void> forgotPassword({required String email});

  /// Logout current user
  Future<void> logout();
}
