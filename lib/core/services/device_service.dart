import 'dart:io';
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
  /// Returns null on success, or list of user's devices if max limit reached
  Future<DeviceRegistrationResult> registerDevice() async {
    try {
      await _apiService.post('/user/devices', {
        'device_id': await getDeviceId(),
        'device_name': await getDeviceName(),
        'platform': getPlatform(),
      });

      return DeviceRegistrationResult(success: true, devices: []);
    } catch (e) {
      // Check if it's a max devices error (409)
      if (e.toString().contains('409') || e.toString().contains('max_devices')) {
        // Parse the devices from error response
        // In real implementation, extract devices from response
        final devices = await getDevices();
        return DeviceRegistrationResult(
          success: false,
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
        lastLogin: d['last_login'] ?? '',
        createdAt: d['created_at'] ?? '',
      )).toList();
    } catch (e) {
      return [];
    }
  }

  /// Remove a device
  Future<void> removeDevice(String deviceId) async {
    await _apiService.delete('/user/devices/$deviceId');
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
  final bool maxDevicesReached;
  final List<DeviceInfo> devices;

  DeviceRegistrationResult({
    required this.success,
    this.maxDevicesReached = false,
    required this.devices,
  });
}

/// Device information model
class DeviceInfo {
  final String deviceId;
  final String deviceName;
  final String platform;
  final String lastLogin;
  final String createdAt;

  DeviceInfo({
    required this.deviceId,
    required this.deviceName,
    required this.platform,
    required this.lastLogin,
    required this.createdAt,
  });

  bool get isIOS => platform == 'ios';
  bool get isAndroid => platform == 'android';
}
