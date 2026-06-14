class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:5000'; // Android emulator → localhost

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration pingTimeout = Duration(seconds: 5);
  static const Duration pingInterval = Duration(seconds: 30);
}