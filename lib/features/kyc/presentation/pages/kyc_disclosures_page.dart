import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';

/// KYC Disclosures page - Agreement acceptance for DriveWealth compliance
/// Must capture explicit consent before account creation
class KycDisclosuresPage extends StatefulWidget {
  const KycDisclosuresPage({super.key});

  @override
  State<KycDisclosuresPage> createState() => _KycDisclosuresPageState();
}

class _KycDisclosuresPageState extends State<KycDisclosuresPage> {
  bool _isLoading = false;

  // Disclosure acceptances
  bool _acceptAccountAgreement = false;
  bool _acceptTradingDisclosure = false;
  bool _acceptPrivacyPolicy = false;
  bool _acceptTermsOfUse = false;
  bool _acceptTaxCertification = false;
  bool _acceptRiskDisclosure = false;

  bool get _allAccepted =>
      _acceptAccountAgreement &&
      _acceptTradingDisclosure &&
      _acceptPrivacyPolicy &&
      _acceptTermsOfUse &&
      _acceptTaxCertification &&
      _acceptRiskDisclosure;

  void _handleSubmit() {
    if (!_allAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept all agreements to continue'),
          backgroundColor: ThryveColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isLoading = false);
        context.go(AppRoutes.kycPending);
      }
    });
  }

  void _showDisclosureSheet(String title, String content) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: isDark ? ThryveColors.backgroundDark : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: ThryveColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  title,
                  style: ThryveTypography.headlineSmall.copyWith(
                    color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    content,
                    style: ThryveTypography.bodyMedium.copyWith(
                      color: ThryveColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThryveColors.accent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ),
            ],
          ),
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
          'Agreements',
          style: ThryveTypography.titleLarge.copyWith(
            color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressIndicator(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Step 5 of 5',
                      style: ThryveTypography.labelMedium.copyWith(
                        color: ThryveColors.accent,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Review & Accept',
                      style: ThryveTypography.headlineSmall.copyWith(
                        color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please review and accept the following agreements to open your investment account.',
                      style: ThryveTypography.bodyMedium.copyWith(
                        color: ThryveColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Disclosures list
                    _buildDisclosureItem(
                      title: 'Customer Account Agreement',
                      description: 'Terms governing your brokerage account',
                      isAccepted: _acceptAccountAgreement,
                      onChanged: (v) => setState(() => _acceptAccountAgreement = v ?? false),
                      onRead: () => _showDisclosureSheet(
                        'Customer Account Agreement',
                        _accountAgreementContent,
                      ),
                      isDark: isDark,
                    ),
                    _buildDisclosureItem(
                      title: 'Trading Disclosure',
                      description: 'Risks and disclosures related to trading',
                      isAccepted: _acceptTradingDisclosure,
                      onChanged: (v) => setState(() => _acceptTradingDisclosure = v ?? false),
                      onRead: () => _showDisclosureSheet(
                        'Trading Disclosure',
                        _tradingDisclosureContent,
                      ),
                      isDark: isDark,
                    ),
                    _buildDisclosureItem(
                      title: 'Privacy Policy',
                      description: 'How we collect and use your information',
                      isAccepted: _acceptPrivacyPolicy,
                      onChanged: (v) => setState(() => _acceptPrivacyPolicy = v ?? false),
                      onRead: () => _showDisclosureSheet(
                        'Privacy Policy',
                        _privacyPolicyContent,
                      ),
                      isDark: isDark,
                    ),
                    _buildDisclosureItem(
                      title: 'Terms of Use',
                      description: 'Terms for using our platform',
                      isAccepted: _acceptTermsOfUse,
                      onChanged: (v) => setState(() => _acceptTermsOfUse = v ?? false),
                      onRead: () => _showDisclosureSheet(
                        'Terms of Use',
                        _termsOfUseContent,
                      ),
                      isDark: isDark,
                    ),
                    _buildDisclosureItem(
                      title: 'Tax Certification (W-8BEN)',
                      description: 'Certification of foreign status for tax purposes',
                      isAccepted: _acceptTaxCertification,
                      onChanged: (v) => setState(() => _acceptTaxCertification = v ?? false),
                      onRead: () => _showDisclosureSheet(
                        'Tax Certification',
                        _taxCertificationContent,
                      ),
                      isDark: isDark,
                    ),
                    _buildDisclosureItem(
                      title: 'Investment Risk Disclosure',
                      description: 'Understanding investment risks',
                      isAccepted: _acceptRiskDisclosure,
                      onChanged: (v) => setState(() => _acceptRiskDisclosure = v ?? false),
                      onRead: () => _showDisclosureSheet(
                        'Investment Risk Disclosure',
                        _riskDisclosureContent,
                      ),
                      isDark: isDark,
                    ),

                    const SizedBox(height: 24),

                    // Accept all toggle
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? ThryveColors.surfaceDark : ThryveColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _allAccepted ? ThryveColors.success : ThryveColors.divider,
                        ),
                      ),
                      child: Row(
                        children: [
                          Checkbox(
                            value: _allAccepted,
                            onChanged: (v) {
                              setState(() {
                                _acceptAccountAgreement = v ?? false;
                                _acceptTradingDisclosure = v ?? false;
                                _acceptPrivacyPolicy = v ?? false;
                                _acceptTermsOfUse = v ?? false;
                                _acceptTaxCertification = v ?? false;
                                _acceptRiskDisclosure = v ?? false;
                              });
                            },
                            activeColor: ThryveColors.success,
                          ),
                          Expanded(
                            child: Text(
                              'I have read and accept all agreements',
                              style: ThryveTypography.titleSmall.copyWith(
                                color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Submit button
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _allAccepted && !_isLoading ? _handleSubmit : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ThryveColors.accent,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: ThryveColors.divider,
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
                                'Submit Application',
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      height: 4,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: List.generate(5, (index) {
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: index < 4 ? 4 : 0),
              decoration: BoxDecoration(
                color: ThryveColors.accent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDisclosureItem({
    required String title,
    required String description,
    required bool isAccepted,
    required Function(bool?) onChanged,
    required VoidCallback onRead,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? ThryveColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAccepted
              ? ThryveColors.success.withValues(alpha: 0.5)
              : (isDark ? ThryveColors.surfaceElevatedDark : ThryveColors.divider),
        ),
      ),
      child: Row(
        children: [
          Checkbox(
            value: isAccepted,
            onChanged: onChanged,
            activeColor: ThryveColors.success,
          ),
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
                  style: ThryveTypography.caption.copyWith(
                    color: ThryveColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onRead,
            child: Text(
              'Read',
              style: ThryveTypography.labelMedium.copyWith(
                color: ThryveColors.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Mock content - would come from DriveWealth API
  static const String _accountAgreementContent = '''
CUSTOMER ACCOUNT AGREEMENT

This Customer Account Agreement ("Agreement") sets forth the terms and conditions governing your brokerage account with Thryve, powered by DriveWealth, LLC.

1. ACCOUNT OPENING
By opening an account, you represent that you are at least 18 years old and have the legal capacity to enter into this Agreement.

2. TRADING AUTHORIZATION
You authorize us to execute buy and sell orders on your behalf in accordance with your instructions.

3. FRACTIONAL SHARES
Your account supports fractional share trading, allowing you to invest in securities with as little as \$1.

4. SETTLEMENT
Trades generally settle on a T+2 basis (two business days after the trade date).

5. FEES AND COMMISSIONS
Please refer to our fee schedule for applicable charges.

6. ACCOUNT STATEMENTS
Monthly statements will be made available electronically through the app.

7. GOVERNING LAW
This Agreement shall be governed by the laws of the State of New Jersey, USA.
''';

  static const String _tradingDisclosureContent = '''
TRADING DISCLOSURE

IMPORTANT: Please read this disclosure carefully before trading.

RISK OF LOSS
Investing in securities involves risk of loss. You may lose some or all of your investment.

MARKET VOLATILITY
Securities prices can be highly volatile and may fluctuate significantly in short periods.

NO GUARANTEED RETURNS
Past performance is not indicative of future results. There are no guaranteed returns.

FRACTIONAL SHARES
Fractional shares may be less liquid than whole shares and may be subject to different trading conditions.

MARKET ORDERS
Market orders are executed at the best available price, which may differ from the quoted price.

EXTENDED HOURS TRADING
Trading during extended hours may involve greater risk due to lower liquidity.
''';

  static const String _privacyPolicyContent = '''
PRIVACY POLICY

We are committed to protecting your personal information.

INFORMATION WE COLLECT
- Personal identification information (name, address, date of birth)
- Financial information (income, net worth, tax identification)
- Transaction data
- Device and usage information

HOW WE USE YOUR INFORMATION
- To verify your identity
- To process transactions
- To comply with legal requirements
- To improve our services

DATA SECURITY
We employ industry-standard security measures to protect your data.

YOUR RIGHTS
You have the right to access, correct, and request deletion of your personal data.
''';

  static const String _termsOfUseContent = '''
TERMS OF USE

By using Thryve, you agree to these Terms of Use.

1. ELIGIBILITY
You must be at least 18 years old to use our services.

2. ACCOUNT SECURITY
You are responsible for maintaining the confidentiality of your login credentials.

3. PROHIBITED ACTIVITIES
You may not use our platform for any illegal activities or market manipulation.

4. INTELLECTUAL PROPERTY
All content and materials on the platform are owned by Thryve or its licensors.

5. LIMITATION OF LIABILITY
We are not liable for any losses resulting from market conditions or technical issues.

6. TERMINATION
We reserve the right to terminate accounts that violate these terms.
''';

  static const String _taxCertificationContent = '''
TAX CERTIFICATION (W-8BEN)

CERTIFICATE OF FOREIGN STATUS

As a non-U.S. person, you are required to certify your foreign status for U.S. tax purposes.

By accepting this certification, you confirm that:

1. You are not a U.S. citizen or U.S. resident alien.

2. You are the beneficial owner of the income for which this form is being provided.

3. You are not acting as an agent or intermediary.

4. The income is not effectively connected with the conduct of a trade or business in the United States.

TAX TREATY BENEFITS
If your country of residence has a tax treaty with the United States, you may be eligible for reduced withholding rates on dividends.

VALIDITY
This certification is valid for three years from the date of acceptance.
''';

  static const String _riskDisclosureContent = '''
INVESTMENT RISK DISCLOSURE

IMPORTANT: All investments involve risk.

GENERAL RISKS
- Market risk: The value of your investments may go down as well as up.
- Liquidity risk: You may not be able to sell your investments when you want to.
- Currency risk: Investments in foreign securities are subject to exchange rate fluctuations.

SPECIFIC RISKS
- Individual stocks: Can be highly volatile and may lose significant value.
- ETFs: May not perfectly track their underlying index.
- Fractional shares: May have different trading conditions than whole shares.

NO ADVICE
This platform provides execution-only services. We do not provide investment advice.

SUITABILITY
You are responsible for determining whether an investment is suitable for your circumstances.

SEEK PROFESSIONAL ADVICE
If you are unsure about the suitability of any investment, please consult a qualified financial advisor.
''';
}
