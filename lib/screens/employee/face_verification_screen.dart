import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/face_service.dart';
import '../../l10n/l10n.dart';

class FaceVerificationScreen extends StatefulWidget {
  final String period;
  final double? lat;
  final double? lng;
  final String mode;

  const FaceVerificationScreen({
    super.key,
    required this.period,
    this.lat,
    this.lng,
    this.mode = 'checkin',
  });

  @override
  State<FaceVerificationScreen> createState() => _FaceVerificationScreenState();
}

enum _VStage {
  init,
  ready,
  capturing,
  processing,
  faceMismatch,
  faceNotEnrolled,
  genericError,
  success,
}

class _FaceVerificationScreenState extends State<FaceVerificationScreen>
    with TickerProviderStateMixin {
  final ApiService _api = ApiService();

  CameraController? _camCtrl;
  _VStage _stage = _VStage.init;
  String _errorMessage = '';

  late final AnimationController _ringCtrl;
  late final Animation<double> _ringAnim;

  @override
  void initState() {
    super.initState();

    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _ringAnim = Tween<double>(begin: 0.90, end: 1.02).animate(
      CurvedAnimation(parent: _ringCtrl, curve: Curves.easeInOut),
    );

    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      final front = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      final ctrl = CameraController(
        front,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await ctrl.initialize();
      if (!mounted) return;
      _camCtrl = ctrl;
      await FaceService.instance.initialize();
      if (!mounted) return;
      setState(() => _stage = _VStage.ready);
    } catch (e) {
      if (mounted) {
        setState(() {
          _stage = _VStage.genericError;
          final l = AppLocalizations.of(context);
          _errorMessage = '${l.cameraError}: $e';
        });
      }
    }
  }

  Future<void> _captureAndVerify() async {
    final l10n = AppLocalizations.of(context);
    if (_camCtrl == null || !_camCtrl!.value.isInitialized) return;
    setState(() => _stage = _VStage.capturing);

    try {
      final file = await _camCtrl!.takePicture();
      setState(() => _stage = _VStage.processing);

      final descriptor =
          await FaceService.instance.extractDescriptorFromFile(file);

      if (!mounted) return;

      if (descriptor == null || descriptor is String) {
        setState(() {
          _stage = _VStage.genericError;
          _errorMessage = descriptor is String
              ? descriptor
              : l10n.noFaceDetected;
        });
        return;
      }

      final endpoint = widget.mode == 'checkout' ? '/verify-face' : '/verify-checkin';
      final body = widget.mode == 'checkout'
          ? {'faceDescriptor': descriptor}
          : {
              'faceDescriptor': descriptor,
              'period': widget.period,
              'lat': widget.lat,
              'lng': widget.lng,
            };
      final response = await _api.post(endpoint, body, requiresAuth: true);

      if (!mounted) return;

      if (response['faceVerified'] == true) {
        setState(() => _stage = _VStage.success);
        await Future.delayed(const Duration(milliseconds: 1200));
        if (mounted) Navigator.pop(context, true);
      } else {
        setState(() {
          _stage = _VStage.genericError;
          _errorMessage = response['message'] ?? l10n.verificationFailed;
        });
      }
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '');

      if (widget.mode == 'checkin' && (msg.contains('expired') || msg.contains('invalid_qr'))) {
        Navigator.pop(context, false);
        return;
      }

      if (msg.contains('Face does not match') || msg.contains('face_mismatch')) {
        setState(() => _stage = _VStage.faceMismatch);
      } else if (msg.contains('face_not_enrolled') ||
          msg.contains('Face not enrolled')) {
        setState(() => _stage = _VStage.faceNotEnrolled);
      } else if ((msg.contains('SocketException') ||
          msg.contains('HandshakeException') ||
          msg.contains('Connection refused') ||
          msg.contains('Failed host lookup') ||
          msg.contains('timed out') ||
          msg.contains('No address associated') ||
          msg.contains('Network is unreachable'))) {
        if (!mounted) return;
        setState(() {
          _stage = _VStage.genericError;
          _errorMessage = '${l10n.networkError}: ${l10n.faceVerificationUnavailable}';
        });
      } else {
        setState(() {
          _stage = _VStage.genericError;
          _errorMessage = msg;
        });
      }
    }
  }

  void _retry() {
    setState(() {
      _stage = _VStage.ready;
    });
  }

  @override
  void dispose() {
    _ringCtrl.dispose();
    _camCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isTerminal = _stage == _VStage.faceMismatch ||
        _stage == _VStage.faceNotEnrolled ||
        _stage == _VStage.success;

    return PopScope(
      canPop: isTerminal ||
          _stage == _VStage.genericError ||
          _stage == _VStage.init,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            if (_camCtrl != null &&
                _camCtrl!.value.isInitialized &&
                (_stage == _VStage.ready ||
                    _stage == _VStage.capturing ||
                    _stage == _VStage.processing))
              CameraPreview(_camCtrl!),

            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xCC000000),
                    Colors.transparent,
                    Color(0xEE000000),
                  ],
                  stops: [0.0, 0.4, 1.0],
                ),
              ),
            ),

            if (_stage == _VStage.ready || _stage == _VStage.capturing)
              Center(
                child: AnimatedBuilder(
                  animation: _ringAnim,
                  builder: (_, __) => Transform.scale(
                    scale: _ringAnim.value,
                    child: Container(
                      width: 300,
                      height: 380,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.85),
                          width: 2.5,
                        ),
                        borderRadius: BorderRadius.circular(120),
                      ),
                    ),
                  ),
                ),
              ),

            SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.face_unlock_outlined,
                        size: 30, color: Colors.white70),
                    const SizedBox(height: 6),
                    Text(
                      widget.mode == 'checkout' ? l10n.faceVerificationCheckout : l10n.faceVerification,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _headerSubtitle(),
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.65),
                          fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 36),
                  child: _buildBottomPanel(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _headerSubtitle() {
    final l10n = AppLocalizations.of(context);
    switch (_stage) {
      case _VStage.init:
        return l10n.initialisingCamera;
      case _VStage.ready:
        return l10n.lookAtCamera;
      case _VStage.capturing:
        return l10n.holdStill;
      case _VStage.processing:
        return l10n.verifyingIdentity;
      case _VStage.faceMismatch:
        return l10n.verificationFailed;
      case _VStage.faceNotEnrolled:
        return l10n.faceNotRegistered;
      case _VStage.genericError:
        return l10n.verificationError;
      case _VStage.success:
        return l10n.identityConfirmed;
    }
  }

  Widget _buildBottomPanel() {
    final l10n = AppLocalizations.of(context);
    switch (_stage) {
      case _VStage.init:
      case _VStage.capturing:
      case _VStage.processing:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
                width: 44,
                height: 44,
                child:
                    CircularProgressIndicator(strokeWidth: 3, color: Colors.white)),
            const SizedBox(height: 14),
            Text(
              _stage == _VStage.processing
                  ? l10n.comparingFace
                  : _stage == _VStage.capturing
                      ? l10n.capturingFace
                      : l10n.startCamera,
              style:
                  const TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        );

      case _VStage.ready:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: _captureAndVerify,
              child: Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  color: Colors.white10,
                ),
                child: Center(
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.tapToCapture,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );

      case _VStage.faceMismatch:
        return _ErrorPanel(
          icon: Icons.no_accounts_rounded,
          iconColor: Colors.redAccent,
          title: l10n.faceDoesNotMatch,
          subtitle: l10n.lookDirectlyAtCamera,
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Colors.white30),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(l10n.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: _retry,
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.tryAgain),
                    style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14)),
                  ),
                ),
              ],
            ),
          ],
        );

      case _VStage.faceNotEnrolled:
        return _ErrorPanel(
          icon: Icons.person_off_rounded,
          iconColor: Colors.orange,
          title: l10n.faceNotRegistered,
          subtitle: l10n.notEnrolledContactAdmin,
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context, false),
              style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50)),
              child: Text(l10n.goBack),
            ),
          ],
        );

      case _VStage.genericError:
        return _ErrorPanel(
          icon: Icons.warning_amber_rounded,
          iconColor: Colors.amber,
          title: l10n.verificationFailed,
          subtitle: _errorMessage,
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Colors.white30),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(l10n.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: _retry,
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.tryAgain),
                    style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14)),
                  ),
                ),
              ],
            ),
          ],
        );

      case _VStage.success:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green.withValues(alpha: 0.15),
                border: Border.all(color: Colors.green, width: 2.5),
              ),
              child:
                  const Icon(Icons.check_rounded, color: Colors.green, size: 44),
            ),
            const SizedBox(height: 16),
            Text(
              widget.mode == 'checkout' ? l10n.checkoutSuccessful : l10n.checkinSuccessful,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
          ],
        );
    }
  }
}

class _ErrorPanel extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final List<Widget> actions;

  const _ErrorPanel({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 48),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.65), fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ...actions,
        ],
      ),
    );
  }
}
