import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';

/// KYC Documents page - Upload ID and selfie for verification
class KycDocumentsPage extends StatefulWidget {
  const KycDocumentsPage({super.key});

  @override
  State<KycDocumentsPage> createState() => _KycDocumentsPageState();
}

class _KycDocumentsPageState extends State<KycDocumentsPage> {
  String? _selectedIdType;
  bool _idUploaded = false;
  bool _selfieUploaded = false;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _idTypes = [
    {'value': 'nin', 'label': 'National ID (NIN)', 'icon': Icons.badge},
    {'value': 'passport', 'label': 'International Passport', 'icon': Icons.menu_book},
    {'value': 'drivers', 'label': "Driver's License", 'icon': Icons.drive_eta},
    {'value': 'voters', 'label': "Voter's Card", 'icon': Icons.how_to_vote},
  ];

  void _handleIdUpload() {
    // TODO: Implement actual image picker
    setState(() => _idUploaded = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ID document uploaded successfully'),
        backgroundColor: ThryveColors.success,
      ),
    );
  }

  void _handleSelfieCapture() {
    // TODO: Implement actual camera capture
    setState(() => _selfieUploaded = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Selfie captured successfully'),
        backgroundColor: ThryveColors.success,
      ),
    );
  }

  void _handleSubmit() {
    if (_selectedIdType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an ID type'),
          backgroundColor: ThryveColors.error,
        ),
      );
      return;
    }
    
    if (!_idUploaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload your ID document'),
          backgroundColor: ThryveColors.error,
        ),
      );
      return;
    }
    
    if (!_selfieUploaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please take a selfie'),
          backgroundColor: ThryveColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    // TODO: Implement actual submission
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isLoading = false);
        context.push(AppRoutes.kycPending);
      }
    });
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
          'Document Verification',
          style: ThryveTypography.titleLarge.copyWith(
            color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            _buildProgressIndicator(),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Step indicator
                    Text(
                      'Step 2 of 3',
                      style: ThryveTypography.labelMedium.copyWith(
                        color: ThryveColors.accent,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Upload your documents',
                      style: ThryveTypography.headlineSmall.copyWith(
                        color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'We need a valid government-issued ID and a selfie to verify your identity.',
                      style: ThryveTypography.bodyMedium.copyWith(
                        color: ThryveColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ID Type Selection
                    Text(
                      'Select ID Type',
                      style: ThryveTypography.labelLarge.copyWith(
                        color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _idTypes.map((type) {
                        final isSelected = _selectedIdType == type['value'];
                        return GestureDetector(
                          onTap: () {
                            setState(() => _selectedIdType = type['value']);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? ThryveColors.accent.withValues(alpha: 0.1)
                                  : (isDark ? ThryveColors.surfaceDark : ThryveColors.surface),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? ThryveColors.accent
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  type['icon'] as IconData,
                                  size: 20,
                                  color: isSelected
                                      ? ThryveColors.accent
                                      : ThryveColors.textSecondary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  type['label'] as String,
                                  style: ThryveTypography.labelMedium.copyWith(
                                    color: isSelected
                                        ? ThryveColors.accent
                                        : (isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),

                    // ID Upload
                    _buildUploadCard(
                      isDark: isDark,
                      title: 'Upload ID Document',
                      subtitle: 'Take a clear photo of your ${_selectedIdType != null ? _getIdTypeLabel(_selectedIdType!) : 'ID'}',
                      icon: Icons.badge_outlined,
                      isUploaded: _idUploaded,
                      onTap: _handleIdUpload,
                    ),
                    const SizedBox(height: 16),

                    // Selfie Capture
                    _buildUploadCard(
                      isDark: isDark,
                      title: 'Take a Selfie',
                      subtitle: 'We\'ll match your face with your ID',
                      icon: Icons.face,
                      isUploaded: _selfieUploaded,
                      onTap: _handleSelfieCapture,
                    ),
                    const SizedBox(height: 24),

                    // Tips
                    _buildTips(isDark),
                    const SizedBox(height: 32),

                    // Submit button
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
                                'Submit for Verification',
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

  String _getIdTypeLabel(String value) {
    final type = _idTypes.firstWhere(
      (t) => t['value'] == value,
      orElse: () => {'label': 'ID'},
    );
    return type['label'] as String;
  }

  Widget _buildUploadCard({
    required bool isDark,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isUploaded,
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
            color: isUploaded ? ThryveColors.success : ThryveColors.divider,
            width: isUploaded ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isUploaded
                    ? ThryveColors.success.withValues(alpha: 0.1)
                    : ThryveColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isUploaded ? Icons.check_circle : icon,
                size: 28,
                color: isUploaded ? ThryveColors.success : ThryveColors.accent,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: ThryveTypography.titleMedium.copyWith(
                      color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isUploaded ? 'Uploaded successfully' : subtitle,
                    style: ThryveTypography.bodySmall.copyWith(
                      color: isUploaded ? ThryveColors.success : ThryveColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isUploaded ? Icons.edit : Icons.camera_alt_outlined,
              color: ThryveColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTips(bool isDark) {
    return Container(
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
              const Icon(
                Icons.lightbulb_outline,
                color: ThryveColors.warning,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Tips for a successful upload',
                style: ThryveTypography.labelLarge.copyWith(
                  color: ThryveColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTipItem('Make sure your ID is not expired'),
          _buildTipItem('Ensure all corners of the ID are visible'),
          _buildTipItem('Take photos in good lighting'),
          _buildTipItem('Remove glasses for your selfie'),
        ],
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(
              Icons.circle,
              size: 6,
              color: ThryveColors.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: ThryveTypography.bodySmall.copyWith(
                color: ThryveColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      height: 4,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: ThryveColors.accent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: ThryveColors.accent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: ThryveColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
