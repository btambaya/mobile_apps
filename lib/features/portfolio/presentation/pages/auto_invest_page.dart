import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';

/// Auto-Invest page - Set up recurring investments
/// Allows users to schedule automatic investments on D/W/M/Y basis
class AutoInvestPage extends StatefulWidget {
  const AutoInvestPage({super.key});

  @override
  State<AutoInvestPage> createState() => _AutoInvestPageState();
}

class _AutoInvestPageState extends State<AutoInvestPage> {
  bool _isEnabled = false;
  String _selectedFrequency = 'Weekly';
  final _amountController = TextEditingController(text: '50');
  String? _selectedStock;
  int _selectedDayOfWeek = DateTime.monday; // For weekly
  int _selectedDayOfMonth = 1; // For monthly

  final List<String> _frequencies = ['Daily', 'Weekly', 'Monthly', 'Yearly'];
  final List<String> _weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];

  // Mock watchlist/portfolio stocks for auto-invest
  final List<Map<String, dynamic>> _availableStocks = [
    {'symbol': 'AAPL', 'name': 'Apple Inc.', 'price': 178.72},
    {'symbol': 'MSFT', 'name': 'Microsoft Corporation', 'price': 378.91},
    {'symbol': 'GOOGL', 'name': 'Alphabet Inc.', 'price': 141.80},
    {'symbol': 'AMZN', 'name': 'Amazon.com Inc.', 'price': 151.94},
    {'symbol': 'NVDA', 'name': 'NVIDIA Corporation', 'price': 467.30},
    {'symbol': 'TSLA', 'name': 'Tesla, Inc.', 'price': 248.50},
  ];

  // Active auto-invests (mock data)
  final List<Map<String, dynamic>> _activeAutoInvests = [
    {
      'symbol': 'AAPL',
      'name': 'Apple Inc.',
      'amount': 100.0,
      'frequency': 'Weekly',
      'nextDate': 'Mon, Dec 30',
      'isActive': true,
    },
    {
      'symbol': 'MSFT',
      'name': 'Microsoft',
      'amount': 50.0,
      'frequency': 'Monthly',
      'nextDate': 'Jan 1, 2025',
      'isActive': true,
    },
  ];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _showCreateAutoInvestSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: isDark ? ThryveColors.backgroundDark : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: ThryveColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'New Auto-Invest',
                      style: ThryveTypography.headlineSmall.copyWith(
                        color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Select Stock
                      Text(
                        'Select Stock',
                        style: ThryveTypography.labelLarge.copyWith(
                          color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _availableStocks.map((stock) {
                          final isSelected = _selectedStock == stock['symbol'];
                          return GestureDetector(
                            onTap: () => setModalState(() => _selectedStock = stock['symbol'] as String),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? ThryveColors.accent
                                    : (isDark ? ThryveColors.surfaceDark : ThryveColors.surface),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? ThryveColors.accent : ThryveColors.divider,
                                ),
                              ),
                              child: Text(
                                stock['symbol'] as String,
                                style: ThryveTypography.labelMedium.copyWith(
                                  color: isSelected ? Colors.white : ThryveColors.textSecondary,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 24),

                      // Amount
                      Text(
                        'Amount per investment',
                        style: ThryveTypography.labelLarge.copyWith(
                          color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        style: ThryveTypography.headlineMedium.copyWith(
                          color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          prefixText: '\$ ',
                          prefixStyle: ThryveTypography.headlineMedium.copyWith(
                            color: ThryveColors.textSecondary,
                          ),
                          filled: true,
                          fillColor: isDark ? ThryveColors.surfaceDark : ThryveColors.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Frequency
                      Text(
                        'Frequency',
                        style: ThryveTypography.labelLarge.copyWith(
                          color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: _frequencies.map((freq) {
                          final isSelected = _selectedFrequency == freq;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setModalState(() => _selectedFrequency = freq),
                              child: Container(
                                margin: EdgeInsets.only(right: freq != 'Yearly' ? 8 : 0),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? ThryveColors.accent
                                      : (isDark ? ThryveColors.surfaceDark : ThryveColors.surface),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    freq[0], // D, W, M, Y
                                    style: ThryveTypography.titleMedium.copyWith(
                                      color: isSelected ? Colors.white : ThryveColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          _selectedFrequency,
                          style: ThryveTypography.bodyMedium.copyWith(
                            color: ThryveColors.textSecondary,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Day selector for weekly
                      if (_selectedFrequency == 'Weekly') ...[
                        Text(
                          'On which day?',
                          style: ThryveTypography.labelLarge.copyWith(
                            color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: List.generate(5, (index) {
                            final isSelected = _selectedDayOfWeek == index + 1;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () => setModalState(() => _selectedDayOfWeek = index + 1),
                                child: Container(
                                  margin: EdgeInsets.only(right: index < 4 ? 8 : 0),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? ThryveColors.accent
                                        : (isDark ? ThryveColors.surfaceDark : ThryveColors.surface),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _weekDays[index],
                                      style: ThryveTypography.labelMedium.copyWith(
                                        color: isSelected ? Colors.white : ThryveColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],

                      // Day selector for monthly
                      if (_selectedFrequency == 'Monthly') ...[
                        Text(
                          'On which day of the month?',
                          style: ThryveTypography.labelLarge.copyWith(
                            color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [1, 5, 10, 15, 20, 25].map((day) {
                            final isSelected = _selectedDayOfMonth == day;
                            return GestureDetector(
                              onTap: () => setModalState(() => _selectedDayOfMonth = day),
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? ThryveColors.accent
                                      : (isDark ? ThryveColors.surfaceDark : ThryveColors.surface),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    '$day',
                                    style: ThryveTypography.titleMedium.copyWith(
                                      color: isSelected ? Colors.white : ThryveColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],

                      const SizedBox(height: 32),

                      // Summary
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: ThryveColors.accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: ThryveColors.accent),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _getSummaryText(),
                                style: ThryveTypography.bodyMedium.copyWith(
                                  color: ThryveColors.accent,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Create button
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _selectedStock != null ? () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Auto-invest for $_selectedStock created!'),
                          backgroundColor: ThryveColors.success,
                        ),
                      );
                    } : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThryveColors.accent,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: ThryveColors.divider,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Create Auto-Invest',
                      style: ThryveTypography.button.copyWith(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getSummaryText() {
    final amount = _amountController.text.isEmpty ? '0' : _amountController.text;
    final stock = _selectedStock ?? 'selected stock';
    
    switch (_selectedFrequency) {
      case 'Daily':
        return 'Invest \$$amount in $stock every trading day';
      case 'Weekly':
        return 'Invest \$$amount in $stock every ${_weekDays[_selectedDayOfWeek - 1]}';
      case 'Monthly':
        return 'Invest \$$amount in $stock on day $_selectedDayOfMonth of each month';
      case 'Yearly':
        return 'Invest \$$amount in $stock once a year';
      default:
        return '';
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
          'Auto-Invest',
          style: ThryveTypography.titleLarge.copyWith(
            color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ThryveColors.accent,
                    ThryveColors.accentDark,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.autorenew, color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Automate Your Investing',
                              style: ThryveTypography.titleMedium.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Set it and forget it',
                              style: ThryveTypography.bodyMedium.copyWith(
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Schedule recurring investments to build wealth automatically. '
                    'Choose daily, weekly, monthly, or yearly contributions.',
                    style: ThryveTypography.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Active auto-invests
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Active Auto-Invests',
                  style: ThryveTypography.titleMedium.copyWith(
                    color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                  ),
                ),
                TextButton.icon(
                  onPressed: _showCreateAutoInvestSheet,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add New'),
                  style: TextButton.styleFrom(foregroundColor: ThryveColors.accent),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_activeAutoInvests.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: isDark ? ThryveColors.surfaceDark : ThryveColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(Icons.autorenew, size: 48, color: ThryveColors.textTertiary),
                    const SizedBox(height: 16),
                    Text(
                      'No auto-invests yet',
                      style: ThryveTypography.titleMedium.copyWith(
                        color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create your first auto-invest to start building wealth automatically',
                      style: ThryveTypography.bodyMedium.copyWith(
                        color: ThryveColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              ..._activeAutoInvests.map((autoInvest) => _buildAutoInvestCard(autoInvest, isDark)),

            const SizedBox(height: 32),

            // Benefits section
            Text(
              'Why Auto-Invest?',
              style: ThryveTypography.titleMedium.copyWith(
                color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildBenefitCard(
              Icons.trending_up,
              'Dollar-Cost Averaging',
              'Reduce the impact of volatility by investing a fixed amount regularly',
              isDark,
            ),
            _buildBenefitCard(
              Icons.psychology,
              'Remove Emotion',
              'Stay disciplined and avoid trying to time the market',
              isDark,
            ),
            _buildBenefitCard(
              Icons.rocket_launch,
              'Compound Growth',
              'Let your money grow over time with consistent contributions',
              isDark,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateAutoInvestSheet,
        backgroundColor: ThryveColors.accent,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'New Auto-Invest',
          style: ThryveTypography.button.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildAutoInvestCard(Map<String, dynamic> autoInvest, bool isDark) {
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
              color: ThryveColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                (autoInvest['symbol'] as String).substring(0, 2),
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
                  autoInvest['symbol'] as String,
                  style: ThryveTypography.titleMedium.copyWith(
                    color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                  ),
                ),
                Text(
                  '\$${autoInvest['amount']} • ${autoInvest['frequency']}',
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ThryveColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Active',
                  style: ThryveTypography.labelSmall.copyWith(
                    color: ThryveColors.success,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Next: ${autoInvest['nextDate']}',
                style: ThryveTypography.caption.copyWith(
                  color: ThryveColors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitCard(IconData icon, String title, String description, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? ThryveColors.surfaceDark : ThryveColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: ThryveColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: ThryveColors.accent, size: 20),
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
                  description,
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
  }
}
