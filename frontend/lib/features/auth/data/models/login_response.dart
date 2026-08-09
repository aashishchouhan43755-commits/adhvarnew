class LoginResponse {
  final String accessToken;
  final String tokenType;

  const LoginResponse({required this.accessToken, required this.tokenType});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json["access_token"] as String,
      tokenType: json["token_type"] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {"access_token": accessToken, "token_type": tokenType};
  }
}
