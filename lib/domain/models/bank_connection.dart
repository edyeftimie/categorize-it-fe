class BankAccount {
  final String id;
  // Not returned by the API (accounts are nested under their connection).
  // Populated client-side after parsing if needed.
  final String? bankConnectionId;
  final String uid;
  final String? iban;
  final String? name;
  final String currency;
  final DateTime? lastSyncedAt;

  const BankAccount({
    required this.id,
    this.bankConnectionId,
    required this.uid,
    this.iban,
    this.name,
    required this.currency,
    this.lastSyncedAt,
  });

  String get maskedIban {
    if (iban == null || iban!.length < 8) return iban ?? '';
    return '${iban!.substring(0, 8)} •••• ${iban!.substring(iban!.length - 4)}';
  }

  factory BankAccount.fromJson(Map<String, dynamic> j) => BankAccount(
    id:           j['id']       as String,
    uid:          j['uid']      as String,
    iban:         j['iban']     as String?,
    name:         j['name']     as String?,
    currency:     j['currency'] as String,
    lastSyncedAt: j['lastSyncedAt'] != null
        ? DateTime.parse(j['lastSyncedAt'] as String)
        : null,
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

  bool get isActive  => status == 'Active';
  bool get isExpired => status == 'Expired';

  factory BankConnection.fromJson(Map<String, dynamic> j) => BankConnection(
    id:           j['id']           as String,
    aspspName:    j['aspspName']    as String,
    aspspCountry: j['aspspCountry'] as String,
    validUntil:   DateTime.parse(j['validUntil'] as String),
    status:       j['status']       as String,
    createdAt:    DateTime.parse(j['createdAt']  as String),
    bankAccounts: (j['accounts'] as List? ?? [])  // API key is 'accounts', not 'bankAccounts'
        .map((a) => BankAccount.fromJson(a as Map<String, dynamic>))
        .toList(),
  );
}