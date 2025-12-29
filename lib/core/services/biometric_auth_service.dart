import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'session_service.dart';

/// Service for biometric authentication (Face ID / Fingerprint)
class BiometricAuthService {
  final LocalAuthentication _localAuth;
  final FlutterSecureStorage _secureStorage;

  static const String _biometricEnabledKey = 'biometric_enabled';

  BiometricAuthService({
    LocalAuthentication? localAuth,
    FlutterSecureStorage? secureStorage,
  })  : _localAuth = localAuth ?? LocalAuthentication(),
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Check if the device supports biometrics
  Future<bool> isDeviceSupported() async {
    return await _localAuth.isDeviceSupported();
  }

  /// Check if biometrics are available and enrolled
  Future<bool> canAuthenticate() async {
    try {
      final isSupported = await _localAuth.isDeviceSupported();
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      return isSupported && canCheckBiometrics;
    } catch (e) {
      return false;
    }
  }

  /// Get list of available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException {
      return [];
    }
  }

  /// Check if user has enabled biometric login in settings
  Future<bool> isBiometricEnabled() async {
    final value = await _secureStorage.read(key: _biometricEnabledKey);
    return value == 'true';
  }

  /// Enable or disable biometric login
  Future<void> setBiometricEnabled(bool enabled) async {
    await _secureStorage.write(
      key: _biometricEnabledKey,
      value: enabled ? 'true' : 'false',
    );
  }

  /// Authenticate using biometrics
  /// Returns true if authentication successful
  Future<bool> authenticate({
    String reason = 'Authenticate to continue',
  }) async {
    final sessionService = SessionService();
    
    // CRITICAL: Set flag IMMEDIATELY - BEFORE any async code
    // Android resumes BEFORE await completes, so flag must be set first
    sessionService.setBiometricAuthInProgress(true);
    
    bool result = false;
    
    try {
      final isSupported = await _localAuth.isDeviceSupported();
      final canCheck = await _localAuth.canCheckBiometrics;
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      
      debugPrint('Biometric check: supported=$isSupported, canCheck=$canCheck, available=$availableBiometrics');
      
      if (!isSupported || !canCheck || availableBiometrics.isEmpty) {
        debugPrint('Biometric not available');
        // Clear immediately if we're not showing biometric dialog
        sessionService.setBiometricAuthInProgress(false);
        return false;
      }

      result = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: false,
          biometricOnly: true,
          useErrorDialogs: true,
        ),
      );
      
      debugPrint('Biometric auth result: $result');
    } on PlatformException catch (e) {
      debugPrint('Biometric PlatformException: ${e.code} - ${e.message}');
      result = false;
    } catch (e) {
      debugPrint('Biometric error: $e');
      result = false;
    }
    
    // CRITICAL: Clear with delay - Android resume fires BEFORE await completes
    // This 600ms delay ensures flag is still true when didChangeAppLifecycleState(resumed) runs
    Future.delayed(const Duration(milliseconds: 600), () {
      sessionService.setBiometricAuthInProgress(false);
    });
    
    return result;
  }

  /// Cancel ongoing authentication
  Future<void> cancelAuthentication() async {
    await _localAuth.stopAuthentication();
  }

  /// Get a human-readable name for the primary biometric type
  Future<String> getBiometricTypeName() async {
    final types = await getAvailableBiometrics();
    if (types.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (types.contains(BiometricType.fingerprint)) {
      return 'Fingerprint';
    } else if (types.contains(BiometricType.iris)) {
      return 'Iris';
    } else if (types.isNotEmpty) {
      return 'Biometric';
    }
    return 'Biometric';
  }
}
