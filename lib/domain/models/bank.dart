class Bank {
  final String name;
  final String country;
  final String? logo;
  final String? bic;

  const Bank({
    required this.name,
    required this.country,
    this.logo,
    this.bic,
  });

  factory Bank.fromJson(Map<String, dynamic> j) => Bank(
    name:    j['name'],
    country: j['country'],
    logo:    j['logo'],
    bic:     j['bic'],
  );
}