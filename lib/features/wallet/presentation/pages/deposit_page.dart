import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';

/// Deposit page - Fund account via Paystack
class DepositPage extends StatefulWidget {
  const DepositPage({super.key});

  @override
  State<DepositPage> createState() => _DepositPageState();
}

class _DepositPageState extends State<DepositPage> {
  final _amountController = TextEditingController();
  String _selectedPaymentMethod = 'card';
  bool _isLoading = false;

  final List<Map<String, dynamic>> _suggestedAmounts = [
    {'ngn': 10000, 'usd': 6.30},
    {'ngn': 25000, 'usd': 15.75},
    {'ngn': 50000, 'usd': 31.50},
    {'ngn': 100000, 'usd': 63.00},
  ];

  void _selectAmount(int amount) {
    _amountController.text = amount.toString();
    setState(() {});
  }

  double get _usdEquivalent {
    final ngn = double.tryParse(_amountController.text) ?? 0;
    return ngn * 0.00063; // Mock exchange rate
  }

  void _handleDeposit() {
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an amount'),
          backgroundColor: ThryveColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    // TODO: Implement Paystack payment
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
              'Deposit Successful!',
              style: ThryveTypography.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              '₦${_amountController.text} has been deposited to your account.',
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
          'Deposit',
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
            // Amount input
            Text(
              'Enter Amount (NGN)',
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
                prefixText: '₦ ',
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
              ),
            ),
            if (_amountController.text.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                '≈ \$${_usdEquivalent.toStringAsFixed(2)} USD',
                style: ThryveTypography.bodyMedium.copyWith(
                  color: ThryveColors.accent,
                ),
              ),
            ],
            const SizedBox(height: 24),

            // Suggested amounts
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _suggestedAmounts.map((amount) {
                final ngn = amount['ngn'] as int;
                final isSelected = _amountController.text == ngn.toString();
                return GestureDetector(
                  onTap: () => _selectAmount(ngn),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                    child: Column(
                      children: [
                        Text(
                          '₦${_formatNumber(ngn)}',
                          style: ThryveTypography.titleSmall.copyWith(
                            color: isSelected
                                ? ThryveColors.accent
                                : (isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary),
                          ),
                        ),
                        Text(
                          '≈ \$${amount['usd']}',
                          style: ThryveTypography.bodySmall.copyWith(
                            color: ThryveColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // Payment method
            Text(
              'Payment Method',
              style: ThryveTypography.labelLarge.copyWith(
                color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildPaymentMethod(
              isDark: isDark,
              id: 'card',
              title: 'Card Payment',
              subtitle: 'Visa, Mastercard, Verve',
              icon: Icons.credit_card,
            ),
            const SizedBox(height: 12),
            _buildPaymentMethod(
              isDark: isDark,
              id: 'bank',
              title: 'Bank Transfer',
              subtitle: 'Pay via bank transfer',
              icon: Icons.account_balance,
            ),
            const SizedBox(height: 32),

            // Security note
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ThryveColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock_outline, color: ThryveColors.info, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your payment is secured by Paystack',
                      style: ThryveTypography.bodySmall.copyWith(
                        color: ThryveColors.info,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Deposit button
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleDeposit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThryveColors.success,
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
                        'Continue to Payment',
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

  Widget _buildPaymentMethod({
    required bool isDark,
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedPaymentMethod == id;

    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = id),
      child: Container(
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
              child: Icon(icon, color: ThryveColors.accent),
            ),
            const SizedBox(width: 16),
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
                    subtitle,
                    style: ThryveTypography.bodySmall.copyWith(
                      color: ThryveColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: id,
              groupValue: _selectedPaymentMethod,
              onChanged: (value) => setState(() => _selectedPaymentMethod = value!),
              activeColor: ThryveColors.accent,
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}
