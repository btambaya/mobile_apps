import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'api_service.dart';

/// Service for managing device registration and limits
class DeviceService {
  final ApiService _apiService = ApiService();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// Get unique device identifier
  Future<String> getDeviceId() async {
    if (Platform.isIOS) {
      final ios = await _deviceInfo.iosInfo;
      return ios.identifierForVendor ?? 'unknown-ios';
    } else if (Platform.isAndroid) {
      final android = await _deviceInfo.androidInfo;
      return android.id;
    }
    return 'unknown-device';
  }

  /// Get human-readable device name
  Future<String> getDeviceName() async {
    if (Platform.isIOS) {
      final ios = await _deviceInfo.iosInfo;
      return _formatIOSDeviceName(ios.utsname.machine);
    } else if (Platform.isAndroid) {
      final android = await _deviceInfo.androidInfo;
      return '${android.brand} ${android.model}';
    }
    return 'Unknown Device';
  }

  /// Get platform string
  String getPlatform() {
    if (Platform.isIOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    return 'unknown';
  }

  /// Register this device on login
  /// Returns registration result with isNewDevice flag for facial verification
  Future<DeviceRegistrationResult> registerDevice() async {
    try {
      debugPrint('📱 [DeviceService] Registering device...');
      debugPrint('📱 [DeviceService] Device ID: ${await getDeviceId()}');
      debugPrint('📱 [DeviceService] Device Name: ${await getDeviceName()}');
      
      final response = await _apiService.post('/user/devices', {
        'device_id': await getDeviceId(),
        'device_name': await getDeviceName(),
        'platform': getPlatform(),
      });

      debugPrint('📱 [DeviceService] Response: $response');
      
      // Check if this is a new device (201 registered) or existing (200 updated)
      final status = response['status'] ?? '';
      final isNewDevice = status == 'registered';
      
      debugPrint('📱 [DeviceService] Status: $status, isNewDevice: $isNewDevice');
      
      return DeviceRegistrationResult(
        success: true,
        isNewDevice: isNewDevice,
        devices: [],
      );
    } catch (e) {
      debugPrint('📱 [DeviceService] ERROR: $e');
      
      // Check if it's a max devices error (409)
      if (e.toString().contains('409') || e.toString().contains('max_devices')) {
        // Parse the devices from error response
        final devices = await getDevices();
        return DeviceRegistrationResult(
          success: false,
          isNewDevice: true, // It would be a new device if we could add it
          maxDevicesReached: true,
          devices: devices,
        );
      }
      rethrow;
    }
  }

  /// Get list of user's registered devices
  Future<List<DeviceInfo>> getDevices() async {
    try {
      final response = await _apiService.get('/user/devices');
      final devicesList = response['devices'] as List<dynamic>? ?? [];
      
      return devicesList.map((d) => DeviceInfo(
        deviceId: d['device_id'] ?? '',
        deviceName: d['device_name'] ?? 'Unknown',
        platform: d['platform'] ?? 'unknown',
        location: d['location'] ?? 'Unknown',
        lastLogin: d['last_login'] ?? '',
        createdAt: d['created_at'] ?? '',
      )).toList();
    } catch (e) {
      return [];
    }
  }

  /// Check if current device is registered (not removed by another device)
  /// Returns false if device was removed (e.g., after passcode change on another device)
  Future<bool> isDeviceRegistered() async {
    try {
      final currentId = await getDeviceId();
      final devices = await getDevices();
      
      final isRegistered = devices.any((d) => d.deviceId == currentId);
      debugPrint('📱 [DeviceService] isDeviceRegistered: $isRegistered (current: $currentId)');
      return isRegistered;
    } catch (e) {
      debugPrint('📱 [DeviceService] isDeviceRegistered error: $e');
      // On error, assume registered to avoid blocking user
      return true;
    }
  }

  /// Remove a device
  Future<void> removeDevice(String deviceId) async {
    try {
      debugPrint('📱 [DeviceService] Deleting device: $deviceId');
      final result = await _apiService.delete('/user/devices/$deviceId');
      debugPrint('📱 [DeviceService] Delete result: $result');
    } catch (e) {
      debugPrint('📱 [DeviceService] Delete ERROR: $e');
      rethrow;
    }
  }
  
  /// Logout all other devices (keep current device only)
  /// Called when passcode is changed to force re-auth on other devices
  Future<void> logoutOtherDevices() async {
    try {
      final currentId = await getDeviceId();
      final devices = await getDevices();
      
      for (final device in devices) {
        if (device.deviceId != currentId) {
          try {
            await removeDevice(device.deviceId);
            debugPrint('📱 [DeviceService] Removed device: ${device.deviceName}');
          } catch (e) {
            debugPrint('📱 [DeviceService] Failed to remove ${device.deviceName}: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('📱 [DeviceService] logoutOtherDevices error: $e');
    }
  }

  /// Format iOS device model to human readable name
  String _formatIOSDeviceName(String model) {
    // Map common identifiers to names
    final Map<String, String> deviceNames = {
      'iPhone15,2': 'iPhone 14 Pro',
      'iPhone15,3': 'iPhone 14 Pro Max',
      'iPhone16,1': 'iPhone 15 Pro',
      'iPhone16,2': 'iPhone 15 Pro Max',
      'iPhone17,1': 'iPhone 16 Pro',
      'iPhone17,2': 'iPhone 16 Pro Max',
    };
    return deviceNames[model] ?? model;
  }
}

/// Result of device registration attempt
class DeviceRegistrationResult {
  final bool success;
  final bool isNewDevice;
  final bool maxDevicesReached;
  final List<DeviceInfo> devices;

  DeviceRegistrationResult({
    required this.success,
    this.isNewDevice = false,
    this.maxDevicesReached = false,
    required this.devices,
  });
}

/// Device information model
class DeviceInfo {
  final String deviceId;
  final String deviceName;
  final String platform;
  final String location;
  final String lastLogin;
  final String createdAt;

  DeviceInfo({
    required this.deviceId,
    required this.deviceName,
    required this.platform,
    required this.location,
    required this.lastLogin,
    required this.createdAt,
  });

  bool get isIOS => platform == 'ios';
  bool get isAndroid => platform == 'android';
}
