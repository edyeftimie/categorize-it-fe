class BankAccount {
  final String id;
  final String uid;
  final String? iban;
  final String? name;
  final String currency;
  final String? cashAccountType;
  final DateTime? lastSyncedAt;

  const BankAccount({
    required this.id,
    required this.uid,
    this.iban,
    this.name,
    required this.currency,
    this.cashAccountType,
    this.lastSyncedAt,
  });

  // Shows masked IBAN when available, falls back to name or a placeholder.
  String get maskedIban {
    if (iban != null && iban!.length >= 8) {
      return '${iban!.substring(0, 8)} •••• ${iban!.substring(iban!.length - 4)}';
    }
    if (iban != null && iban!.isNotEmpty) return iban!;
    return name ?? '••••';
  }

  factory BankAccount.fromJson(Map<String, dynamic> j) => BankAccount(
    id:              j['id'],
    uid:             j['uid'],
    iban:            j['iban'],
    name:            j['name'],
    currency:        j['currency'],
    cashAccountType: j['cashAccountType'],
    lastSyncedAt:    j['lastSyncedAt'] != null ? DateTime.parse(j['lastSyncedAt']) : null,
  );
}

class BankConnection {
  final String id;
  final String aspspName;
  final String aspspCountry;
  final DateTime validUntil;
  final String status;
  final DateTime createdAt;
  final List<BankAccount> bankAccounts;

  const BankConnection({
    required this.id,
    required this.aspspName,
    required this.aspspCountry,
    required this.validUntil,
    required this.status,
    required this.createdAt,
    required this.bankAccounts,
  });

  bool get isActive  => status == 'AUTHORIZED';
  bool get isExpired => status == 'EXPIRED';

  factory BankConnection.fromJson(Map<String, dynamic> j) => BankConnection(
    id:           j['id'],
    aspspName:    j['aspspName'],
    aspspCountry: j['aspspCountry'],
    validUntil:   DateTime.parse(j['validUntil']),
    status:       j['status'],
    createdAt:    DateTime.parse(j['createdAt']),
    bankAccounts: (j['accounts'] as List? ?? [])
        .map((a) => BankAccount.fromJson(a as Map<String, dynamic>))
        .toList(),
  );
}