import 'package:categoriseit_fe/domain/models/bank.dart';
import 'package:categoriseit_fe/domain/models/bank_connection.dart';
import 'package:categoriseit_fe/domain/repositories/i_bank_connection_repository.dart';
import 'mock_data.dart';

class MockBankConnectionRepository implements IBankConnectionRepository {
  final _connections = List<BankConnection>.from(MockData.bankConnections);

  @override
  Future<List<BankConnection>> getConnections() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_connections);
  }

  @override
  Future<List<Bank>> getAvailableBanks() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      const Bank(name: 'Banca Transilvania', country: 'RO'),
      const Bank(name: 'ING Bank', country: 'RO'),
    ];
  }

  @override
  Future<({String url, String state})> initiateAuth({
    required String aspspName,
    required String aspspCountry,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return (
      url: 'https://mock-bank-auth.enablebanking.com/auth?aspsp=$aspspName',
      state: 'mock-state',
    );
  }

  @override
  Future<BankConnection> handleCallback({required String code}) async {
    await Future.delayed(const Duration(seconds: 1));
    return _connections.first;
  }

  @override
  Future<void> disconnect(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _connections.removeWhere((c) => c.id == id);
  }
}