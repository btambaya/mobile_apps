import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../../features/auth/data/datasources/cognito_auth_datasource.dart';
import 'device_service.dart';

/// Service for managing app PIN (4-6 digit passcode)
/// PIN is stored securely locally AND synced to Cognito for cross-device access
class PinService {
  // Singleton instance
  static final PinService _instance = PinService._internal();
  factory PinService() => _instance;
  PinService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final CognitoAuthDatasource _cognitoDatasource = CognitoAuthDatasource();
  static const String _pinKey = 'app_pin_hash';
  static const String _pinEnabledKey = 'pin_enabled';

  /// Check if PIN is set up
  Future<bool> isPinEnabled() async {
    final enabled = await _secureStorage.read(key: _pinEnabledKey);
    return enabled == 'true';
  }

  /// Set up new PIN (hashed for security)
  /// Saves to both local storage AND Cognito for cross-device sync
  /// Also logs out all other devices to force re-auth with new passcode
  Future<void> setPin(String pin) async {
    if (pin.length < 4 || pin.length > 6) {
      throw Exception('PIN must be 4-6 digits');
    }
    
    final hash = _hashPin(pin);
    
    // Save locally
    await _secureStorage.write(key: _pinKey, value: hash);
    await _secureStorage.write(key: _pinEnabledKey, value: 'true');
    
    // Sync to Cognito (async, don't block if it fails)
    try {
      await _cognitoDatasource.savePasscodeHash(hash);
    } catch (e) {
      debugPrint('Failed to sync passcode to Cognito: $e');
    }
    
    // Logout all other devices to force re-auth with new passcode
    try {
      await DeviceService().logoutOtherDevices();
    } catch (e) {
      debugPrint('Failed to logout other devices: $e');
    }
  }

  /// Verify entered PIN matches stored PIN
  Future<bool> verifyPin(String enteredPin) async {
    final storedHash = await _secureStorage.read(key: _pinKey);
    if (storedHash == null) return false;
    
    final enteredHash = _hashPin(enteredPin);
    return storedHash == enteredHash;
  }

  /// Sync passcode from Cognito (call after login on new device)
  /// Returns true if passcode was synced from cloud
  Future<bool> syncFromCloud() async {
    try {
      final cloudHash = await _cognitoDatasource.getPasscodeHash();
      if (cloudHash != null && cloudHash.isNotEmpty) {
        // Store locally
        await _secureStorage.write(key: _pinKey, value: cloudHash);
        await _secureStorage.write(key: _pinEnabledKey, value: 'true');
        return true;
      }
    } catch (e) {
      debugPrint('Failed to sync passcode from Cognito: $e');
    }
    return false;
  }

  /// Remove PIN
  /// Clears from both local storage AND Cognito for cross-device sync
  Future<void> removePin() async {
    await _secureStorage.delete(key: _pinKey);
    await _secureStorage.write(key: _pinEnabledKey, value: 'false');
    
    // Sync removal to Cognito (clear the custom attribute)
    try {
      await _cognitoDatasource.savePasscodeHash('');
    } catch (e) {
      debugPrint('Failed to clear passcode from Cognito: $e');
    }
  }

  /// Hash PIN with SHA256 for secure storage
  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
