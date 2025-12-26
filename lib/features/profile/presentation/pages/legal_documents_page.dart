import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';

/// Legal Documents page - Terms and Privacy Policy
class LegalDocumentsPage extends StatelessWidget {
  const LegalDocumentsPage({super.key});

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
          'Legal Documents',
          style: ThryveTypography.titleLarge.copyWith(
            color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDocumentCard(
              context: context,
              isDark: isDark,
              icon: Icons.article_outlined,
              title: 'Terms of Service',
              description: 'Our terms and conditions for using Thryve',
              lastUpdated: 'Last updated: December 2024',
              onTap: () => _showDocument(context, 'Terms of Service', _termsOfService),
            ),
            const SizedBox(height: 16),
            _buildDocumentCard(
              context: context,
              isDark: isDark,
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              description: 'How we collect, use, and protect your data',
              lastUpdated: 'Last updated: December 2024',
              onTap: () => _showDocument(context, 'Privacy Policy', _privacyPolicy),
            ),
            const SizedBox(height: 16),
            _buildDocumentCard(
              context: context,
              isDark: isDark,
              icon: Icons.security_outlined,
              title: 'Risk Disclosure',
              description: 'Important information about investment risks',
              lastUpdated: 'Last updated: December 2024',
              onTap: () => _showDocument(context, 'Risk Disclosure', _riskDisclosure),
            ),
            const SizedBox(height: 16),
            _buildDocumentCard(
              context: context,
              isDark: isDark,
              icon: Icons.gavel_outlined,
              title: 'Regulatory Information',
              description: 'Our licenses and regulatory compliance',
              lastUpdated: 'Last updated: December 2024',
              onTap: () => _showDocument(context, 'Regulatory Information', _regulatoryInfo),
            ),
            const SizedBox(height: 32),
            Center(
              child: Text(
                'If you have questions about these documents,\nplease contact support@thryve.app',
                style: ThryveTypography.bodySmall.copyWith(
                  color: ThryveColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentCard({
    required BuildContext context,
    required bool isDark,
    required IconData icon,
    required String title,
    required String description,
    required String lastUpdated,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
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
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: ThryveTypography.bodySmall.copyWith(
                      color: ThryveColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastUpdated,
                    style: ThryveTypography.caption.copyWith(
                      color: ThryveColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: ThryveColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  void _showDocument(BuildContext context, String title, String content) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: isDark ? ThryveColors.backgroundDark : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: ThryveColors.divider,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(title, style: ThryveTypography.titleLarge),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    content,
                    style: ThryveTypography.bodyMedium.copyWith(
                      color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                      height: 1.6,
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

  static const String _termsOfService = '''
TERMS OF SERVICE

Effective Date: December 2024

Welcome to Thryve. These Terms of Service ("Terms") govern your use of the Thryve mobile application and related services.

1. ACCEPTANCE OF TERMS
By accessing or using Thryve, you agree to be bound by these Terms. If you do not agree, please do not use our services.

2. ELIGIBILITY
You must be at least 18 years old and a resident of Nigeria to use Thryve. You must complete our identity verification (KYC) process before trading.

3. ACCOUNT REGISTRATION
You agree to provide accurate information during registration and to keep your account credentials secure. You are responsible for all activity under your account.

4. BROKERAGE SERVICES
Thryve provides access to US securities through our partner broker, DriveWealth LLC, a member of FINRA and SIPC. All trades are executed by DriveWealth.

5. INVESTMENT RISKS
All investments carry risk. The value of your investments can go up or down. Past performance is not indicative of future results. You should only invest money you can afford to lose.

6. FEES AND CHARGES
Thryve may charge fees for certain services. All fees will be clearly disclosed before you incur them. Currency conversion fees apply to deposits and withdrawals.

7. DEPOSITS AND WITHDRAWALS
Deposits are processed through our payment partners. Withdrawals are typically processed within 1-3 business days. We reserve the right to delay withdrawals for security or compliance reasons.

8. PROHIBITED ACTIVITIES
You may not use Thryve for money laundering, fraud, or any illegal activity. We may suspend or terminate accounts that violate these Terms.

9. LIMITATION OF LIABILITY
Thryve is not liable for any losses resulting from market conditions, system outages, or your investment decisions.

10. CHANGES TO TERMS
We may update these Terms from time to time. Continued use of Thryve after changes constitutes acceptance.

11. CONTACT
For questions about these Terms, contact us at legal@thryve.app
''';

  static const String _privacyPolicy = '''
PRIVACY POLICY

Effective Date: December 2024

Thryve ("we", "our", or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, and safeguard your information.

1. INFORMATION WE COLLECT
- Personal Information: Name, email, phone number, date of birth, address
- Identity Documents: Government ID, BVN, selfie photos for verification
- Financial Information: Bank account details, transaction history
- Device Information: IP address, device type, operating system

2. HOW WE USE YOUR INFORMATION
- To verify your identity and comply with regulations
- To process transactions and provide our services
- To communicate with you about your account
- To improve our products and services
- To prevent fraud and ensure security

3. INFORMATION SHARING
We share your information with:
- DriveWealth LLC (our brokerage partner)
- Payment processors (Paystack, Flutterwave)
- Identity verification services
- Regulatory authorities as required by law

We do not sell your personal information to third parties.

4. DATA SECURITY
We use industry-standard encryption and security measures to protect your data. However, no system is completely secure.

5. DATA RETENTION
We retain your information as long as your account is active or as required by law. You can request deletion of your account by contacting support.

6. YOUR RIGHTS
You have the right to:
- Access your personal information
- Request correction of inaccurate data
- Request deletion of your data (subject to legal requirements)
- Opt out of marketing communications

7. COOKIES AND TRACKING
Our app may use analytics to improve user experience. You can manage app permissions through your device settings.

8. CHILDREN'S PRIVACY
Thryve is not intended for users under 18. We do not knowingly collect information from children.

9. CHANGES TO THIS POLICY
We may update this Privacy Policy periodically. We will notify you of significant changes.

10. CONTACT US
For privacy-related inquiries: privacy@thryve.app
''';

  static const String _riskDisclosure = '''
RISK DISCLOSURE STATEMENT

IMPORTANT: Please read this document carefully before investing.

GENERAL INVESTMENT RISKS

Investing in securities involves risk. You could lose some or all of your investment. Before investing, consider the following:

1. MARKET RISK
The value of securities can fluctuate based on market conditions, economic factors, and company performance. There is no guarantee that investments will increase in value.

2. CURRENCY RISK
When you invest in US securities using Nigerian Naira, you are exposed to exchange rate fluctuations. Changes in the USD/NGN exchange rate can affect your returns.

3. LIQUIDITY RISK
Some securities may be difficult to sell quickly at a fair price. You may not be able to sell your investments when you want or at the price you expect.

4. REGULATORY RISK
Changes in laws or regulations could affect your investments or our ability to provide services.

5. TECHNOLOGY RISK
System failures, cyber attacks, or other technical issues could disrupt trading or affect your account.

6. NO GUARANTEE OF RETURNS
Past performance is not indicative of future results. There is no guarantee that you will achieve your investment goals.

FRACTIONAL SHARES
Fractional shares may have limited liquidity and may not be transferable to other brokers.

IMPORTANT REMINDERS
- Only invest money you can afford to lose
- Diversify your investments to spread risk
- Consider your investment timeline and goals
- Seek professional advice if unsure

By using Thryve, you acknowledge that you understand these risks.
''';

  static const String _regulatoryInfo = '''
REGULATORY INFORMATION

ABOUT THRYVE
Thryve is a fintech platform that provides Nigerian users access to US securities markets.

BROKERAGE SERVICES
Brokerage services are provided by DriveWealth LLC, a registered broker-dealer and member of:
- Financial Industry Regulatory Authority (FINRA)
- Securities Investor Protection Corporation (SIPC)

Your securities and cash are held in your name at DriveWealth. SIPC protects securities up to \$500,000 (including \$250,000 for cash claims).

PAYMENT SERVICES
Payment processing is handled by licensed payment providers:
- Paystack (licensed by CBN)
- Flutterwave (licensed by CBN)

DATA PROTECTION
We comply with the Nigeria Data Protection Regulation (NDPR) and implement appropriate data protection measures.

NOT INVESTMENT ADVICE
Thryve does not provide investment advice. Information on our platform is for educational purposes only and should not be considered investment recommendations.

COMPLAINTS
If you have a complaint:
1. Contact us at support@thryve.app
2. We will respond within 48 hours
3. If unresolved, you may escalate to DriveWealth or relevant regulatory bodies

CONTACT
Thryve Support: support@thryve.app
DriveWealth: support@drivewealth.com
''';
}
