import 'dart:convert';

// ===== Request =====
class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

// ===== Response login =====
class LoginResponse {
  final String token;
  final String userId;
  final String email;
  final String fullName;
  final List<String> roles;

  const LoginResponse({
    required this.token,
    required this.userId,
    required this.email,
    required this.fullName,
    required this.roles,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    token: json['token'] as String,
    userId: (json['userId'] ?? json['id'] ?? '').toString(),
    email: json['email'] as String,
    fullName: json['fullName'] as String,
    roles: List<String>.from(json['roles'] ?? []),
  );
}

// ===== Current user (stored locally) =====
class CurrentUser {
  final String id;
  final String email;
  final String fullName;
  final List<String> roles;
  final String? clientId;
  final String? organizationId;

  const CurrentUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.roles,
    this.clientId,
    this.organizationId,
  });

  factory CurrentUser.fromJson(Map<String, dynamic> json) => CurrentUser(
    id: json['id']?.toString() ?? '',
    email: json['email'] as String? ?? '',
    fullName: json['fullName'] as String? ?? '',
    roles: List<String>.from(json['roles'] ?? []),
    clientId: json['clientId']?.toString(),
    organizationId: json['organizationId']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'fullName': fullName,
    'roles': roles,
    'clientId': clientId,
    'organizationId': organizationId,
  };

  String toJsonString() => jsonEncode(toJson());

  factory CurrentUser.fromJsonString(String jsonString) =>
      CurrentUser.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
}
