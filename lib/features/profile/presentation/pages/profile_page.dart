import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';
import '../../../../core/services/user_profile_service.dart';
import '../../../auth/data/repositories/auth_repository_impl.dart';
import '../../../auth/domain/entities/auth_user.dart';
import '../../domain/entities/user_profile.dart';

/// Profile page - User account management
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthRepositoryImpl _authRepository = AuthRepositoryImpl();
  final UserProfileService _profileService = UserProfileService();
  
  UserProfile? _profile;
  AuthUser? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    // Check if we have cached profile (instant load!)
    if (_profileService.hasCache) {
      setState(() {
        _profile = _profileService.cachedProfile;
        _isLoading = false;
      });
      return;
    }

    // Fetch from service (will cache automatically)
    try {
      final profile = await _profileService.getProfile();
      if (mounted) {
        setState(() {
          _profile = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      // Fallback to Cognito if API fails
      try {
        final user = await _authRepository.getCurrentUser();
        if (mounted) {
          setState(() {
            _user = user;
            _isLoading = false;
          });
        }
      } catch (e2) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
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
        title: Text(
          'Profile',
          style: ThryveTypography.titleLarge.copyWith(
            color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
              color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
            ),
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Profile header
                  _buildProfileHeader(isDark),

                  // KYC status
                  _buildKycStatus(context, isDark),

                  // Account stats
                  _buildAccountStats(isDark),

                  // Menu items
                  _buildMenuSection(context, isDark),

                  const SizedBox(height: 24),

                  // Logout button
                  _buildLogoutButton(context, isDark),

                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader(bool isDark) {
    // Use API profile if available, otherwise fallback to Cognito user
    final displayName = _profile?.displayName ?? _user?.displayName ?? 'User';
    final initials = _profile?.initials ?? _user?.initials ?? 'U';
    final email = _profile?.email ?? _user?.email ?? '';
    final phone = _profile?.phoneNumber ?? _user?.phoneNumber ?? '';

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: ThryveColors.accentGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: ThryveTypography.displaySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isDark ? ThryveColors.surfaceDark : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? ThryveColors.backgroundDark : Colors.white,
                      width: 3,
                    ),
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    size: 16,
                    color: ThryveColors.accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Name
          Text(
            displayName,
            style: ThryveTypography.headlineSmall.copyWith(
              color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: ThryveTypography.bodyMedium.copyWith(
              color: ThryveColors.textSecondary,
            ),
          ),
          if (phone.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              phone,
              style: ThryveTypography.bodySmall.copyWith(
                color: ThryveColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildKycStatus(BuildContext context, bool isDark) {
    // Determine KYC state from profile
    final kycStatus = _profile?.kycStatus ?? 'not_started';
    final isComplete = kycStatus == 'approved';
    final isPending = kycStatus == 'pending';
    
    // Colors based on status
    final statusColor = isComplete
        ? ThryveColors.success
        : isPending
            ? ThryveColors.warning
            : ThryveColors.warning;
    
    final statusTitle = isComplete
        ? 'Verified'
        : isPending
            ? 'Verification Pending'
            : 'Complete Verification';
    
    final statusSubtitle = isComplete
        ? 'Your identity has been verified'
        : isPending
            ? 'We\'re reviewing your documents'
            : 'Verify your identity to unlock all features';

    return GestureDetector(
      onTap: isComplete ? null : () => context.push(AppRoutes.kycStart),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: statusColor.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isComplete ? Icons.verified : Icons.verified_user_outlined,
                color: statusColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    statusTitle,
                    style: ThryveTypography.titleSmall.copyWith(
                      color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                    ),
                  ),
                  Text(
                    statusSubtitle,
                    style: ThryveTypography.bodySmall.copyWith(
                      color: ThryveColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (!isComplete)
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: ThryveColors.textSecondary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountStats(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              'Portfolio Value',
              '\$0.00',
              Icons.account_balance_wallet_outlined,
              isDark,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatItem(
              'Returns',
              '+0.00%',
              Icons.trending_up,
              isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? ThryveColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? ThryveColors.surfaceElevatedDark : ThryveColors.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: ThryveColors.accent, size: 24),
          const SizedBox(height: 12),
          Text(
            label,
            style: ThryveTypography.bodySmall.copyWith(
              color: ThryveColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: ThryveTypography.titleMedium.copyWith(
              color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: isDark ? ThryveColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? ThryveColors.surfaceElevatedDark : ThryveColors.divider,
        ),
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.person_outline,
            title: 'Edit Profile',
            onTap: () => context.push(AppRoutes.editProfile),
            isDark: isDark,
          ),
          _buildMenuDivider(isDark),
          _buildMenuItem(
            icon: Icons.account_balance_outlined,
            title: 'Bank Accounts',
            onTap: () => context.push(AppRoutes.bankAccounts),
            isDark: isDark,
          ),
          _buildMenuDivider(isDark),
          _buildMenuItem(
            icon: Icons.history,
            title: 'Transaction History',
            onTap: () => context.push(AppRoutes.orderHistory),
            isDark: isDark,
          ),
          _buildMenuDivider(isDark),
          _buildMenuItem(
            icon: Icons.payment_outlined,
            title: 'Manage Subscriptions',
            onTap: () {},
            isDark: isDark,
          ),
          _buildMenuDivider(isDark),
          _buildMenuItem(
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () => context.push(AppRoutes.helpSupport),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: ThryveColors.accent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: ThryveColors.accent, size: 20),
      ),
      title: Text(
        title,
        style: ThryveTypography.titleSmall.copyWith(
          color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: ThryveColors.textSecondary,
      ),
      onTap: onTap,
    );
  }

  Widget _buildMenuDivider(bool isDark) {
    return Divider(
      height: 1,
      indent: 72,
      color: isDark ? ThryveColors.surfaceElevatedDark : ThryveColors.divider,
    );
  }

  Widget _buildLogoutButton(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: OutlinedButton.icon(
          onPressed: () async {
            await _authRepository.signOut();
            if (mounted) {
              context.go(AppRoutes.onboarding);
            }
          },
          icon: const Icon(Icons.logout, color: ThryveColors.error),
          label: Text(
            'Sign Out',
            style: ThryveTypography.button.copyWith(
              color: ThryveColors.error,
              fontSize: 16,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: ThryveColors.error, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}
