import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';

/// Wallet page - Shows balance and transaction history
class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Wallet',
          style: ThryveTypography.titleLarge.copyWith(
            color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance cards
            _buildBalanceCards(context, isDark),

            // Action buttons
            _buildActionButtons(context, isDark),

            // Transactions section
            _buildTransactionsSection(context, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCards(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // USD Balance
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: ThryveColors.accentGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'USD Balance',
                      style: ThryveTypography.bodyMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.attach_money,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '\$1,250.45',
                  style: ThryveTypography.displayMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Available to invest or withdraw',
                  style: ThryveTypography.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // NGN Balance
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? ThryveColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? ThryveColors.surfaceElevatedDark : ThryveColors.divider,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'NGN Equivalent',
                      style: ThryveTypography.bodyMedium.copyWith(
                        color: ThryveColors.textSecondary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: ThryveColors.info.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '₦1 = \$0.00063',
                        style: ThryveTypography.labelSmall.copyWith(
                          color: ThryveColors.info,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '₦1,984,215.00',
                  style: ThryveTypography.headlineLarge.copyWith(
                    color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              context,
              icon: Icons.add,
              label: 'Deposit',
              color: ThryveColors.success,
              onTap: () => context.push(AppRoutes.deposit),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildActionButton(
              context,
              icon: Icons.remove,
              label: 'Withdraw',
              color: ThryveColors.accent,
              onTap: () => context.push(AppRoutes.withdraw),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: ThryveTypography.labelLarge.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsSection(BuildContext context, bool isDark) {
    final transactions = [
      {'type': 'deposit', 'amount': '₦50,000', 'usd': '\$31.50', 'date': 'Dec 25, 2024', 'status': 'completed'},
      {'type': 'buy', 'amount': 'AAPL', 'usd': '-\$150.00', 'date': 'Dec 24, 2024', 'status': 'completed'},
      {'type': 'deposit', 'amount': '₦100,000', 'usd': '\$63.00', 'date': 'Dec 23, 2024', 'status': 'completed'},
      {'type': 'withdraw', 'amount': '₦25,000', 'usd': '-\$15.75', 'date': 'Dec 22, 2024', 'status': 'completed'},
      {'type': 'sell', 'amount': 'TSLA', 'usd': '+\$200.00', 'date': 'Dec 21, 2024', 'status': 'completed'},
      {'type': 'deposit', 'amount': '₦200,000', 'usd': '\$126.00', 'date': 'Dec 20, 2024', 'status': 'pending'},
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Transactions',
            style: ThryveTypography.titleLarge.copyWith(
              color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...transactions.map((tx) => _buildTransactionItem(tx, isDark)),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> tx, bool isDark) {
    IconData icon;
    Color iconColor;
    String title;

    switch (tx['type']) {
      case 'deposit':
        icon = Icons.arrow_downward;
        iconColor = ThryveColors.success;
        title = 'Deposit';
        break;
      case 'withdraw':
        icon = Icons.arrow_upward;
        iconColor = ThryveColors.error;
        title = 'Withdrawal';
        break;
      case 'buy':
        icon = Icons.shopping_cart;
        iconColor = ThryveColors.accent;
        title = 'Bought ${tx['amount']}';
        break;
      case 'sell':
        icon = Icons.sell;
        iconColor = ThryveColors.info;
        title = 'Sold ${tx['amount']}';
        break;
      default:
        icon = Icons.swap_horiz;
        iconColor = ThryveColors.textSecondary;
        title = 'Transaction';
    }

    final isPending = tx['status'] == 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? ThryveColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? ThryveColors.surfaceElevatedDark : ThryveColors.divider,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: ThryveTypography.titleSmall.copyWith(
                        color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                      ),
                    ),
                    if (isPending) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: ThryveColors.warning.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Pending',
                          style: ThryveTypography.labelSmall.copyWith(
                            color: ThryveColors.warning,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  tx['date'] as String,
                  style: ThryveTypography.bodySmall.copyWith(
                    color: ThryveColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                tx['usd'] as String,
                style: ThryveTypography.titleMedium.copyWith(
                  color: (tx['usd'] as String).startsWith('+')
                      ? ThryveColors.success
                      : (tx['usd'] as String).startsWith('-')
                          ? ThryveColors.error
                          : (isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary),
                ),
              ),
              if (tx['type'] == 'deposit' || tx['type'] == 'withdraw')
                Text(
                  tx['amount'] as String,
                  style: ThryveTypography.bodySmall.copyWith(
                    color: ThryveColors.textSecondary,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
