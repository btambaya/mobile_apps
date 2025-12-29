import 'package:flutter/material.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';
import '../../../../core/services/device_service.dart';

/// Dialog shown when user has reached maximum 3 devices
/// User must select a device to remove before continuing
class DeviceLimitDialog extends StatefulWidget {
  final List<DeviceInfo> devices;
  final Function(String deviceId) onDeviceRemoved;

  const DeviceLimitDialog({
    super.key,
    required this.devices,
    required this.onDeviceRemoved,
  });

  @override
  State<DeviceLimitDialog> createState() => _DeviceLimitDialogState();
}

class _DeviceLimitDialogState extends State<DeviceLimitDialog> {
  String? _selectedDeviceId;
  bool _isRemoving = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: isDark ? ThryveColors.surfaceDark : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Warning icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: ThryveColors.warning.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.devices,
                color: ThryveColors.warning,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              'Device Limit Reached',
              style: ThryveTypography.headlineSmall.copyWith(
                color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Description
            Text(
              'You can only be logged in on 3 devices. Select a device to remove:',
              style: ThryveTypography.bodyMedium.copyWith(
                color: ThryveColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Device list
            ...widget.devices.map((device) => _buildDeviceTile(device, isDark)),

            const SizedBox(height: 24),

            // Remove button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedDeviceId == null || _isRemoving
                    ? null
                    : _handleRemoveDevice,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThryveColors.error,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isRemoving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Remove Selected Device',
                        style: ThryveTypography.button.copyWith(color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceTile(DeviceInfo device, bool isDark) {
    final isSelected = device.deviceId == _selectedDeviceId;

    return GestureDetector(
      onTap: () => setState(() => _selectedDeviceId = device.deviceId),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? ThryveColors.accent.withValues(alpha: 0.1)
              : (isDark ? ThryveColors.surfaceDark : ThryveColors.surface),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? ThryveColors.accent : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              device.isIOS ? Icons.phone_iphone : Icons.phone_android,
              color: isSelected ? ThryveColors.accent : ThryveColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device.deviceName,
                    style: ThryveTypography.titleSmall.copyWith(
                      color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Last active: ${_formatDate(device.lastLogin)}',
                    style: ThryveTypography.bodySmall.copyWith(
                      color: ThryveColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: ThryveColors.accent),
          ],
        ),
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inDays == 0) return 'Today';
      if (diff.inDays == 1) return 'Yesterday';
      if (diff.inDays < 7) return '${diff.inDays} days ago';
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Unknown';
    }
  }

  Future<void> _handleRemoveDevice() async {
    if (_selectedDeviceId == null) return;

    setState(() => _isRemoving = true);

    try {
      await DeviceService().removeDevice(_selectedDeviceId!);
      widget.onDeviceRemoved(_selectedDeviceId!);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove device: $e'),
            backgroundColor: ThryveColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRemoving = false);
      }
    }
  }
}

/// Show the device limit dialog
Future<void> showDeviceLimitDialog(
  BuildContext context,
  List<DeviceInfo> devices,
) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => DeviceLimitDialog(
      devices: devices,
      onDeviceRemoved: (deviceId) async {
        Navigator.of(context).pop();
        // After removal, try registering again
        final result = await DeviceService().registerDevice();
        if (!result.success && result.maxDevicesReached) {
          // Still at limit, show dialog again
          if (context.mounted) {
            showDeviceLimitDialog(context, result.devices);
          }
        }
      },
    ),
  );
}
