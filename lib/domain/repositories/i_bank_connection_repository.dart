import '../models/bank.dart';
import '../models/bank_connection.dart';

abstract interface class IBankConnectionRepository {
  Future<List<BankConnection>> getConnections();
  Future<List<Bank>> getAvailableBanks();
  Future<({String url, String state})> initiateAuth({
    required String aspspName,
    required String aspspCountry,
  });
  Future<BankConnection> handleCallback({required String code});
  Future<void> disconnect(String id);
}