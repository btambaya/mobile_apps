import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';
import '../../../../core/services/user_profile_service.dart';
import '../../domain/entities/user_profile.dart';

/// Notifications page - View all notifications with actionable items
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final UserProfileService _profileService = UserProfileService();
  UserProfile? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    // Check cache first (instant!)
    if (_profileService.hasCache) {
      setState(() {
        _profile = _profileService.cachedProfile;
        _isLoading = false;
      });
      return;
    }

    // Fetch from service
    try {
      final profile = await _profileService.getProfile();
      if (mounted) {
        setState(() {
          _profile = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<NotificationItem> _buildNotifications() {
    final List<NotificationItem> notifications = [];
    
    // Action required: Phone verification
    if (_profile != null && !_profile!.phoneVerified) {
      notifications.add(NotificationItem(
        type: NotificationType.action,
        title: 'Verify Your Phone Number',
        message: 'Verify your phone number to secure your account and enable two-factor authentication.',
        time: 'Action required',
        isRead: false,
        actionRoute: null, // TODO: Add phone verification route
      ));
    }
    
    // Action required: Complete KYC
    if (_profile != null && _profile!.needsKyc) {
      notifications.add(NotificationItem(
        type: NotificationType.action,
        title: 'Complete Identity Verification',
        message: 'Complete your KYC to unlock trading, deposits, and withdrawals.',
        time: 'Action required',
        isRead: false,
        actionRoute: AppRoutes.kycStart,
      ));
    }
    
    // KYC pending notification
    if (_profile != null && _profile!.isKycPending) {
      notifications.add(NotificationItem(
        type: NotificationType.info,
        title: 'KYC Under Review',
        message: 'Your identity verification is being reviewed. This usually takes 1-2 business days.',
        time: 'Pending',
        isRead: true,
        actionRoute: null,
      ));
    }
    
    // Welcome notification for new users
    notifications.add(NotificationItem(
      type: NotificationType.success,
      title: 'Welcome to Thryve!',
      message: 'Start your investment journey by completing your profile and making your first deposit.',
      time: 'Today',
      isRead: _profile?.isKycComplete ?? false,
      actionRoute: null,
    ));
    
    // Sample notifications (can be removed in production)
    notifications.addAll([
      NotificationItem(
        type: NotificationType.info,
        title: 'New Feature: Auto-Invest',
        message: 'Set up recurring investments and grow your portfolio automatically.',
        time: '2 days ago',
        isRead: true,
        actionRoute: AppRoutes.autoInvest,
      ),
    ]);
    
    return notifications;
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(isDark),
    );
  }

  Widget _buildBody(bool isDark) {
    final notifications = _buildNotifications();
    
    if (notifications.isEmpty) {
      return _buildEmptyState(isDark);
    }
    
    // Separate action items from regular notifications
    final actionItems = notifications.where((n) => n.type == NotificationType.action).toList();
    final regularItems = notifications.where((n) => n.type != NotificationType.action).toList();
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Action required section
        if (actionItems.isNotEmpty) ...[
          Text(
            'ACTION REQUIRED',
            style: ThryveTypography.labelMedium.copyWith(
              color: ThryveColors.error,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...actionItems.map((item) => _buildNotificationCard(item, isDark)),
          const SizedBox(height: 24),
        ],
        
        // Regular notifications
        if (regularItems.isNotEmpty) ...[
          Text(
            'NOTIFICATIONS',
            style: ThryveTypography.labelMedium.copyWith(
              color: ThryveColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          ...regularItems.map((item) => _buildNotificationCard(item, isDark)),
        ],
      ],
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
      case NotificationType.action:
        icon = Icons.warning_amber_rounded;
        color = ThryveColors.error;
        break;
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

    return GestureDetector(
      onTap: notification.actionRoute != null
          ? () => context.push(notification.actionRoute!)
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: notification.isRead
              ? (isDark ? ThryveColors.surfaceDark : Colors.white)
              : (isDark ? ThryveColors.surfaceElevatedDark : ThryveColors.surface),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notification.type == NotificationType.action
                ? ThryveColors.error.withValues(alpha: 0.5)
                : (notification.isRead
                    ? (isDark ? ThryveColors.surfaceElevatedDark : ThryveColors.divider)
                    : ThryveColors.accent.withValues(alpha: 0.3)),
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
                            decoration: BoxDecoration(
                              color: notification.type == NotificationType.action
                                  ? ThryveColors.error
                                  : ThryveColors.accent,
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
                    Row(
                      children: [
                        Text(
                          notification.time,
                          style: ThryveTypography.caption.copyWith(
                            color: notification.type == NotificationType.action
                                ? ThryveColors.error
                                : ThryveColors.textTertiary,
                            fontWeight: notification.type == NotificationType.action
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        if (notification.actionRoute != null) ...[
                          const Spacer(),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: ThryveColors.textSecondary,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum NotificationType { action, success, trade, deposit, alert, info, dividend }

class NotificationItem {
  final NotificationType type;
  final String title;
  final String message;
  final String time;
  final bool isRead;
  final String? actionRoute;

  NotificationItem({
    required this.type,
    required this.title,
    required this.message,
    required this.time,
    required this.isRead,
    this.actionRoute,
  });
}
