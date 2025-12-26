import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';
import '../../../auth/presentation/widgets/auth_text_field.dart';

/// KYC Personal Info page - Collect user's personal details
/// Updated with DriveWealth required fields
class KycPersonalInfoPage extends StatefulWidget {
  const KycPersonalInfoPage({super.key});

  @override
  State<KycPersonalInfoPage> createState() => _KycPersonalInfoPageState();
}

class _KycPersonalInfoPageState extends State<KycPersonalInfoPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Name fields
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dobController = TextEditingController();
  
  // Address fields
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  
  // Tax fields
  final _taxIdController = TextEditingController();
  
  String? _selectedState;
  String? _selectedCountry;
  String? _selectedCitizenship;
  String? _selectedTaxCountry;
  bool _isLoading = false;
  DateTime? _selectedDate;

  // Nigerian states - default for Nigeria
  final List<String> _nigerianStates = [
    'Abia', 'Adamawa', 'Akwa Ibom', 'Anambra', 'Bauchi', 'Bayelsa', 'Benue',
    'Borno', 'Cross River', 'Delta', 'Ebonyi', 'Edo', 'Ekiti', 'Enugu', 'FCT',
    'Gombe', 'Imo', 'Jigawa', 'Kaduna', 'Kano', 'Katsina', 'Kebbi', 'Kogi',
    'Kwara', 'Lagos', 'Nasarawa', 'Niger', 'Ogun', 'Ondo', 'Osun', 'Oyo',
    'Plateau', 'Rivers', 'Sokoto', 'Taraba', 'Yobe', 'Zamfara',
  ];

  // Countries list
  final List<String> _countries = [
    'Nigeria',
    'United States',
    'United Kingdom',
    'Ghana',
    'Kenya',
    'South Africa',
    'Canada',
    'Germany',
    'France',
    'India',
    'China',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    // Default to Nigeria
    _selectedCountry = 'Nigeria';
    _selectedCitizenship = 'Nigeria';
    _selectedTaxCountry = 'Nigeria';
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dobController.dispose();
    _taxIdController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 25),
      firstDate: DateTime(1920),
      lastDate: DateTime(now.year - 18),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: ThryveColors.accent,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: ThryveColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  String get _taxIdLabel {
    if (_selectedCountry == 'Nigeria') return 'BVN (Bank Verification Number)';
    if (_selectedCountry == 'United States') return 'SSN (Social Security Number)';
    return 'Tax Identification Number (TIN)';
  }

  String get _taxIdHint {
    if (_selectedCountry == 'Nigeria') return 'Enter your 11-digit BVN';
    if (_selectedCountry == 'United States') return 'Enter your 9-digit SSN';
    return 'Enter your tax ID number';
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedState == null || _selectedCountry == null || 
          _selectedCitizenship == null || _selectedTaxCountry == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please complete all required fields'),
            backgroundColor: ThryveColors.error,
          ),
        );
        return;
      }
      
      setState(() => _isLoading = true);
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() => _isLoading = false);
          // Navigate to new investor profile page
          context.push(AppRoutes.kycInvestorProfile);
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
          'Personal Information',
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
                        'Step 1 of 5',
                        style: ThryveTypography.labelMedium.copyWith(
                          color: ThryveColors.accent,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tell us about yourself',
                        style: ThryveTypography.headlineSmall.copyWith(
                          color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This information helps us verify your identity and comply with regulations.',
                        style: ThryveTypography.bodyMedium.copyWith(
                          color: ThryveColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // First Name
                      AuthTextField(
                        controller: _firstNameController,
                        label: 'Legal First Name',
                        hint: 'As it appears on your ID',
                        prefixIcon: Icons.person_outline,
                        textCapitalization: TextCapitalization.words,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your first name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Last Name
                      AuthTextField(
                        controller: _lastNameController,
                        label: 'Legal Last Name',
                        hint: 'As it appears on your ID',
                        prefixIcon: Icons.person_outline,
                        textCapitalization: TextCapitalization.words,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your last name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Date of Birth
                      _buildDateField(isDark),
                      const SizedBox(height: 16),

                      // Citizenship
                      _buildDropdown(
                        label: 'Country of Citizenship',
                        value: _selectedCitizenship,
                        items: _countries,
                        onChanged: (v) => setState(() => _selectedCitizenship = v),
                        isDark: isDark,
                      ),
                      const SizedBox(height: 24),

                      // Section: Address
                      Text(
                        'Residential Address',
                        style: ThryveTypography.titleMedium.copyWith(
                          color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Country
                      _buildDropdown(
                        label: 'Country of Residence',
                        value: _selectedCountry,
                        items: _countries,
                        onChanged: (v) => setState(() {
                          _selectedCountry = v;
                          _selectedState = null;
                        }),
                        isDark: isDark,
                      ),
                      const SizedBox(height: 16),

                      // Street Address
                      AuthTextField(
                        controller: _addressController,
                        label: 'Street Address',
                        hint: 'Enter your street address',
                        prefixIcon: Icons.home_outlined,
                        textCapitalization: TextCapitalization.words,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // City and Postal Code row
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: AuthTextField(
                              controller: _cityController,
                              label: 'City',
                              hint: 'Enter city',
                              textCapitalization: TextCapitalization.words,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AuthTextField(
                              controller: _postalCodeController,
                              label: 'Postal Code',
                              hint: 'Code',
                              keyboardType: TextInputType.text,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // State/Province - Nigeria-specific for now
                      if (_selectedCountry == 'Nigeria')
                        _buildDropdown(
                          label: 'State',
                          value: _selectedState,
                          items: _nigerianStates,
                          onChanged: (v) => setState(() => _selectedState = v),
                          isDark: isDark,
                        ),
                      const SizedBox(height: 24),

                      // Section: Tax Information
                      Text(
                        'Tax Information',
                        style: ThryveTypography.titleMedium.copyWith(
                          color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Tax Country
                      _buildDropdown(
                        label: 'Country of Tax Residency',
                        value: _selectedTaxCountry,
                        items: _countries,
                        onChanged: (v) => setState(() => _selectedTaxCountry = v),
                        isDark: isDark,
                      ),
                      const SizedBox(height: 16),

                      // Tax ID (BVN/SSN/TIN)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AuthTextField(
                            controller: _taxIdController,
                            label: _taxIdLabel,
                            hint: _taxIdHint,
                            keyboardType: TextInputType.number,
                            prefixIcon: Icons.credit_card_outlined,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your tax ID';
                              }
                              if (_selectedCountry == 'Nigeria' && value.length != 11) {
                                return 'BVN must be 11 digits';
                              }
                              if (_selectedCountry == 'United States' && value.length != 9) {
                                return 'SSN must be 9 digits';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.lock_outline,
                                size: 14,
                                color: ThryveColors.textTertiary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Your tax information is encrypted and secure',
                                style: ThryveTypography.caption.copyWith(
                                  color: ThryveColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ],
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
                            elevation: 0,
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
                color: index < 1 ? ThryveColors.accent : ThryveColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDateField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date of Birth',
          style: ThryveTypography.labelLarge.copyWith(
            color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectDate,
          child: AbsorbPointer(
            child: TextFormField(
              controller: _dobController,
              decoration: InputDecoration(
                hintText: 'DD/MM/YYYY',
                prefixIcon: const Icon(
                  Icons.calendar_today_outlined,
                  color: ThryveColors.textSecondary,
                ),
                suffixIcon: const Icon(
                  Icons.arrow_drop_down,
                  color: ThryveColors.textSecondary,
                ),
                filled: true,
                fillColor: isDark ? ThryveColors.surfaceDark : ThryveColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select your date of birth';
                }
                return null;
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
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
      ],
    );
  }
}
