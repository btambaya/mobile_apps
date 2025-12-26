import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';

/// KYC Investor Profile page - Collect employment and financial details
/// Required by DriveWealth for investor suitability assessment
class KycInvestorProfilePage extends StatefulWidget {
  const KycInvestorProfilePage({super.key});

  @override
  State<KycInvestorProfilePage> createState() => _KycInvestorProfilePageState();
}

class _KycInvestorProfilePageState extends State<KycInvestorProfilePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Employment
  String? _employmentStatus;
  final _employerController = TextEditingController();
  final _occupationController = TextEditingController();

  // Financial
  String? _annualIncome;
  String? _totalNetWorth;
  String? _liquidNetWorth;

  // Investment
  String? _investmentExperience;
  String? _investmentObjective;
  String? _riskTolerance;

  final List<String> _employmentOptions = [
    'Employed',
    'Self-Employed',
    'Unemployed',
    'Retired',
    'Student',
  ];

  final List<String> _incomeRanges = [
    'Less than \$25,000',
    '\$25,000 - \$50,000',
    '\$50,000 - \$100,000',
    '\$100,000 - \$250,000',
    '\$250,000 - \$500,000',
    'More than \$500,000',
  ];

  final List<String> _netWorthRanges = [
    'Less than \$50,000',
    '\$50,000 - \$100,000',
    '\$100,000 - \$250,000',
    '\$250,000 - \$500,000',
    '\$500,000 - \$1,000,000',
    'More than \$1,000,000',
  ];

  final List<String> _experienceOptions = [
    'None',
    'Limited (1-2 years)',
    'Moderate (3-5 years)',
    'Extensive (5+ years)',
  ];

  final List<String> _objectiveOptions = [
    'Capital Preservation',
    'Income',
    'Growth',
    'Speculation',
  ];

  final List<String> _riskOptions = [
    'Conservative',
    'Moderate',
    'Aggressive',
  ];

  @override
  void dispose() {
    _employerController.dispose();
    _occupationController.dispose();
    super.dispose();
  }

  bool get _showEmployerFields =>
      _employmentStatus == 'Employed' || _employmentStatus == 'Self-Employed';

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      // Validate all selections
      if (_employmentStatus == null ||
          _annualIncome == null ||
          _totalNetWorth == null ||
          _liquidNetWorth == null ||
          _investmentExperience == null ||
          _investmentObjective == null ||
          _riskTolerance == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please complete all fields'),
            backgroundColor: ThryveColors.error,
          ),
        );
        return;
      }

      setState(() => _isLoading = true);
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() => _isLoading = false);
          context.push(AppRoutes.kycDocuments);
        }
      });
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
          'Investor Profile',
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Step 2 of 5',
                        style: ThryveTypography.labelMedium.copyWith(
                          color: ThryveColors.accent,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your Financial Profile',
                        style: ThryveTypography.headlineSmall.copyWith(
                          color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This information helps us provide suitable investment options.',
                        style: ThryveTypography.bodyMedium.copyWith(
                          color: ThryveColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Employment Section
                      _buildSectionTitle('Employment Information', isDark),
                      const SizedBox(height: 16),
                      _buildDropdown(
                        label: 'Employment Status',
                        value: _employmentStatus,
                        items: _employmentOptions,
                        onChanged: (v) => setState(() => _employmentStatus = v),
                        isDark: isDark,
                      ),

                      if (_showEmployerFields) ...[
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _employerController,
                          label: 'Employer Name',
                          hint: 'Enter your employer name',
                          isDark: isDark,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _occupationController,
                          label: 'Occupation/Title',
                          hint: 'Enter your job title',
                          isDark: isDark,
                        ),
                      ],

                      const SizedBox(height: 32),

                      // Financial Section
                      _buildSectionTitle('Financial Information', isDark),
                      const SizedBox(height: 16),
                      _buildDropdown(
                        label: 'Annual Income',
                        value: _annualIncome,
                        items: _incomeRanges,
                        onChanged: (v) => setState(() => _annualIncome = v),
                        isDark: isDark,
                      ),
                      const SizedBox(height: 16),
                      _buildDropdown(
                        label: 'Total Net Worth',
                        value: _totalNetWorth,
                        items: _netWorthRanges,
                        onChanged: (v) => setState(() => _totalNetWorth = v),
                        isDark: isDark,
                      ),
                      const SizedBox(height: 16),
                      _buildDropdown(
                        label: 'Liquid Net Worth',
                        value: _liquidNetWorth,
                        items: _netWorthRanges,
                        onChanged: (v) => setState(() => _liquidNetWorth = v),
                        isDark: isDark,
                        helperText: 'Cash and easily convertible assets',
                      ),

                      const SizedBox(height: 32),

                      // Investment Section
                      _buildSectionTitle('Investment Experience', isDark),
                      const SizedBox(height: 16),
                      _buildDropdown(
                        label: 'Investment Experience',
                        value: _investmentExperience,
                        items: _experienceOptions,
                        onChanged: (v) => setState(() => _investmentExperience = v),
                        isDark: isDark,
                      ),
                      const SizedBox(height: 16),
                      _buildDropdown(
                        label: 'Investment Objective',
                        value: _investmentObjective,
                        items: _objectiveOptions,
                        onChanged: (v) => setState(() => _investmentObjective = v),
                        isDark: isDark,
                      ),
                      const SizedBox(height: 16),
                      _buildDropdown(
                        label: 'Risk Tolerance',
                        value: _riskTolerance,
                        items: _riskOptions,
                        onChanged: (v) => setState(() => _riskTolerance = v),
                        isDark: isDark,
                      ),

                      const SizedBox(height: 32),

                      // Continue button
                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleSubmit,
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
                                  'Continue',
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
                color: index < 2 ? ThryveColors.accent : ThryveColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: ThryveTypography.titleMedium.copyWith(
        color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required bool isDark,
    String? helperText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: ThryveTypography.labelLarge.copyWith(
            color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            hintText: 'Select $label',
            filled: true,
            fillColor: isDark ? ThryveColors.surfaceDark : ThryveColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          items: items.map((item) {
            return DropdownMenuItem(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
        ),
        if (helperText != null) ...[
          const SizedBox(height: 4),
          Text(
            helperText,
            style: ThryveTypography.caption.copyWith(
              color: ThryveColors.textTertiary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: ThryveTypography.labelLarge.copyWith(
            color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: isDark ? ThryveColors.surfaceDark : ThryveColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (value) {
            if (_showEmployerFields && (value == null || value.isEmpty)) {
              return 'This field is required';
            }
            return null;
          },
        ),
      ],
    );
  }
}
