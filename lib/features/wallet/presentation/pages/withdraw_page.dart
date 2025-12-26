import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';

/// Withdraw page - Withdraw funds to bank account
class WithdrawPage extends StatefulWidget {
  const WithdrawPage({super.key});

  @override
  State<WithdrawPage> createState() => _WithdrawPageState();
}

class _WithdrawPageState extends State<WithdrawPage> {
  final _amountController = TextEditingController();
  String? _selectedBank;
  bool _isLoading = false;

  // Mock bank accounts
  final List<Map<String, String>> _bankAccounts = [
    {'id': '1', 'bank': 'GTBank', 'number': '****4532', 'name': 'John Doe'},
    {'id': '2', 'bank': 'Access Bank', 'number': '****7821', 'name': 'John Doe'},
  ];

  final double _availableBalance = 1250.45;

  double get _ngnEquivalent {
    final usd = double.tryParse(_amountController.text) ?? 0;
    return usd * 1587.30; // Mock exchange rate
  }

  void _handleWithdraw() {
    final amount = double.tryParse(_amountController.text) ?? 0;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount'),
          backgroundColor: ThryveColors.error,
        ),
      );
      return;
    }

    if (amount > _availableBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Insufficient balance'),
          backgroundColor: ThryveColors.error,
        ),
      );
      return;
    }

    if (_selectedBank == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a bank account'),
          backgroundColor: ThryveColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSuccessDialog();
      }
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: ThryveColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 48,
                color: ThryveColors.success,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Withdrawal Initiated!',
              style: ThryveTypography.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Your withdrawal of \$${_amountController.text} is being processed. Funds will arrive within 24 hours.',
              style: ThryveTypography.bodyMedium.copyWith(
                color: ThryveColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThryveColors.accent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
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
          'Withdraw',
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
            // Available balance
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? ThryveColors.surfaceDark : ThryveColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    'Available Balance',
                    style: ThryveTypography.bodyMedium.copyWith(
                      color: ThryveColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$$_availableBalance',
                    style: ThryveTypography.headlineLarge.copyWith(
                      color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Amount input
            Text(
              'Withdrawal Amount (USD)',
              style: ThryveTypography.labelLarge.copyWith(
                color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              onChanged: (value) => setState(() {}),
              style: ThryveTypography.displaySmall.copyWith(
                color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
              ),
              decoration: InputDecoration(
                prefixText: '\$ ',
                prefixStyle: ThryveTypography.displaySmall.copyWith(
                  color: ThryveColors.textSecondary,
                ),
                hintText: '0',
                filled: true,
                fillColor: isDark ? ThryveColors.surfaceDark : ThryveColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: TextButton(
                  onPressed: () {
                    _amountController.text = _availableBalance.toString();
                    setState(() {});
                  },
                  child: Text(
                    'MAX',
                    style: ThryveTypography.labelLarge.copyWith(
                      color: ThryveColors.accent,
                    ),
                  ),
                ),
              ),
            ),
            if (_amountController.text.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                '≈ ₦${_formatNumber(_ngnEquivalent.round())}',
                style: ThryveTypography.bodyMedium.copyWith(
                  color: ThryveColors.accent,
                ),
              ),
            ],
            const SizedBox(height: 32),

            // Bank account selection
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Bank Account',
                  style: ThryveTypography.labelLarge.copyWith(
                    color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showAddBankSheet(),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add New'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._bankAccounts.map((bank) => _buildBankOption(bank, isDark)),
            const SizedBox(height: 24),

            // Fees info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ThryveColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: ThryveColors.warning, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Processing Time',
                        style: ThryveTypography.labelLarge.copyWith(
                          color: ThryveColors.warning,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Withdrawals usually take 1-3 business days. Settlement time may vary depending on your bank.',
                    style: ThryveTypography.bodySmall.copyWith(
                      color: ThryveColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Withdraw button
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleWithdraw,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThryveColors.accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Withdraw Funds',
                        style: ThryveTypography.button.copyWith(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankOption(Map<String, String> bank, bool isDark) {
    final isSelected = _selectedBank == bank['id'];

    return GestureDetector(
      onTap: () => setState(() => _selectedBank = bank['id']),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? ThryveColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? ThryveColors.accent : ThryveColors.divider,
            width: isSelected ? 2 : 1,
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
              child: const Icon(Icons.account_balance, color: ThryveColors.accent),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bank['bank']!,
                    style: ThryveTypography.titleSmall.copyWith(
                      color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${bank['number']} • ${bank['name']}',
                    style: ThryveTypography.bodySmall.copyWith(
                      color: ThryveColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: bank['id']!,
              groupValue: _selectedBank,
              onChanged: (value) => setState(() => _selectedBank = value),
              activeColor: ThryveColors.accent,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddBankSheet() {
    // Navigate to bank accounts page
    Navigator.pop(context);
    context.push(AppRoutes.bankAccounts);
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}
