class User {
  final String id;
  final String email;
  final String? username;
  final String role;

  const User({required this.id, required this.email, this.username, required this.role});

  factory User.fromJson(Map<String, dynamic> j) => User(
    id: j['id'], email: j['email'], username: j['username'], role: j['role'],
  );
}