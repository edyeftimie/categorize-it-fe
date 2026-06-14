import '../../domain/models/bank_connection.dart';
import '../../domain/repositories/i_bank_connection_repository.dart';
import 'mock_data.dart';

class MockBankConnectionRepository implements IBankConnectionRepository {
  final _connections = List<BankConnection>.from(MockData.bankConnections);

  @override
  Future<List<BankConnection>> getConnections() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_connections);
  }

  @override
  Future<String> initiateAuth({required String aspspId, required String redirectUri}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return 'https://mock-bank-auth.enablebanking.com/auth?aspsp=$aspspId';
  }

  @override
  Future<BankConnection> handleCallback(String authCode) async {
    await Future.delayed(const Duration(seconds: 1));
    return _connections.first;
  }

  @override
  Future<void> disconnect(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _connections.removeWhere((c) => c.id == id);
  }
}