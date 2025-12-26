import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';

/// Documents page - Access official account documents from DriveWealth
/// Includes account statements, tax documents, and trade confirmations
class DocumentsPage extends StatefulWidget {
  const DocumentsPage({super.key});

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Mock data - would come from DriveWealth API
  final List<DocumentItem> _statements = [
    DocumentItem(
      title: 'Account Statement - December 2024',
      date: DateTime(2024, 12, 31),
      type: DocumentType.statement,
    ),
    DocumentItem(
      title: 'Account Statement - November 2024',
      date: DateTime(2024, 11, 30),
      type: DocumentType.statement,
    ),
    DocumentItem(
      title: 'Account Statement - October 2024',
      date: DateTime(2024, 10, 31),
      type: DocumentType.statement,
    ),
  ];

  final List<DocumentItem> _taxDocs = [
    DocumentItem(
      title: 'W-8BEN Tax Certification',
      date: DateTime(2024, 1, 15),
      type: DocumentType.tax,
      subtitle: 'Valid until January 2027',
    ),
    DocumentItem(
      title: 'Form 1042-S - 2023',
      date: DateTime(2024, 2, 28),
      type: DocumentType.tax,
      subtitle: 'Foreign Person\'s U.S. Source Income',
    ),
  ];

  final List<DocumentItem> _confirmations = [
    DocumentItem(
      title: 'Trade Confirmation - AAPL',
      date: DateTime(2024, 12, 20),
      type: DocumentType.confirmation,
      subtitle: 'Buy 2.5 shares @ \$178.50',
    ),
    DocumentItem(
      title: 'Trade Confirmation - TSLA',
      date: DateTime(2024, 12, 18),
      type: DocumentType.confirmation,
      subtitle: 'Buy 1.0 shares @ \$245.30',
    ),
    DocumentItem(
      title: 'Trade Confirmation - MSFT',
      date: DateTime(2024, 12, 15),
      type: DocumentType.confirmation,
      subtitle: 'Sell 0.5 shares @ \$380.25',
    ),
  ];

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
          'Documents',
          style: ThryveTypography.titleLarge.copyWith(
            color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: ThryveColors.accent,
          unselectedLabelColor: ThryveColors.textSecondary,
          indicatorColor: ThryveColors.accent,
          tabs: const [
            Tab(text: 'Statements'),
            Tab(text: 'Tax'),
            Tab(text: 'Trades'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDocumentList(_statements, isDark),
          _buildDocumentList(_taxDocs, isDark),
          _buildDocumentList(_confirmations, isDark),
        ],
      ),
    );
  }

  Widget _buildDocumentList(List<DocumentItem> documents, bool isDark) {
    if (documents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open_outlined,
              size: 64,
              color: ThryveColors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'No documents yet',
              style: ThryveTypography.titleMedium.copyWith(
                color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
              ),
            ),
            Text(
              'Documents will appear here when available',
              style: ThryveTypography.bodyMedium.copyWith(
                color: ThryveColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: documents.length,
      itemBuilder: (context, index) {
        final doc = documents[index];
        return _buildDocumentCard(doc, isDark);
      },
    );
  }

  Widget _buildDocumentCard(DocumentItem doc, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? ThryveColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? ThryveColors.surfaceElevatedDark : ThryveColors.divider,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: doc.iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            doc.icon,
            color: doc.iconColor,
          ),
        ),
        title: Text(
          doc.title,
          style: ThryveTypography.titleSmall.copyWith(
            color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (doc.subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                doc.subtitle!,
                style: ThryveTypography.bodySmall.copyWith(
                  color: ThryveColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              doc.formattedDate,
              style: ThryveTypography.caption.copyWith(
                color: ThryveColors.textTertiary,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.download_outlined),
          color: ThryveColors.accent,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Downloading ${doc.title}...'),
                backgroundColor: ThryveColors.accent,
              ),
            );
          },
        ),
        onTap: () {
          // Open document viewer
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Opening ${doc.title}'),
              backgroundColor: ThryveColors.info,
            ),
          );
        },
      ),
    );
  }
}

enum DocumentType { statement, tax, confirmation }

class DocumentItem {
  final String title;
  final DateTime date;
  final DocumentType type;
  final String? subtitle;

  DocumentItem({
    required this.title,
    required this.date,
    required this.type,
    this.subtitle,
  });

  IconData get icon {
    switch (type) {
      case DocumentType.statement:
        return Icons.description_outlined;
      case DocumentType.tax:
        return Icons.receipt_long_outlined;
      case DocumentType.confirmation:
        return Icons.swap_horiz;
    }
  }

  Color get iconColor {
    switch (type) {
      case DocumentType.statement:
        return ThryveColors.info;
      case DocumentType.tax:
        return ThryveColors.warning;
      case DocumentType.confirmation:
        return ThryveColors.success;
    }
  }

  String get formattedDate {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
