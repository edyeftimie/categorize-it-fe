import 'dart:async';
import 'package:categoriseit_fe/core/config/app_config.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

class ConnectivityService {
  Timer? _timer;
  bool _isConnected = false;
  final _controller = StreamController<bool>.broadcast();

  Stream<bool> get stream => _controller.stream;
  bool get isConnected => _isConnected;

  void startMonitoring() {
    _ping();
    _timer = Timer.periodic(ApiConstants.pingInterval, (_) => _ping());
  }

  Future<void> _ping() async {
    try {
      final response = await http
          .get(Uri.parse('${appBaseUrl}/api/health'))
          .timeout(ApiConstants.pingTimeout);
      _update(response.statusCode == 200);
    } catch (_) {
      _update(false);
    }
  }

  void _update(bool connected) {
    if (connected != _isConnected) {
      _isConnected = connected;
      _controller.add(_isConnected);
    }
  }

  void dispose() {
    _timer?.cancel();
    _controller.close();
  }
}