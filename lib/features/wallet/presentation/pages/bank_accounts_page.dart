import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';

/// Bank accounts page - Manage linked bank accounts
class BankAccountsPage extends StatefulWidget {
  const BankAccountsPage({super.key});

  @override
  State<BankAccountsPage> createState() => _BankAccountsPageState();
}

class _BankAccountsPageState extends State<BankAccountsPage> {
  final List<BankAccount> _accounts = [
    BankAccount(
      id: '1',
      bankName: 'GTBank',
      accountNumber: '0123456789',
      accountName: 'John Doe',
      isDefault: true,
    ),
    BankAccount(
      id: '2',
      bankName: 'Access Bank',
      accountNumber: '9876543210',
      accountName: 'John Doe',
      isDefault: false,
    ),
  ];

  void _addBankAccount() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddBankSheet(
        onAdd: (bank) {
          setState(() {
            _accounts.add(bank);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bank account added successfully'),
              backgroundColor: ThryveColors.success,
            ),
          );
        },
      ),
    );
  }

  void _setAsDefault(String id) {
    setState(() {
      for (var account in _accounts) {
        account.isDefault = account.id == id;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Default bank account updated'),
        backgroundColor: ThryveColors.success,
      ),
    );
  }

  void _deleteAccount(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Remove Bank Account'),
        content: const Text('Are you sure you want to remove this bank account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _accounts.removeWhere((a) => a.id == id);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Bank account removed'),
                  backgroundColor: ThryveColors.error,
                ),
              );
            },
            child: Text('Remove', style: TextStyle(color: ThryveColors.error)),
          ),
        ],
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
          'Bank Accounts',
          style: ThryveTypography.titleLarge.copyWith(
            color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: _accounts.isEmpty
          ? _buildEmptyState(isDark)
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: _accounts.length + 1,
              itemBuilder: (context, index) {
                if (index == _accounts.length) {
                  return _buildAddButton();
                }
                return _buildAccountCard(_accounts[index], isDark);
              },
            ),
      floatingActionButton: _accounts.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _addBankAccount,
              backgroundColor: ThryveColors.accent,
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                'Add Bank',
                style: ThryveTypography.labelLarge.copyWith(color: Colors.white),
              ),
            )
          : null,
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
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
                Icons.account_balance_outlined,
                size: 64,
                color: ThryveColors.accent,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Bank Accounts',
              style: ThryveTypography.titleLarge.copyWith(
                color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add a bank account to withdraw your funds',
              style: ThryveTypography.bodyMedium.copyWith(
                color: ThryveColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _addBankAccount,
              icon: const Icon(Icons.add),
              label: const Text('Add Bank Account'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ThryveColors.accent,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountCard(BankAccount account, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? ThryveColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: account.isDefault
              ? ThryveColors.accent
              : (isDark ? ThryveColors.surfaceElevatedDark : ThryveColors.divider),
          width: account.isDefault ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
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
                      Row(
                        children: [
                          Text(
                            account.bankName,
                            style: ThryveTypography.titleSmall.copyWith(
                              color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                            ),
                          ),
                          if (account.isDefault) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: ThryveColors.accent.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Default',
                                style: ThryveTypography.labelSmall.copyWith(color: ThryveColors.accent),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        '${account.accountNumber.substring(0, 4)}****${account.accountNumber.substring(account.accountNumber.length - 2)}',
                        style: ThryveTypography.bodySmall.copyWith(color: ThryveColors.textSecondary),
                      ),
                      Text(
                        account.accountName,
                        style: ThryveTypography.bodySmall.copyWith(color: ThryveColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                  ),
                  onSelected: (value) {
                    if (value == 'default') {
                      _setAsDefault(account.id);
                    } else if (value == 'delete') {
                      _deleteAccount(account.id);
                    }
                  },
                  itemBuilder: (context) => [
                    if (!account.isDefault)
                      const PopupMenuItem(
                        value: 'default',
                        child: Row(
                          children: [
                            Icon(Icons.star_outline, size: 20),
                            SizedBox(width: 8),
                            Text('Set as Default'),
                          ],
                        ),
                      ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, size: 20, color: ThryveColors.error),
                          const SizedBox(width: 8),
                          Text('Remove', style: TextStyle(color: ThryveColors.error)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return const SizedBox(height: 80); // Space for FAB
  }
}

class BankAccount {
  final String id;
  final String bankName;
  final String accountNumber;
  final String accountName;
  bool isDefault;

  BankAccount({
    required this.id,
    required this.bankName,
    required this.accountNumber,
    required this.accountName,
    this.isDefault = false,
  });
}

class _AddBankSheet extends StatefulWidget {
  final Function(BankAccount) onAdd;

  const _AddBankSheet({required this.onAdd});

  @override
  State<_AddBankSheet> createState() => _AddBankSheetState();
}

class _AddBankSheetState extends State<_AddBankSheet> {
  final _accountNumberController = TextEditingController();
  String? _selectedBank;
  bool _isVerifying = false;
  bool _isVerified = false;
  String? _accountName;

  final List<String> _banks = [
    'Access Bank',
    'First Bank',
    'GTBank',
    'Zenith Bank',
    'UBA',
    'Stanbic IBTC',
    'Fidelity Bank',
    'Sterling Bank',
    'Unity Bank',
    'Wema Bank',
  ];

  void _verifyAccount() {
    if (_selectedBank != null && _accountNumberController.text.length == 10) {
      setState(() => _isVerifying = true);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isVerifying = false;
            _isVerified = true;
            _accountName = 'John Doe';
          });
        }
      });
    }
  }

  void _addAccount() {
    if (_isVerified && _selectedBank != null) {
      final account = BankAccount(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        bankName: _selectedBank!,
        accountNumber: _accountNumberController.text,
        accountName: _accountName!,
      );
      widget.onAdd(account);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: isDark ? ThryveColors.backgroundDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: ThryveColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Add Bank Account',
            style: ThryveTypography.headlineSmall.copyWith(
              color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Bank dropdown
          DropdownButtonFormField<String>(
            value: _selectedBank,
            decoration: InputDecoration(
              labelText: 'Select Bank',
              filled: true,
              fillColor: isDark ? ThryveColors.surfaceDark : ThryveColors.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            items: _banks.map((bank) {
              return DropdownMenuItem(value: bank, child: Text(bank));
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedBank = value;
                _isVerified = false;
              });
            },
          ),
          const SizedBox(height: 16),

          // Account number
          TextField(
            controller: _accountNumberController,
            keyboardType: TextInputType.number,
            maxLength: 10,
            decoration: InputDecoration(
              labelText: 'Account Number',
              filled: true,
              fillColor: isDark ? ThryveColors.surfaceDark : ThryveColors.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              counterText: '',
              suffixIcon: _isVerifying
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.check_circle_outline),
                      onPressed: _verifyAccount,
                    ),
            ),
            onChanged: (value) {
              if (value.length == 10 && _selectedBank != null) {
                _verifyAccount();
              }
            },
          ),

          // Verified account name
          if (_isVerified && _accountName != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ThryveColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ThryveColors.success.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: ThryveColors.success),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Account Verified',
                        style: ThryveTypography.labelMedium.copyWith(color: ThryveColors.success),
                      ),
                      Text(
                        _accountName!,
                        style: ThryveTypography.titleSmall.copyWith(
                          color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),

          // Add button
          ElevatedButton(
            onPressed: _isVerified ? _addAccount : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: ThryveColors.accent,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'Add Bank Account',
              style: ThryveTypography.button.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
