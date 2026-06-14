class BankAccount {
  final String id;
  final String bankConnectionId;
  final String uid;
  final String? iban;
  final String? name;
  final String currency;
  final DateTime? lastSyncedAt;

  const BankAccount({
    required this.id, required this.bankConnectionId, required this.uid,
    this.iban, this.name, required this.currency, this.lastSyncedAt,
  });

  String get maskedIban {
    if (iban == null || iban!.length < 8) return iban ?? '';
    return '${iban!.substring(0, 8)} •••• ${iban!.substring(iban!.length - 4)}';
  }

  factory BankAccount.fromJson(Map<String, dynamic> j) => BankAccount(
    id: j['id'], bankConnectionId: j['bankConnectionId'], uid: j['uid'],
    iban: j['iban'], name: j['name'], currency: j['currency'],
    lastSyncedAt: j['lastSyncedAt'] != null ? DateTime.parse(j['lastSyncedAt']) : null,
  );
}

class BankConnection {
  final String id;
  final String userId;
  final String aspspName;
  final String aspspCountry;
  final DateTime validUntil;
  final String status;
  final DateTime createdAt;
  final List<BankAccount> bankAccounts;

  const BankConnection({
    required this.id, required this.userId, required this.aspspName,
    required this.aspspCountry, required this.validUntil, required this.status,
    required this.createdAt, required this.bankAccounts,
  });

  bool get isActive  => status == 'Active';
  bool get isExpired => status == 'Expired';

  factory BankConnection.fromJson(Map<String, dynamic> j) => BankConnection(
    id: j['id'], userId: j['userId'], aspspName: j['aspspName'],
    aspspCountry: j['aspspCountry'], validUntil: DateTime.parse(j['validUntil']),
    status: j['status'], createdAt: DateTime.parse(j['createdAt']),
    bankAccounts: (j['bankAccounts'] as List? ?? [])
        .map((a) => BankAccount.fromJson(a as Map<String, dynamic>))
        .toList(),
  );
}