import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';

/// Devices page - Manage logged in devices
class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  // Mock devices data - in production, fetch from device management API
  final List<Map<String, dynamic>> _devices = [
    {
      'id': 'device_1',
      'name': 'iPhone 15 Pro',
      'location': 'Lagos, Nigeria',
      'time': 'Now • Current session',
      'isCurrentDevice': true,
    },
    {
      'id': 'device_2',
      'name': 'Chrome on MacBook',
      'location': 'Lagos, Nigeria',
      'time': 'Yesterday at 2:30 PM',
      'isCurrentDevice': false,
    },
    {
      'id': 'device_3',
      'name': 'Safari on iPhone',
      'location': 'Abuja, Nigeria',
      'time': 'Dec 23, 2024',
      'isCurrentDevice': false,
    },
  ];

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Description
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
            _buildSectionTitle('Active Devices', isDark),
            _buildCard(isDark, [
              for (int i = 0; i < _devices.length; i++) ...[
                if (i > 0)
                  Divider(height: 1, color: isDark ? ThryveColors.surfaceElevatedDark : ThryveColors.divider),
                _buildDeviceItem(
                  device: _devices[i]['name'],
                  location: _devices[i]['location'],
                  time: _devices[i]['time'],
                  isCurrentDevice: _devices[i]['isCurrentDevice'],
                  deviceId: _devices[i]['id'],
                  isDark: isDark,
                ),
              ],
            ]),
            const SizedBox(height: 16),
            
            // Log out all button
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
    required String device,
    required String location,
    required String time,
    required bool isCurrentDevice,
    required String deviceId,
    required bool isDark,
  }) {
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
              device.contains('iPhone') ? Icons.phone_iphone : Icons.laptop_mac,
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
                        device,
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
                  '$location • $time',
                  style: ThryveTypography.bodySmall.copyWith(color: ThryveColors.textSecondary),
                ),
              ],
            ),
          ),
          if (!isCurrentDevice)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: ThryveColors.error, size: 22),
              onPressed: () => _showRemoveDeviceConfirmation(deviceId, device),
              tooltip: 'Remove device',
            ),
        ],
      ),
    );
  }

  void _showRemoveDeviceConfirmation(String deviceId, String deviceName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Remove Device'),
        content: Text('Remove "$deviceName" from your account? This will log out that device.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: ThryveColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _devices.removeWhere((d) => d['id'] == deviceId);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$deviceName has been removed'),
                  backgroundColor: ThryveColors.success,
                ),
              );
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
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _devices.removeWhere((d) => d['isCurrentDevice'] != true);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All other devices have been logged out'),
                  backgroundColor: ThryveColors.warning,
                ),
              );
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
}
