import '../models/bank_connection.dart';

abstract interface class IBankConnectionRepository {
  Future<List<BankConnection>> getConnections();
  Future<String> initiateAuth({required String aspspId, required String redirectUri});
  Future<BankConnection> handleCallback(String authCode);
  Future<void> disconnect(String id);
}