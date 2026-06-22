class Bank {
  final String name;
  final String country;

  const Bank({required this.name, required this.country});

  factory Bank.fromJson(Map<String, dynamic> j) => Bank(
    name:    j['name']    as String,
    country: j['country'] as String,
  );
}