import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';

/// Home/Dashboard page - Main landing page after login
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with greeting and notifications
              _buildHeader(context, isDark),

              // Portfolio summary card
              _buildPortfolioCard(context, isDark),

              // Quick actions
              _buildQuickActions(context, isDark),

              // Market movers section
              _buildSectionHeader(context, 'Market Movers', isDark),
              _buildMarketMovers(context, isDark),

              // Watchlist section
              _buildSectionHeader(context, 'Your Watchlist', isDark, showSeeAll: true),
              _buildWatchlist(context, isDark),

              // News section
              _buildSectionHeader(context, 'Market News', isDark),
              _buildNewsList(context, isDark),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good Morning 👋',
                  style: ThryveTypography.bodyMedium.copyWith(
                    color: ThryveColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Welcome to Thryve',
                  style: ThryveTypography.headlineMedium.copyWith(
                    color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          // Notification bell
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDark ? ThryveColors.surfaceDark : ThryveColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    Icons.notifications_outlined,
                    color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: ThryveColors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioCard(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: ThryveColors.accentGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: ThryveColors.accent.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Portfolio Value',
                  style: ThryveTypography.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.trending_up, size: 16, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        '+12.5%',
                        style: ThryveTypography.labelMedium.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '\$4,532.80',
              style: ThryveTypography.displayMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '₦7,234,450.00',
              style: ThryveTypography.titleMedium.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildPortfolioStat('Today\'s Gain', '+\$45.20', true),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                Expanded(
                  child: _buildPortfolioStat('All Time', '+\$532.80', true),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPortfolioStat(String label, String value, bool isPositive) {
    return Column(
      children: [
        Text(
          value,
          style: ThryveTypography.titleLarge.copyWith(
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: ThryveTypography.bodySmall.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, bool isDark) {
    final actions = [
      {'icon': Icons.add_circle_outline, 'label': 'Deposit', 'route': AppRoutes.deposit},
      {'icon': Icons.remove_circle_outline, 'label': 'Withdraw', 'route': AppRoutes.withdraw},
      {'icon': Icons.swap_horiz, 'label': 'Trade', 'route': AppRoutes.trade},
      {'icon': Icons.history, 'label': 'History', 'route': AppRoutes.wallet},
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: actions.map((action) {
          return GestureDetector(
            onTap: () => context.push(action['route'] as String),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isDark ? ThryveColors.surfaceDark : ThryveColors.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    action['icon'] as IconData,
                    color: ThryveColors.accent,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  action['label'] as String,
                  style: ThryveTypography.labelMedium.copyWith(
                    color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, bool isDark, {bool showSeeAll = false}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: ThryveTypography.titleLarge.copyWith(
              color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
            ),
          ),
          if (showSeeAll)
            TextButton(
              onPressed: () {},
              child: Text(
                'See All',
                style: ThryveTypography.labelLarge.copyWith(
                  color: ThryveColors.accent,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMarketMovers(BuildContext context, bool isDark) {
    final stocks = [
      {'symbol': 'AAPL', 'name': 'Apple Inc.', 'price': '\$178.72', 'change': '+2.34%', 'isUp': true},
      {'symbol': 'TSLA', 'name': 'Tesla, Inc.', 'price': '\$248.50', 'change': '-1.23%', 'isUp': false},
      {'symbol': 'MSFT', 'name': 'Microsoft', 'price': '\$378.91', 'change': '+1.87%', 'isUp': true},
    ];

    return SizedBox(
      height: 140,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: stocks.length,
        itemBuilder: (context, index) {
          final stock = stocks[index];
          return Container(
            width: 160,
            margin: EdgeInsets.only(right: index < stocks.length - 1 ? 12 : 0),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: ThryveColors.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          stock['symbol'].toString().substring(0, 1),
                          style: ThryveTypography.titleMedium.copyWith(
                            color: ThryveColors.accent,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (stock['isUp'] as bool)
                            ? ThryveColors.success.withValues(alpha: 0.1)
                            : ThryveColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        stock['change'] as String,
                        style: ThryveTypography.labelSmall.copyWith(
                          color: (stock['isUp'] as bool) ? ThryveColors.success : ThryveColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  stock['symbol'] as String,
                  style: ThryveTypography.titleMedium.copyWith(
                    color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                  ),
                ),
                Text(
                  stock['price'] as String,
                  style: ThryveTypography.bodySmall.copyWith(
                    color: ThryveColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWatchlist(BuildContext context, bool isDark) {
    final watchlist = [
      {'symbol': 'NVDA', 'name': 'NVIDIA Corp.', 'price': '\$467.30', 'change': '+4.21%', 'isUp': true},
      {'symbol': 'AMZN', 'name': 'Amazon.com', 'price': '\$151.94', 'change': '+0.87%', 'isUp': true},
      {'symbol': 'META', 'name': 'Meta Platforms', 'price': '\$326.49', 'change': '-0.45%', 'isUp': false},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: watchlist.map((stock) {
          return GestureDetector(
            onTap: () => context.push('/trade/${stock['symbol']}'),
            child: Container(
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
                      color: ThryveColors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        stock['symbol'].toString().substring(0, 2),
                        style: ThryveTypography.titleSmall.copyWith(
                          color: ThryveColors.accent,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stock['symbol'] as String,
                          style: ThryveTypography.titleMedium.copyWith(
                            color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                          ),
                        ),
                        Text(
                          stock['name'] as String,
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
                        stock['price'] as String,
                        style: ThryveTypography.titleMedium.copyWith(
                          color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                        ),
                      ),
                      Text(
                        stock['change'] as String,
                        style: ThryveTypography.labelMedium.copyWith(
                          color: (stock['isUp'] as bool) ? ThryveColors.success : ThryveColors.error,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNewsList(BuildContext context, bool isDark) {
    final news = [
      {
        'title': 'Fed signals potential rate cuts in 2024',
        'source': 'Reuters',
        'time': '2h ago',
      },
      {
        'title': 'Tech stocks rally on strong earnings',
        'source': 'Bloomberg',
        'time': '4h ago',
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: news.map((item) {
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
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: ThryveColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.article_outlined,
                    color: ThryveColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'] as String,
                        style: ThryveTypography.titleSmall.copyWith(
                          color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${item['source']} • ${item['time']}',
                        style: ThryveTypography.bodySmall.copyWith(
                          color: ThryveColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
