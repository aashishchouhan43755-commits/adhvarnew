class UserResponse {
  final int id;
  final String name;
  final String email;
  final bool isActive;

  const UserResponse({
    required this.id,
    required this.name,
    required this.email,
    required this.isActive,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      id: json["id"] as int,
      // FastAPI returns "full_name"
      name: json["full_name"] as String,
      email: json["email"] as String,
      isActive: json["is_active"] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "full_name": name,
      "email": email,
      "is_active": isActive,
    };
  }
}