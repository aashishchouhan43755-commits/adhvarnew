import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/register_request.dart';
import '../models/user_response.dart';

class AuthRemoteDataSource {
  final Dio _dio = DioClient.dio;

  Future<LoginResponse> login(LoginRequest request) async {
    final response = await _dio.post(
      ApiConstants.login,
      data: request.toJson(),
    );

    return LoginResponse.fromJson(response.data);
  }

  Future<void> register(RegisterRequest request) async {
    await _dio.post(ApiConstants.register, data: request.toJson());
  }

  Future<UserResponse> getCurrentUser() async {
    final response = await _dio.get("/users/me");

    return UserResponse.fromJson(response.data);
  }

  Future<void> forgotPassword({required String email}) async {
    await _dio.post("/auth/forgot-password", data: {"email": email});
  }

  Future<LoginResponse> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final response = await _dio.post(
      ApiConstants.verifyOtp,
      data: {"email": email, "otp": otp},
    );
    return LoginResponse.fromJson(response.data);
  }

  Future<void> resendOtp({required String email}) async {
    await _dio.post(ApiConstants.resendOtp, data: {"email": email});
  }
}
