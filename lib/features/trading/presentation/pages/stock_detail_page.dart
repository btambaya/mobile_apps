import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';
import '../../data/models/finnhub_models.dart';
import '../widgets/analyst_rating_card.dart';
import '../widgets/price_target_card.dart';
import '../widgets/key_stats_grid.dart';
import '../widgets/events_section.dart';
import '../widgets/about_stock_section.dart';
import '../widgets/similar_stocks_row.dart';
import '../widgets/price_alert_card.dart';
import '../widgets/stock_news_widgets.dart';

/// Enhanced Stock detail page - Shows comprehensive stock info with tabs
class StockDetailPage extends StatefulWidget {
  final String symbol;

  const StockDetailPage({super.key, required this.symbol});

  @override
  State<StockDetailPage> createState() => _StockDetailPageState();
}

class _StockDetailPageState extends State<StockDetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = '1D';
  bool _isInWatchlist = false;

  final List<String> _periods = ['1D', '1W', '1M', '3M', '1Y', 'ALL'];
  final List<PriceAlert> _alerts = [];

  // Mock data - would come from DriveWealth/Finnhub APIs
  Map<String, dynamic> get _stockData => {
    'symbol': widget.symbol,
    'name': _getStockName(widget.symbol),
    'price': 178.72,
    'change': 2.34,
    'changePercent': 1.33,
    'isUp': true,
    'open': 176.50,
    'high': 180.12,
    'low': 175.80,
    'volume': 52300000.0,
  };

  // Mock analyst data
  AnalystRecommendation get _mockRecommendation => AnalystRecommendation(
    symbol: widget.symbol,
    buy: 18,
    hold: 12,
    sell: 5,
    strongBuy: 8,
    strongSell: 2,
    period: '2024-12',
  );

  // Mock price target
  PriceTarget get _mockPriceTarget => PriceTarget(
    symbol: widget.symbol,
    targetHigh: 220.0,
    targetLow: 145.0,
    targetMean: 195.50,
    targetMedian: 192.0,
    lastUpdated: '2024-12-20',
  );

  // Mock financials
  BasicFinancials get _mockFinancials => BasicFinancials(
    symbol: widget.symbol,
    peRatio: 29.5,
    eps: 6.05,
    marketCap: 2780000.0, // In millions
    week52High: 199.62,
    week52Low: 124.17,
    dividendYield: 0.55,
    beta: 1.28,
    volume: 52.3,
    avgVolume: 58.2,
  );

  // Mock earnings
  List<EarningsEvent> get _mockEarnings => [
    EarningsEvent(
      symbol: widget.symbol,
      date: '2025-01-30',
      hour: 'amc',
      epsEstimate: 2.35,
    ),
  ];

  // Mock company profile
  CompanyProfile get _mockProfile => CompanyProfile(
    country: 'US',
    currency: 'USD',
    exchange: 'NASDAQ',
    finnhubIndustry: 'Technology',
    ipo: '1980-12-12',
    logo: 'https://static.finnhub.io/logo/87cb30d8-80df-11ea-8951-00000000092a.png',
    marketCapitalization: 2780000.0,
    name: _getStockName(widget.symbol),
    phone: '14089961010',
    shareOutstanding: 15550.0,
    ticker: widget.symbol,
    weburl: 'https://www.apple.com',
  );

  // Mock news
  List<StockNews> get _mockNews => [
    StockNews(
      category: 'company news',
      datetime: DateTime.now().subtract(const Duration(hours: 2)).millisecondsSinceEpoch ~/ 1000,
      headline: '${_getStockName(widget.symbol)} Reports Strong Q4 Earnings',
      id: 1,
      image: '',
      related: widget.symbol,
      source: 'Reuters',
      summary: 'The company reported earnings that beat analyst expectations...',
      url: 'https://example.com/news/1',
    ),
    StockNews(
      category: 'company news',
      datetime: DateTime.now().subtract(const Duration(hours: 8)).millisecondsSinceEpoch ~/ 1000,
      headline: 'Analysts Upgrade ${widget.symbol} on Strong Growth Outlook',
      id: 2,
      image: '',
      related: widget.symbol,
      source: 'Bloomberg',
      summary: 'Multiple analysts have upgraded their ratings...',
      url: 'https://example.com/news/2',
    ),
  ];

  // Mock similar stocks
  List<SimilarStock> get _mockSimilarStocks => [
    SimilarStock(symbol: 'MSFT', price: 378.50, changePercent: 0.85),
    SimilarStock(symbol: 'GOOGL', price: 140.25, changePercent: -0.32),
    SimilarStock(symbol: 'META', price: 345.80, changePercent: 1.25),
    SimilarStock(symbol: 'AMZN', price: 178.20, changePercent: 0.65),
  ];

  String _getStockName(String symbol) {
    final names = {
      'AAPL': 'Apple Inc.',
      'MSFT': 'Microsoft Corporation',
      'GOOGL': 'Alphabet Inc.',
      'AMZN': 'Amazon.com Inc.',
      'NVDA': 'NVIDIA Corporation',
      'TSLA': 'Tesla, Inc.',
      'META': 'Meta Platforms Inc.',
    };
    return names[symbol] ?? symbol;
  }

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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stock = _stockData;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildAppBar(isDark, stock),
        ],
        body: Column(
          children: [
            // Tab bar
            Container(
              color: isDark ? ThryveColors.backgroundDark : Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: ThryveColors.accent,
                unselectedLabelColor: ThryveColors.textSecondary,
                indicatorColor: ThryveColors.accent,
                indicatorWeight: 3,
                tabs: const [
                  Tab(text: 'Overview'),
                  Tab(text: 'Financials'),
                  Tab(text: 'News'),
                ],
              ),
            ),
            
            // Tab views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(isDark, stock),
                  _buildFinancialsTab(isDark),
                  _buildNewsTab(isDark),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildActionButtons(context, isDark),
    );
  }

  Widget _buildAppBar(bool isDark, Map<String, dynamic> stock) {
    final isUp = stock['isUp'] as bool;

    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: isDark ? ThryveColors.backgroundDark : Colors.white,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new,
          color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
        ),
        onPressed: () => context.pop(),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.notifications_outlined,
            color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
          ),
          onPressed: () {
            // Scroll to alerts section
          },
        ),
        IconButton(
          icon: Icon(
            _isInWatchlist ? Icons.star : Icons.star_border,
            color: _isInWatchlist ? ThryveColors.accent : ThryveColors.textSecondary,
          ),
          onPressed: () {
            setState(() => _isInWatchlist = !_isInWatchlist);
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 56), // AppBar height
              _buildHeaderInfo(isDark, stock, isUp),
              _buildPeriodSelector(isDark),
              Expanded(child: _buildMiniChart(isDark, isUp)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderInfo(bool isDark, Map<String, dynamic> stock, bool isUp) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stock logo
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: ThryveColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                widget.symbol[0],
                style: ThryveTypography.headlineSmall.copyWith(
                  color: ThryveColors.accent,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Stock info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.symbol} · ${stock['name']}',
                  style: ThryveTypography.titleSmall.copyWith(
                    color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '\$${stock['price']}',
                      style: ThryveTypography.headlineMedium.copyWith(
                        color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (isUp ? ThryveColors.success : ThryveColors.error).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${isUp ? '+' : ''}\$${stock['change']} (${stock['changePercent']}%)',
                        style: ThryveTypography.labelSmall.copyWith(
                          color: isUp ? ThryveColors.success : ThryveColors.error,
                        ),
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

  Widget _buildPeriodSelector(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _periods.map((period) {
          final isSelected = period == _selectedPeriod;
          return GestureDetector(
            onTap: () => setState(() => _selectedPeriod = period),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? ThryveColors.accent : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                period,
                style: ThryveTypography.labelSmall.copyWith(
                  color: isSelected ? Colors.white : ThryveColors.textSecondary,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMiniChart(bool isDark, bool isUp) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (spot) => ThryveColors.surfaceDark,
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: const [
                FlSpot(0, 176),
                FlSpot(1, 175.5),
                FlSpot(2, 177),
                FlSpot(3, 176.8),
                FlSpot(4, 178.2),
                FlSpot(5, 177.5),
                FlSpot(6, 178.72),
              ],
              isCurved: true,
              color: isUp ? ThryveColors.success : ThryveColors.error,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    (isUp ? ThryveColors.success : ThryveColors.error).withValues(alpha: 0.2),
                    (isUp ? ThryveColors.success : ThryveColors.error).withValues(alpha: 0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(bool isDark, Map<String, dynamic> stock) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Analyst ratings card
          AnalystRatingCard(
            recommendation: _mockRecommendation,
            onTap: () {
              // Navigate to full ratings page
            },
          ),
          const SizedBox(height: 16),
          
          // Price targets card
          PriceTargetCard(
            priceTarget: _mockPriceTarget,
            currentPrice: stock['price'] as double,
            onTap: () {
              // Navigate to full targets page
            },
          ),
          const SizedBox(height: 16),
          
          // Key stats
          KeyStatsGrid(
            financials: _mockFinancials,
            currentPrice: stock['price'] as double,
            dayHigh: stock['high'] as double,
            dayLow: stock['low'] as double,
            volume: stock['volume'] as double,
          ),
          const SizedBox(height: 16),
          
          // Events section
          EventsSection(earnings: _mockEarnings),
          const SizedBox(height: 16),
          
          // About section
          AboutStockSection(
            profile: _mockProfile,
            description: 'Apple Inc. designs, manufactures, and markets smartphones, personal computers, tablets, wearables, and accessories worldwide. The company offers iPhone, Mac, iPad, and wearables, home, and accessories.',
          ),
          const SizedBox(height: 16),
          
          // Price alerts
          PriceAlertCard(
            symbol: widget.symbol,
            currentPrice: stock['price'] as double,
            alerts: _alerts,
            onAddAlert: (alert) {
              setState(() => _alerts.add(alert));
            },
            onRemoveAlert: (id) {
              setState(() => _alerts.removeWhere((a) => a.id == id));
            },
          ),
          const SizedBox(height: 16),
          
          // Similar stocks
          SimilarStocksRow(
            stocks: _mockSimilarStocks,
            onStockTap: (symbol) {
              context.push('/stock/$symbol');
            },
          ),
          
          const SizedBox(height: 100), // Bottom padding for buttons
        ],
      ),
    );
  }

  Widget _buildFinancialsTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Key Stats (detailed view)
          KeyStatsGrid(
            financials: _mockFinancials,
            currentPrice: _stockData['price'] as double,
            dayHigh: _stockData['high'] as double,
            dayLow: _stockData['low'] as double,
            volume: _stockData['volume'] as double,
          ),
          const SizedBox(height: 24),
          
          // Placeholder for future full financials
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? ThryveColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? ThryveColors.surfaceElevatedDark : ThryveColors.divider,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.bar_chart,
                  size: 48,
                  color: ThryveColors.textTertiary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Detailed Financials',
                  style: ThryveTypography.titleMedium.copyWith(
                    color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Income Statement, Balance Sheet, and Cash Flow charts coming in Phase 2',
                  style: ThryveTypography.bodySmall.copyWith(
                    color: ThryveColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildNewsTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: StockNewsList(
        news: _mockNews,
        onNewsTap: (news) {
          // Open news URL
        },
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? ThryveColors.surfaceDark : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 56,
              child: OutlinedButton(
                onPressed: () => _showTradeSheet(context, false),
                style: OutlinedButton.styleFrom(
                  foregroundColor: ThryveColors.error,
                  side: const BorderSide(color: ThryveColors.error, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Sell',
                  style: ThryveTypography.button.copyWith(fontSize: 16),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: () => _showTradeSheet(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThryveColors.success,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Buy',
                  style: ThryveTypography.button.copyWith(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTradeSheet(BuildContext context, bool isBuy) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TradeBottomSheet(
        symbol: widget.symbol,
        isBuy: isBuy,
        currentPrice: _stockData['price'] as double,
      ),
    );
  }
}

/// Bottom sheet for buy/sell order
class TradeBottomSheet extends StatefulWidget {
  final String symbol;
  final bool isBuy;
  final double currentPrice;

  const TradeBottomSheet({
    super.key,
    required this.symbol,
    required this.isBuy,
    required this.currentPrice,
  });

  @override
  State<TradeBottomSheet> createState() => _TradeBottomSheetState();
}

class _TradeBottomSheetState extends State<TradeBottomSheet> {
  final _amountController = TextEditingController(text: '100');
  bool _isLoading = false;

  double get _shares => double.parse(_amountController.text.isEmpty ? '0' : _amountController.text) / widget.currentPrice;

  void _handleTrade() {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.isBuy ? 'Bought' : 'Sold'} ${_shares.toStringAsFixed(4)} shares of ${widget.symbol}'),
            backgroundColor: ThryveColors.success,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? ThryveColors.backgroundDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle
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

          // Title
          Text(
            '${widget.isBuy ? 'Buy' : 'Sell'} ${widget.symbol}',
            style: ThryveTypography.headlineSmall.copyWith(
              color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Current price: \$${widget.currentPrice}',
            style: ThryveTypography.bodyMedium.copyWith(
              color: ThryveColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Amount input
          Text(
            'Amount (USD)',
            style: ThryveTypography.labelLarge.copyWith(
              color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            onChanged: (value) => setState(() {}),
            style: ThryveTypography.headlineMedium.copyWith(
              color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
            ),
            decoration: InputDecoration(
              prefixText: '\$ ',
              prefixStyle: ThryveTypography.headlineMedium.copyWith(
                color: ThryveColors.textSecondary,
              ),
              filled: true,
              fillColor: isDark ? ThryveColors.surfaceDark : ThryveColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Estimated shares
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? ThryveColors.surfaceDark : ThryveColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Estimated shares',
                  style: ThryveTypography.bodyMedium.copyWith(
                    color: ThryveColors.textSecondary,
                  ),
                ),
                Text(
                  _shares.toStringAsFixed(4),
                  style: ThryveTypography.titleMedium.copyWith(
                    color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Trade button
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleTrade,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.isBuy ? ThryveColors.success : ThryveColors.error,
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
                      'Confirm ${widget.isBuy ? 'Buy' : 'Sell'}',
                      style: ThryveTypography.button.copyWith(fontSize: 16, color: Colors.white),
                    ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }
}
