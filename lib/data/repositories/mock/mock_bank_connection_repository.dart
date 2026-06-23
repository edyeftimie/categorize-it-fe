import '../../../domain/models/bank.dart';
import '../../../domain/models/bank_connection.dart';
import '../../../domain/repositories/i_bank_connection_repository.dart';
import 'mock_data.dart';

class MockBankConnectionRepository implements IBankConnectionRepository {
  final _connections = List<BankConnection>.from(MockData.bankConnections);

  @override
  Future<List<Bank>> getAvailableBanks() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const [
      Bank(name: 'Banca Transilvania', country: 'RO'),
      Bank(name: 'ING Bank', country: 'RO'),
      Bank(name: 'BCR', country: 'RO'),
      Bank(name: 'BRD', country: 'RO'),
    ];
  }

  @override
  Future<List<BankConnection>> getConnections() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_connections);
  }

  @override
  Future<BankAuthResult> initiateAuth({
    required String aspspName,
    required String aspspCountry,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return BankAuthResult(
      url: 'https://mock-bank-auth.enablebanking.com/auth?aspsp=$aspspName',
    );
  }

  @override
  Future<BankConnection> handleCallback(String code) async {
    await Future.delayed(const Duration(seconds: 1));
    return _connections.first;
  }

  @override
  Future<void> disconnect(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _connections.removeWhere((c) => c.id == id);
  }
}