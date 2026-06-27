import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/providers.dart';

class BankConsentScreen extends ConsumerStatefulWidget {
  final String url;
  const BankConsentScreen({super.key, required this.url});

  @override
  ConsumerState<BankConsentScreen> createState() => _BankConsentScreenState();
}

class _BankConsentScreenState extends ConsumerState<BankConsentScreen> {
  late final WebViewController _controller;
  bool _pageLoading = true;
  bool _processing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) => setState(() => _pageLoading = true),
        onPageFinished: (_) => setState(() => _pageLoading = false),
        onNavigationRequest: (req) {
          if (req.url.startsWith('http://localhost:3000/bank-callback')) {
            _handleCallback(req.url);
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
        onWebResourceError: (e) {
          if (mounted) setState(() { _pageLoading = false; _error = e.description; });
        },
      ))
      ..loadRequest(Uri.parse(widget.url));
  }

  Future<void> _handleCallback(String callbackUrl) async {
    final uri = Uri.parse(callbackUrl);
    final code = uri.queryParameters['code'];
    if (code == null) {
      setState(() => _error = 'No authorisation code received from bank.');
      return;
    }
    setState(() => _processing = true);
    try {
      final bankRepo = ref.read(bankConnectionRepositoryProvider);
      final txRepo   = ref.read(transactionRepositoryProvider);
      await bankRepo.handleCallback(code: code);
      await txRepo.sync();
      ref.invalidate(bankConnectionsProvider);
      ref.invalidate(transactionsProvider);
      ref.invalidate(dashboardProvider);
      if (mounted) context.go('/account');
    } catch (e) {
      if (mounted) setState(() { _processing = false; _error = '$e'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: Colors.white,
        title: const Text('Connect Bank', style: TextStyle(fontSize: 16)),
        elevation: 0,
      ),
      body: Stack(
        children: [
          if (_error != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.emerald,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text('Go back', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            WebViewWidget(controller: _controller),
          if (_pageLoading || _processing)
            Container(
              color: _processing ? Colors.black54 : Colors.transparent,
              child: const Center(child: CircularProgressIndicator(color: AppColors.emerald)),
            ),
        ],
      ),
    );
  }
}