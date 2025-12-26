import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';

/// Trade page - Stock search and discovery
class TradePage extends StatefulWidget {
  const TradePage({super.key});

  @override
  State<TradePage> createState() => _TradePageState();
}

class _TradePageState extends State<TradePage> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'All';

  final List<String> _categories = ['All', 'Tech', 'Finance', 'Healthcare', 'Energy', 'Consumer'];

  final List<Map<String, dynamic>> _popularStocks = [
    {'symbol': 'AAPL', 'name': 'Apple Inc.', 'price': '\$178.72', 'change': '+2.34%', 'isUp': true, 'category': 'Tech'},
    {'symbol': 'MSFT', 'name': 'Microsoft Corporation', 'price': '\$378.91', 'change': '+1.87%', 'isUp': true, 'category': 'Tech'},
    {'symbol': 'GOOGL', 'name': 'Alphabet Inc.', 'price': '\$141.80', 'change': '+0.95%', 'isUp': true, 'category': 'Tech'},
    {'symbol': 'AMZN', 'name': 'Amazon.com Inc.', 'price': '\$151.94', 'change': '+0.87%', 'isUp': true, 'category': 'Consumer'},
    {'symbol': 'NVDA', 'name': 'NVIDIA Corporation', 'price': '\$467.30', 'change': '+4.21%', 'isUp': true, 'category': 'Tech'},
    {'symbol': 'TSLA', 'name': 'Tesla, Inc.', 'price': '\$248.50', 'change': '-1.23%', 'isUp': false, 'category': 'Consumer'},
    {'symbol': 'META', 'name': 'Meta Platforms Inc.', 'price': '\$326.49', 'change': '-0.45%', 'isUp': false, 'category': 'Tech'},
    {'symbol': 'JPM', 'name': 'JPMorgan Chase & Co.', 'price': '\$170.23', 'change': '+1.12%', 'isUp': true, 'category': 'Finance'},
    {'symbol': 'V', 'name': 'Visa Inc.', 'price': '\$260.45', 'change': '+0.67%', 'isUp': true, 'category': 'Finance'},
    {'symbol': 'JNJ', 'name': 'Johnson & Johnson', 'price': '\$156.78', 'change': '-0.23%', 'isUp': false, 'category': 'Healthcare'},
  ];

  List<Map<String, dynamic>> get _filteredStocks {
    var stocks = _popularStocks;
    
    if (_selectedCategory != 'All') {
      stocks = stocks.where((s) => s['category'] == _selectedCategory).toList();
    }
    
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      stocks = stocks.where((s) =>
        (s['symbol'] as String).toLowerCase().contains(query) ||
        (s['name'] as String).toLowerCase().contains(query)
      ).toList();
    }
    
    return stocks;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Trade',
          style: ThryveTypography.titleLarge.copyWith(
            color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search bar
          _buildSearchBar(isDark),

          // Category filter
          _buildCategoryFilter(isDark),

          // Market status
          _buildMarketStatus(isDark),

          // Stocks list
          Expanded(
            child: _buildStocksList(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() {}),
        style: ThryveTypography.bodyLarge.copyWith(
          color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Search stocks...',
          hintStyle: ThryveTypography.bodyLarge.copyWith(
            color: ThryveColors.textTertiary,
          ),
          prefixIcon: const Icon(Icons.search, color: ThryveColors.textSecondary),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: ThryveColors.textSecondary),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
              : null,
          filled: true,
          fillColor: isDark ? ThryveColors.surfaceDark : ThryveColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(bool isDark) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = category),
            child: Container(
              margin: EdgeInsets.only(right: index < _categories.length - 1 ? 8 : 0),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? ThryveColors.accent
                    : (isDark ? ThryveColors.surfaceDark : ThryveColors.surface),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                category,
                style: ThryveTypography.labelMedium.copyWith(
                  color: isSelected
                      ? Colors.white
                      : ThryveColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMarketStatus(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ThryveColors.success.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: ThryveColors.success,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Market Open',
                    style: ThryveTypography.labelLarge.copyWith(
                      color: ThryveColors.success,
                    ),
                  ),
                  Text(
                    'Trading hours: 9:30 AM - 4:00 PM EST',
                    style: ThryveTypography.bodySmall.copyWith(
                      color: ThryveColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStocksList(bool isDark) {
    final stocks = _filteredStocks;

    if (stocks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: ThryveColors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'No stocks found',
              style: ThryveTypography.titleMedium.copyWith(
                color: ThryveColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different search term',
              style: ThryveTypography.bodyMedium.copyWith(
                color: ThryveColors.textTertiary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: stocks.length,
      itemBuilder: (context, index) {
        final stock = stocks[index];
        return GestureDetector(
          onTap: () => context.push('/trade/${stock['symbol']}'),
          child: Container(
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
                      stock['symbol'].toString().substring(0, 2),
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
                        stock['symbol'] as String,
                        style: ThryveTypography.titleMedium.copyWith(
                          color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                        ),
                      ),
                      Text(
                        stock['name'] as String,
                        style: ThryveTypography.bodySmall.copyWith(
                          color: ThryveColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      stock['price'] as String,
                      style: ThryveTypography.titleMedium.copyWith(
                        color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: (stock['isUp'] as bool)
                            ? ThryveColors.success.withValues(alpha: 0.1)
                            : ThryveColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        stock['change'] as String,
                        style: ThryveTypography.labelSmall.copyWith(
                          color: (stock['isUp'] as bool) ? ThryveColors.success : ThryveColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
