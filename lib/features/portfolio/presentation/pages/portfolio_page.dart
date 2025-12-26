import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';

/// Portfolio page - Shows user's holdings and performance
class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key});

  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = '1M';

  final List<String> _periods = ['1D', '1W', '1M', '3M', '1Y', 'ALL'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Portfolio',
          style: ThryveTypography.titleLarge.copyWith(
            color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Portfolio value section
          _buildPortfolioValue(isDark),

          // Period selector
          _buildPeriodSelector(isDark),

          // Chart
          _buildChart(isDark),

          // Tab bar
          _buildTabBar(isDark),

          // Holdings/Activity list
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildHoldingsList(isDark),
                _buildActivityList(isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioValue(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            'Total Value',
            style: ThryveTypography.bodyMedium.copyWith(
              color: ThryveColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '\$4,532.80',
            style: ThryveTypography.displayMedium.copyWith(
              color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: ThryveColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.trending_up, size: 16, color: ThryveColors.success),
                const SizedBox(width: 4),
                Text(
                  '+\$532.80 (12.5%)',
                  style: ThryveTypography.labelMedium.copyWith(
                    color: ThryveColors.success,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _periods.map((period) {
          final isSelected = period == _selectedPeriod;
          return GestureDetector(
            onTap: () => setState(() => _selectedPeriod = period),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? ThryveColors.accent : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                period,
                style: ThryveTypography.labelMedium.copyWith(
                  color: isSelected
                      ? Colors.white
                      : ThryveColors.textSecondary,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChart(bool isDark) {
    return Container(
      height: 180,
      padding: const EdgeInsets.all(24),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (spot) => ThryveColors.surfaceDark,
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: const [
                FlSpot(0, 3),
                FlSpot(1, 3.5),
                FlSpot(2, 3.2),
                FlSpot(3, 4),
                FlSpot(4, 3.8),
                FlSpot(5, 4.2),
                FlSpot(6, 4.5),
              ],
              isCurved: true,
              color: ThryveColors.accent,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    ThryveColors.accent.withValues(alpha: 0.3),
                    ThryveColors.accent.withValues(alpha: 0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: isDark ? ThryveColors.surfaceDark : ThryveColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: ThryveColors.accent,
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: ThryveColors.textSecondary,
        labelStyle: ThryveTypography.labelLarge,
        tabs: const [
          Tab(text: 'Holdings'),
          Tab(text: 'Activity'),
        ],
      ),
    );
  }

  Widget _buildHoldingsList(bool isDark) {
    final holdings = [
      {'symbol': 'AAPL', 'name': 'Apple Inc.', 'shares': '5.234', 'value': '\$933.20', 'change': '+2.34%', 'isUp': true},
      {'symbol': 'NVDA', 'name': 'NVIDIA Corp.', 'shares': '2.100', 'value': '\$981.33', 'change': '+4.21%', 'isUp': true},
      {'symbol': 'TSLA', 'name': 'Tesla, Inc.', 'shares': '3.500', 'value': '\$869.75', 'change': '-1.23%', 'isUp': false},
      {'symbol': 'MSFT', 'name': 'Microsoft', 'shares': '2.000', 'value': '\$757.82', 'change': '+1.87%', 'isUp': true},
      {'symbol': 'AMZN', 'name': 'Amazon.com', 'shares': '6.500', 'value': '\$987.61', 'change': '+0.87%', 'isUp': true},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: holdings.length,
      itemBuilder: (context, index) {
        final holding = holdings[index];
        return GestureDetector(
          onTap: () => context.push('/trade/${holding['symbol']}'),
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
                      holding['symbol'].toString().substring(0, 2),
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
                        holding['symbol'] as String,
                        style: ThryveTypography.titleMedium.copyWith(
                          color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${holding['shares']} shares',
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
                      holding['value'] as String,
                      style: ThryveTypography.titleMedium.copyWith(
                        color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                      ),
                    ),
                    Text(
                      holding['change'] as String,
                      style: ThryveTypography.labelMedium.copyWith(
                        color: (holding['isUp'] as bool) ? ThryveColors.success : ThryveColors.error,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActivityList(bool isDark) {
    final activities = [
      {'type': 'buy', 'symbol': 'AAPL', 'amount': '\$150.00', 'shares': '0.84', 'date': 'Dec 25, 2024'},
      {'type': 'sell', 'symbol': 'TSLA', 'amount': '\$200.00', 'shares': '0.80', 'date': 'Dec 24, 2024'},
      {'type': 'buy', 'symbol': 'NVDA', 'amount': '\$300.00', 'shares': '0.64', 'date': 'Dec 23, 2024'},
      {'type': 'dividend', 'symbol': 'MSFT', 'amount': '\$12.50', 'shares': '', 'date': 'Dec 20, 2024'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        final isBuy = activity['type'] == 'buy';
        final isDividend = activity['type'] == 'dividend';

        IconData icon;
        Color iconColor;
        String title;

        if (isDividend) {
          icon = Icons.attach_money;
          iconColor = ThryveColors.success;
          title = 'Dividend from ${activity['symbol']}';
        } else if (isBuy) {
          icon = Icons.add;
          iconColor = ThryveColors.success;
          title = 'Bought ${activity['symbol']}';
        } else {
          icon = Icons.remove;
          iconColor = ThryveColors.error;
          title = 'Sold ${activity['symbol']}';
        }

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
                    Text(
                      title,
                      style: ThryveTypography.titleSmall.copyWith(
                        color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                      ),
                    ),
                    Text(
                      activity['date'] as String,
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
                    '${isBuy ? '-' : '+'}${activity['amount']}',
                    style: ThryveTypography.titleMedium.copyWith(
                      color: isBuy ? ThryveColors.error : ThryveColors.success,
                    ),
                  ),
                  if ((activity['shares'] as String).isNotEmpty)
                    Text(
                      '${activity['shares']} shares',
                      style: ThryveTypography.bodySmall.copyWith(
                        color: ThryveColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
