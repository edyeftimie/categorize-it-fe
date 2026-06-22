import '../models/bank.dart';
import '../models/bank_connection.dart';

class BankAuthResult {
  final String url;
  final String? state;
  const BankAuthResult({required this.url, this.state});
}

abstract interface class IBankConnectionRepository {
  /// GET /api/banks — list of available ASPSPs.
  Future<List<Bank>> getAvailableBanks();

  /// GET /api/bank-connections
  Future<List<BankConnection>> getConnections();

  /// POST /api/bank-connections/auth → { url, state }
  Future<BankAuthResult> initiateAuth({
    required String aspspName,
    required String aspspCountry,
  });

  /// POST /api/bank-connections/callback → BankConnection
  Future<BankConnection> handleCallback(String code);

  /// DELETE /api/bank-connections/{id}
  Future<void> disconnect(String id);
}