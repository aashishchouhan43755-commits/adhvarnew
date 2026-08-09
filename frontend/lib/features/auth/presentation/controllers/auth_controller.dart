import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';

class AuthController {
  AuthController(this.ref);

  final Ref ref;

  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> registerFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> forgotPasswordFormKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController forgotEmailController = TextEditingController();

  Future<void> login() async {
    if (!(loginFormKey.currentState?.validate() ?? false)) {
      return;
    }

    await ref
        .read(authProvider.notifier)
        .login(
          email: emailController.text.trim(),
          password: passwordController.text,
        );
  }

  Future<void> register() async {
    if (!(registerFormKey.currentState?.validate() ?? false)) {
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      throw Exception('Passwords do not match');
    }

    await ref
        .read(authProvider.notifier)
        .register(
          name: nameController.text.trim(),
          email: emailController.text.trim(),
          password: passwordController.text,
        );
  }

  /// TODO: Implement when backend forgot-password API is available.
  Future<void> forgotPassword() async {
    if (!(forgotPasswordFormKey.currentState?.validate() ?? false)) {
      return;
    }

    throw UnimplementedError('Forgot Password is not implemented yet.');
  }

  Future<void> logout() async {
    await ref.read(authProvider.notifier).logout();
  }

  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    forgotEmailController.dispose();
  }
}

final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(ref);
});
