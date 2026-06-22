class User {
  final String id;
  final String email;
  final String? username;

  const User({required this.id, required this.email, this.username});

  factory User.fromJson(Map<String, dynamic> j) => User(
    id: j['userId'] as String,
    email: j['email'] as String,
    username: j['name'] as String?,
  );
}