import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../services/api_service.dart' show ApiService, ApiException;
import '../../widgets/common/app_snackbar.dart';
import '../../l10n/l10n.dart';
import 'face_verification_screen.dart';

class CheckinScanScreen extends StatefulWidget {
  final String period;
  final double? lat;
  final double? lng;

  const CheckinScanScreen({
    super.key,
    required this.period,
    this.lat,
    this.lng,
  });

  @override
  State<CheckinScanScreen> createState() => _CheckinScanScreenState();
}

class _CheckinScanScreenState extends State<CheckinScanScreen> {
  final ApiService _api = ApiService();
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
  );

  bool _isProcessing = false;
  String? _errorMsg;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _onQrDetected(String? raw) {
    if (_isProcessing || raw == null || !mounted) return;
    _isProcessing = true;
    setState(() => _errorMsg = null);
    _verifyQrAndProceed(raw);
  }

  Future<void> _verifyQrAndProceed(String token) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _errorMsg = null);

    try {
      await _api.post('/verify-qr', {
        'token': token,
        'lat': widget.lat,
        'lng': widget.lng,
      }, requiresAuth: true);

      if (!mounted) return;

      final success = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => FaceVerificationScreen(
            period: widget.period,
            lat: widget.lat,
            lng: widget.lng,
          ),
        ),
      );

      if (!mounted) return;

      if (success == true) {
        final label =
            widget.period == 'morning' ? l10n.morning : l10n.evening;
        showSuccess(context, '$label ${l10n.checkinSuccessful}');
        Navigator.pop(context, true);
      } else {
        setState(() {
          _isProcessing = false;
          _errorMsg = l10n.checkinCancelled;
        });
      }
    } catch (e) {
      if (!mounted) return;
      String msg;
      if (e is ApiException && e.statusCode == 0) {
        msg = l10n.noInternetConnection;
      } else {
        msg = e.toString().replaceFirst('Exception: ', '');
        if (msg.contains('expired') || msg.contains('Invalid')) {
          msg = l10n.qrInvalidOrExpired;
        }
      }
      setState(() {
        _isProcessing = false;
        _errorMsg = msg;
      });
    }
  }

  void _retry() => setState(() {
        _isProcessing = false;
        _errorMsg = null;
      });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.qrCheckinStep2)),
      body: Column(
        children: [
          Expanded(
            child: _isProcessing
                ? Container(
                    color: Colors.black,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(color: Colors.white),
                          const SizedBox(height: 16),
                          Text(l10n.validatingQR,
                              style: const TextStyle(color: Colors.white70)),
                        ],
                      ),
                    ),
                  )
                : MobileScanner(
                    controller: _scannerController,
                    onDetect: (capture) {
                      if (capture.barcodes.isEmpty) return;
                      final raw = capture.barcodes.first.rawValue;
                      if (raw != null) _onQrDetected(raw);
                    },
                  ),
          ),

          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _StepDot(active: true, done: true, label: l10n.step1Loc, icon: Icons.location_on),
                    const SizedBox(width: 6),
                    Container(width: 24, height: 2, color: colorScheme.primary),
                    const SizedBox(width: 6),
                    _StepDot(active: true, done: false, label: l10n.step2QR, icon: Icons.qr_code),
                    const SizedBox(width: 6),
                    Container(width: 24, height: 2, color: colorScheme.outlineVariant),
                    const SizedBox(width: 6),
                    _StepDot(active: false, done: false, label: l10n.step3Face, icon: Icons.face),
                  ],
                ),
                const SizedBox(height: 16),
                Icon(Icons.qr_code_scanner,
                    size: 36, color: colorScheme.primary),
                const SizedBox(height: 8),
                Text(
                  l10n.scanAdminQR,
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.locVerified,
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13),
                ),

                if (_errorMsg != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.red.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.red, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _errorMsg!,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  FilledButton.tonalIcon(
                    onPressed: _retry,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: Text(l10n.scanAgain),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  final bool active;
  final bool done;
  final String label;
  final IconData icon;

  const _StepDot({
    required this.active,
    required this.done,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final Color bgColor;
    final Color fgColor;
    final IconData displayIcon;

    if (done) {
      bgColor = Colors.green;
      fgColor = Colors.white;
      displayIcon = Icons.check;
    } else if (active) {
      bgColor = cs.primary;
      fgColor = cs.onPrimary;
      displayIcon = icon;
    } else {
      bgColor = cs.surfaceVariant;
      fgColor = cs.onSurfaceVariant;
      displayIcon = icon;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: bgColor,
          ),
          child: Icon(displayIcon, size: 16, color: fgColor),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(
                fontSize: 10,
                fontWeight: done ? FontWeight.bold : FontWeight.normal,
                color: done ? Colors.green : (active ? cs.primary : cs.onSurfaceVariant))),
      ],
    );
  }
}
