import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> isAvailable() async {
    if (kIsWeb) return false;
    try {
      return await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
    } catch (e) {
      return false;
    }
  }

  Future<String?> authenticate({String reason = 'Authenticate to check in/out'}) async {
    final available = await isAvailable();
    if (!available) return null;

    try {
      await _auth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
      return null;
    } catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
    }
  }

  Future<String?> enrollFingerprint() async {
    final available = await isAvailable();
    if (!available) return 'Biometric not available on this device';

    for (int i = 0; i < 3; i++) {
      final error = await authenticate(reason: 'Fingerprint scan ${i + 1} of 3 - place your finger');
      if (error != null) {
        return 'Scan ${i + 1} failed: $error';
      }
    }

    return null;
  }
}
