import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';
import '../../../../core/services/device_service.dart';

/// Devices page - Manage logged in devices
class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  final DeviceService _deviceService = DeviceService();
  
  List<DeviceInfo> _devices = [];
  String? _currentDeviceId;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final currentId = await _deviceService.getDeviceId();
      final devices = await _deviceService.getDevices();
      
      if (mounted) {
        setState(() {
          _currentDeviceId = currentId;
          _devices = devices;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load devices';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Devices',
          style: ThryveTypography.titleLarge.copyWith(
            color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildBody(isDark),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: ThryveColors.error, size: 48),
            const SizedBox(height: 16),
            Text(_error!, style: ThryveTypography.bodyMedium),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDevices,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDevices,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ThryveColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: ThryveColors.info.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: ThryveColors.info, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'These are devices that have logged into your account. Remove any you don\'t recognize.',
                      style: ThryveTypography.bodySmall.copyWith(
                        color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Devices list
            _buildSectionTitle('Active Devices (${_devices.length}/3)', isDark),
            
            if (_devices.isEmpty)
              _buildCard(isDark, [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'No devices found',
                      style: ThryveTypography.bodyMedium.copyWith(
                        color: ThryveColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ])
            else
              _buildCard(isDark, [
                for (int i = 0; i < _devices.length; i++) ...[
                  if (i > 0)
                    Divider(height: 1, color: isDark ? ThryveColors.surfaceElevatedDark : ThryveColors.divider),
                  _buildDeviceItem(
                    device: _devices[i],
                    isCurrentDevice: _devices[i].deviceId == _currentDeviceId,
                    isDark: isDark,
                  ),
                ],
              ]),
            
            const SizedBox(height: 16),
            
            // Log out all button
            if (_devices.length > 1)
              TextButton.icon(
                onPressed: () => _showLogoutAllConfirmation(),
                icon: const Icon(Icons.logout, color: ThryveColors.error, size: 20),
                label: Text(
                  'Log out all other devices',
                  style: ThryveTypography.labelLarge.copyWith(color: ThryveColors.error),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: ThryveTypography.labelLarge.copyWith(
          color: ThryveColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildCard(bool isDark, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? ThryveColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? ThryveColors.surfaceElevatedDark : ThryveColors.divider,
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDeviceItem({
    required DeviceInfo device,
    required bool isCurrentDevice,
    required bool isDark,
  }) {
    final timeDisplay = _formatTime(device.lastLogin);
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (isCurrentDevice ? ThryveColors.success : ThryveColors.textSecondary)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              device.isIOS ? Icons.phone_iphone : Icons.phone_android,
              color: isCurrentDevice ? ThryveColors.success : ThryveColors.textSecondary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        device.deviceName,
                        style: ThryveTypography.titleSmall.copyWith(
                          color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isCurrentDevice) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: ThryveColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'This device',
                          style: ThryveTypography.labelSmall.copyWith(color: ThryveColors.success),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  '${device.location} • $timeDisplay',
                  style: ThryveTypography.bodySmall.copyWith(color: ThryveColors.textSecondary),
                ),
              ],
            ),
          ),
          if (!isCurrentDevice)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: ThryveColors.error, size: 22),
              onPressed: () => _showRemoveDeviceConfirmation(device),
              tooltip: 'Remove device',
            ),
        ],
      ),
    );
  }

  String _formatTime(String isoTime) {
    if (isoTime.isEmpty) return 'Unknown';
    
    try {
      final dateTime = DateTime.parse(isoTime);
      final now = DateTime.now();
      final diff = now.difference(dateTime);
      
      if (diff.inMinutes < 5) return 'Now';
      if (diff.inHours < 1) return '${diff.inMinutes} minutes ago';
      if (diff.inDays < 1) return '${diff.inHours} hours ago';
      if (diff.inDays == 1) return 'Yesterday';
      if (diff.inDays < 7) return '${diff.inDays} days ago';
      
      return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
    } catch (e) {
      return isoTime;
    }
  }

  void _showRemoveDeviceConfirmation(DeviceInfo device) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Remove Device'),
        content: Text('Remove "${device.deviceName}" from your account? This will log out that device.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: ThryveColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _removeDevice(device.deviceId, device.deviceName);
            },
            child: const Text(
              'Remove',
              style: TextStyle(color: ThryveColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _removeDevice(String deviceId, String deviceName) async {
    try {
      await _deviceService.removeDevice(deviceId);
      
      if (mounted) {
        setState(() {
          _devices.removeWhere((d) => d.deviceId == deviceId);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$deviceName has been removed'),
            backgroundColor: ThryveColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove device: $e'),
            backgroundColor: ThryveColors.error,
          ),
        );
      }
    }
  }

  void _showLogoutAllConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Log Out All Devices'),
        content: const Text('This will log out all devices except this one. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: ThryveColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _logoutAllOtherDevices();
            },
            child: const Text(
              'Log Out All',
              style: TextStyle(color: ThryveColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _logoutAllOtherDevices() async {
    final otherDevices = _devices.where((d) => d.deviceId != _currentDeviceId).toList();
    int removed = 0;
    
    for (final device in otherDevices) {
      try {
        await _deviceService.removeDevice(device.deviceId);
        removed++;
      } catch (e) {
        // Continue with next device
      }
    }
    
    if (mounted) {
      await _loadDevices(); // Refresh list
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$removed device(s) have been logged out'),
          backgroundColor: ThryveColors.warning,
        ),
      );
    }
  }
}
