import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';

/// Notifications page - View all notifications
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final notifications = [
      NotificationItem(
        type: NotificationType.success,
        title: 'KYC Verified!',
        message: 'Your identity has been successfully verified. You can now deposit and trade.',
        time: '2 hours ago',
        isRead: false,
      ),
      NotificationItem(
        type: NotificationType.trade,
        title: 'Order Filled',
        message: 'Your buy order for 0.5 shares of AAPL at \$178.50 has been executed.',
        time: '5 hours ago',
        isRead: false,
      ),
      NotificationItem(
        type: NotificationType.deposit,
        title: 'Deposit Received',
        message: 'Your deposit of ₦50,000 has been credited to your account.',
        time: 'Yesterday',
        isRead: true,
      ),
      NotificationItem(
        type: NotificationType.alert,
        title: 'Price Alert: TSLA',
        message: 'Tesla is up 5% today! Check out the movement.',
        time: 'Yesterday',
        isRead: true,
      ),
      NotificationItem(
        type: NotificationType.info,
        title: 'New Feature',
        message: 'You can now set price alerts for your favorite stocks.',
        time: '2 days ago',
        isRead: true,
      ),
      NotificationItem(
        type: NotificationType.dividend,
        title: 'Dividend Received',
        message: 'You received \$12.50 dividend from MSFT.',
        time: '3 days ago',
        isRead: true,
      ),
    ];

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
          'Notifications',
          style: ThryveTypography.titleLarge.copyWith(
            color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All notifications marked as read'),
                  backgroundColor: ThryveColors.success,
                ),
              );
            },
            child: Text(
              'Mark all read',
              style: ThryveTypography.labelMedium.copyWith(color: ThryveColors.accent),
            ),
          ),
        ],
      ),
      body: notifications.isEmpty
          ? _buildEmptyState(isDark)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                return _buildNotificationCard(notifications[index], isDark);
              },
            ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: ThryveColors.accent.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_off_outlined,
              size: 64,
              color: ThryveColors.accent,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Notifications',
            style: ThryveTypography.titleLarge.copyWith(
              color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
            style: ThryveTypography.bodyMedium.copyWith(
              color: ThryveColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem notification, bool isDark) {
    IconData icon;
    Color color;

    switch (notification.type) {
      case NotificationType.success:
        icon = Icons.check_circle;
        color = ThryveColors.success;
        break;
      case NotificationType.trade:
        icon = Icons.trending_up;
        color = ThryveColors.accent;
        break;
      case NotificationType.deposit:
        icon = Icons.account_balance_wallet;
        color = ThryveColors.success;
        break;
      case NotificationType.alert:
        icon = Icons.notifications_active;
        color = ThryveColors.warning;
        break;
      case NotificationType.info:
        icon = Icons.info;
        color = ThryveColors.info;
        break;
      case NotificationType.dividend:
        icon = Icons.attach_money;
        color = ThryveColors.success;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: notification.isRead
            ? (isDark ? ThryveColors.surfaceDark : Colors.white)
            : (isDark ? ThryveColors.surfaceElevatedDark : ThryveColors.surface),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: notification.isRead
              ? (isDark ? ThryveColors.surfaceElevatedDark : ThryveColors.divider)
              : ThryveColors.accent.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: ThryveTypography.titleSmall.copyWith(
                            color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                            fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w600,
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: ThryveColors.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: ThryveTypography.bodySmall.copyWith(
                      color: ThryveColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    notification.time,
                    style: ThryveTypography.caption.copyWith(
                      color: ThryveColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum NotificationType { success, trade, deposit, alert, info, dividend }

class NotificationItem {
  final NotificationType type;
  final String title;
  final String message;
  final String time;
  final bool isRead;

  NotificationItem({
    required this.type,
    required this.title,
    required this.message,
    required this.time,
    required this.isRead,
  });
}
