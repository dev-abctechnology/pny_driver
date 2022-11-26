class AuthUser {
  final String id;
  final String name;
  final String email;
  final String token;

  AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.token,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      token: json['token'],
    );
  }
}
