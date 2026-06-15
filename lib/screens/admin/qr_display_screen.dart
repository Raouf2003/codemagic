import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../services/api_service.dart';
import '../../widgets/common/app_snackbar.dart';
import '../../l10n/l10n.dart';

class QrDisplayScreen extends StatefulWidget {
  const QrDisplayScreen({super.key});

  @override
  State<QrDisplayScreen> createState() => _QrDisplayScreenState();
}

class _QrDisplayScreenState extends State<QrDisplayScreen> {
  final ApiService _api = ApiService();
  String? _token;
  Timer? _timer;
  int _countdown = 30;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchToken();
  }

  Future<void> _fetchToken() async {
    setState(() => _isLoading = true);
    try {
      final response = await _api.get('/qr-token');
      if (!mounted) return;
      setState(() {
        _token = response['token'];
        _countdown = response['expiresIn'] ?? 30;
        _isLoading = false;
      });
      _startTimer();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      showError(context, AppLocalizations.of(context).failedToGenerateQR);
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _countdown = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_countdown <= 1) {
        _fetchToken();
        return;
      }
      setState(() => _countdown--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.qrCheckinCode)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.employeeCheckin,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.scanThisQR,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 32),
            if (_isLoading)
              const CircularProgressIndicator()
            else if (_token != null)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.15),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: QrImageView(
                  data: _token!,
                  version: QrVersions.auto,
                  size: 260,
                  eyeStyle: QrEyeStyle(
                    color: colorScheme.primary,
                  ),
                  dataModuleStyle: QrDataModuleStyle(
                    color: colorScheme.primary,
                  ),
                ),
              ),
            const SizedBox(height: 24),
            if (_token != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: _countdown <= 5
                      ? Colors.red.withValues(alpha: 0.1)
                      : colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _countdown <= 5 ? Icons.timer_off : Icons.timer,
                      size: 18,
                      color: _countdown <= 5 ? Colors.red : colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Refreshes in ${_countdown}s',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _countdown <= 5 ? Colors.red : colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 32),
            FilledButton.tonalIcon(
              onPressed: _isLoading ? null : _fetchToken,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.refreshNow),
            ),
          ],
        ),
      ),
    );
  }
}
