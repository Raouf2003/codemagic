import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../../l10n/l10n.dart';
import '../../services/face_service.dart';

class FaceEnrollmentScreen extends StatefulWidget {
  final String employeeName;
  const FaceEnrollmentScreen({super.key, required this.employeeName});

  @override
  State<FaceEnrollmentScreen> createState() => _FaceEnrollmentScreenState();
}

enum _Stage { init, preview, capturing, processing, noFace, success }

class _FaceEnrollmentScreenState extends State<FaceEnrollmentScreen>
    with TickerProviderStateMixin {
  CameraController? _camCtrl;
  _Stage _stage = _Stage.init;
  final List<List<double>> _descriptors = [];
  String _errorMessage = '';

  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _initCamera();
    FaceService.instance.initialize();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_errorMessage.isEmpty) {
      _errorMessage = AppLocalizations.of(context).noFaceDetected;
    }
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
      setState(() => _stage = _Stage.preview);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context).cameraError}: $e'), backgroundColor: Colors.red),
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _capture() async {
    if (_stage != _Stage.preview || _camCtrl == null) return;
    setState(() => _stage = _Stage.capturing);

    try {
      final file = await _camCtrl!.takePicture();
      setState(() => _stage = _Stage.processing);

      final result = await FaceService.instance.extractDescriptorFromFile(file);

      if (!mounted) return;

      if (result == null || result is String) {
        _errorMessage = (result is String) ? result : 'Unknown error';
        setState(() => _stage = _Stage.noFace);
      } else {
        _descriptors.add(result as List<double>);
        if (_descriptors.length >= 3) {
          setState(() => _stage = _Stage.success);
        } else {
          await Future.delayed(const Duration(milliseconds: 400));
          if (mounted) {
            setState(() => _stage = _Stage.preview);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        _errorMessage = e.toString();
        setState(() => _stage = _Stage.noFace);
      }
    }
  }

  void _retry() => setState(() {
        _stage = _Stage.preview;
      });

  void _confirm() => Navigator.pop(context, _descriptors);

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _camCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_camCtrl != null && _camCtrl!.value.isInitialized)
            CameraPreview(_camCtrl!),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xBB000000), Colors.transparent, Color(0xDD000000)],
                stops: [0.0, 0.45, 1.0],
              ),
            ),
          ),
          if (_stage == _Stage.preview || _stage == _Stage.capturing)
            Center(
              child: AnimatedBuilder(
                animation: _pulseAnim,
                builder: (_, __) => Transform.scale(
                  scale: _pulseAnim.value,
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${_descriptors.length}/3',
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Icon(Icons.face_retouching_natural,
                      size: 32, color: Colors.white70),
                  const SizedBox(height: 8),
                  Text(
                    l10n.faceEnrollment,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.employeeName,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 14,
                    ),
                  ),
                  if (_stage == _Stage.preview && _descriptors.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        'Sample ${_descriptors.length + 1} of 3 — slightly adjust your position',
                        style: TextStyle(
                          color: Colors.amber.withValues(alpha: 0.8),
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: _buildBottomPanel(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPanel() {
    final l10n = AppLocalizations.of(context);
    switch (_stage) {
      case _Stage.init:
        return _StatusChip(
          icon: Icons.sync,
          label: l10n.startingCamera,
          color: Colors.white60,
        );

      case _Stage.preview:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StatusChip(
              icon: Icons.face,
              label: l10n.positionFaceInsideOval,
              color: Colors.white70,
            ),
            const SizedBox(height: 24),
            _CaptureButton(onTap: _capture),
          ],
        );

      case _Stage.capturing:
      case _Stage.processing:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 44,
              height: 44,
              child: CircularProgressIndicator(
                  strokeWidth: 3, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              _stage == _Stage.capturing
                  ? l10n.capturing
                  : l10n.extractingFaceData,
              style:
                  const TextStyle(color: Colors.white70, fontSize: 15),
            ),
          ],
        );

      case _Stage.noFace:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StatusChip(
              icon: Icons.warning_amber_rounded,
              label: _errorMessage,
              color: const Color(0xFFFFB74D),
            ),
            const SizedBox(height: 20),
            FilledButton.tonalIcon(
              onPressed: _retry,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.tryAgain),
              style: FilledButton.styleFrom(
                minimumSize: const Size(200, 50),
                backgroundColor: Colors.white24,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );

      case _Stage.success:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green.withValues(alpha: 0.2),
                border: Border.all(color: Colors.green, width: 2),
              ),
              child: const Icon(Icons.check_rounded,
                  color: Colors.green, size: 40),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.faceCaptured,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '3 samples captured (${_descriptors.length} total)',
              style:
                  TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      _descriptors.clear();
                      setState(() => _stage = _Stage.preview);
                    },
                    icon: const Icon(Icons.refresh, size: 18),
                    label: Text(l10n.retakeAll),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white70,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: _confirm,
                    icon: const Icon(Icons.person_add_alt_1),
                    label: Text(l10n.confirmSave),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
    }
  }
}

class _StatusChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _StatusChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Flexible(
            child: Text(label,
                style: TextStyle(color: color, fontSize: 13),
                textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }
}

class _CaptureButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CaptureButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
            decoration:
                const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
