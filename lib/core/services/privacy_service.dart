import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrivacyService {
  static final PrivacyService instance = PrivacyService._init();
  final LocalAuthentication _auth = LocalAuthentication();

  static const _prefKey = 'app_privacy_lock_enabled';

  PrivacyService._init();

  Future<bool> isLockEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_prefKey) ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> setLockEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKey, enabled);
    } catch (e) {
      debugPrint('Error setting lock enabled: $e');
    }
  }

  Future<bool> canAuthenticateWithBiometrics() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      return canCheck && isSupported;
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason:
            'Confirma tu identidad para acceder a tus chats y estadísticas.',
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );
    } catch (e) {
      debugPrint('Error during authentication: $e');
      return false;
    }
  }
}
