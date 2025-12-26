/// Finnhub API data models for stock analysis
/// 
/// These models parse responses from Finnhub's free API endpoints
/// for analyst ratings, price targets, basic financials, news, and earnings.

// Analyst Recommendation Model
class AnalystRecommendation {
  final String symbol;
  final int buy;
  final int hold;
  final int sell;
  final int strongBuy;
  final int strongSell;
  final String period;

  AnalystRecommendation({
    required this.symbol,
    required this.buy,
    required this.hold,
    required this.sell,
    required this.strongBuy,
    required this.strongSell,
    required this.period,
  });

  factory AnalystRecommendation.fromJson(Map<String, dynamic> json) {
    return AnalystRecommendation(
      symbol: json['symbol'] ?? '',
      buy: json['buy'] ?? 0,
      hold: json['hold'] ?? 0,
      sell: json['sell'] ?? 0,
      strongBuy: json['strongBuy'] ?? 0,
      strongSell: json['strongSell'] ?? 0,
      period: json['period'] ?? '',
    );
  }

  int get totalAnalysts => strongBuy + buy + hold + sell + strongSell;
  
  double get buyPercentage => totalAnalysts > 0 ? ((strongBuy + buy) / totalAnalysts) * 100 : 0;
  double get holdPercentage => totalAnalysts > 0 ? (hold / totalAnalysts) * 100 : 0;
  double get sellPercentage => totalAnalysts > 0 ? ((sell + strongSell) / totalAnalysts) * 100 : 0;

  String get consensus {
    if (buyPercentage > 50) return 'Buy';
    if (sellPercentage > 50) return 'Sell';
    return 'Hold';
  }
}

// Price Target Model
class PriceTarget {
  final String symbol;
  final double targetHigh;
  final double targetLow;
  final double targetMean;
  final double targetMedian;
  final String lastUpdated;

  PriceTarget({
    required this.symbol,
    required this.targetHigh,
    required this.targetLow,
    required this.targetMean,
    required this.targetMedian,
    required this.lastUpdated,
  });

  factory PriceTarget.fromJson(Map<String, dynamic> json) {
    return PriceTarget(
      symbol: json['symbol'] ?? '',
      targetHigh: (json['targetHigh'] ?? 0).toDouble(),
      targetLow: (json['targetLow'] ?? 0).toDouble(),
      targetMean: (json['targetMean'] ?? 0).toDouble(),
      targetMedian: (json['targetMedian'] ?? 0).toDouble(),
      lastUpdated: json['lastUpdated'] ?? '',
    );
  }

  double upsidePercentage(double currentPrice) {
    if (currentPrice <= 0) return 0;
    return ((targetMean - currentPrice) / currentPrice) * 100;
  }
}

// Basic Financials Model
class BasicFinancials {
  final String symbol;
  final double? peRatio;
  final double? eps;
  final double? marketCap;
  final double? week52High;
  final double? week52Low;
  final double? dividendYield;
  final double? beta;
  final double? volume;
  final double? avgVolume;

  BasicFinancials({
    required this.symbol,
    this.peRatio,
    this.eps,
    this.marketCap,
    this.week52High,
    this.week52Low,
    this.dividendYield,
    this.beta,
    this.volume,
    this.avgVolume,
  });

  factory BasicFinancials.fromJson(Map<String, dynamic> json) {
    final metric = json['metric'] ?? {};
    return BasicFinancials(
      symbol: json['symbol'] ?? '',
      peRatio: metric['peBasicExclExtraTTM']?.toDouble(),
      eps: metric['epsBasicExclExtraItemsTTM']?.toDouble(),
      marketCap: metric['marketCapitalization']?.toDouble(),
      week52High: metric['52WeekHigh']?.toDouble(),
      week52Low: metric['52WeekLow']?.toDouble(),
      dividendYield: metric['dividendYieldIndicatedAnnual']?.toDouble(),
      beta: metric['beta']?.toDouble(),
      volume: metric['10DayAverageTradingVolume']?.toDouble(),
      avgVolume: metric['3MonthAverageTradingVolume']?.toDouble(),
    );
  }

  String get formattedMarketCap {
    if (marketCap == null) return 'N/A';
    if (marketCap! >= 1000000) return '\$${(marketCap! / 1000000).toStringAsFixed(2)}T';
    if (marketCap! >= 1000) return '\$${(marketCap! / 1000).toStringAsFixed(2)}B';
    return '\$${marketCap!.toStringAsFixed(2)}M';
  }
}

// Stock News Model
class StockNews {
  final String category;
  final int datetime;
  final String headline;
  final int id;
  final String image;
  final String related;
  final String source;
  final String summary;
  final String url;

  StockNews({
    required this.category,
    required this.datetime,
    required this.headline,
    required this.id,
    required this.image,
    required this.related,
    required this.source,
    required this.summary,
    required this.url,
  });

  factory StockNews.fromJson(Map<String, dynamic> json) {
    return StockNews(
      category: json['category'] ?? '',
      datetime: json['datetime'] ?? 0,
      headline: json['headline'] ?? '',
      id: json['id'] ?? 0,
      image: json['image'] ?? '',
      related: json['related'] ?? '',
      source: json['source'] ?? '',
      summary: json['summary'] ?? '',
      url: json['url'] ?? '',
    );
  }

  DateTime get publishedAt => DateTime.fromMillisecondsSinceEpoch(datetime * 1000);
  
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(publishedAt);
    
    if (difference.inDays > 0) return '${difference.inDays}d ago';
    if (difference.inHours > 0) return '${difference.inHours}h ago';
    if (difference.inMinutes > 0) return '${difference.inMinutes}m ago';
    return 'Just now';
  }
}

// Earnings Calendar Model
class EarningsEvent {
  final String symbol;
  final String date;
  final String hour; // "bmo" (before market open), "amc" (after market close)
  final double? epsActual;
  final double? epsEstimate;
  final double? revenueActual;
  final double? revenueEstimate;

  EarningsEvent({
    required this.symbol,
    required this.date,
    required this.hour,
    this.epsActual,
    this.epsEstimate,
    this.revenueActual,
    this.revenueEstimate,
  });

  factory EarningsEvent.fromJson(Map<String, dynamic> json) {
    return EarningsEvent(
      symbol: json['symbol'] ?? '',
      date: json['date'] ?? '',
      hour: json['hour'] ?? '',
      epsActual: json['epsActual']?.toDouble(),
      epsEstimate: json['epsEstimate']?.toDouble(),
      revenueActual: json['revenueActual']?.toDouble(),
      revenueEstimate: json['revenueEstimate']?.toDouble(),
    );
  }

  String get formattedHour {
    if (hour == 'bmo') return 'Before Market Open';
    if (hour == 'amc') return 'After Market Close';
    return hour;
  }

  bool get hasSurprise => epsActual != null && epsEstimate != null;
  
  double? get epsSurprise {
    if (!hasSurprise) return null;
    return epsActual! - epsEstimate!;
  }
}

// Company Profile Model
class CompanyProfile {
  final String country;
  final String currency;
  final String exchange;
  final String finnhubIndustry;
  final String ipo;
  final String logo;
  final double marketCapitalization;
  final String name;
  final String phone;
  final double shareOutstanding;
  final String ticker;
  final String weburl;

  CompanyProfile({
    required this.country,
    required this.currency,
    required this.exchange,
    required this.finnhubIndustry,
    required this.ipo,
    required this.logo,
    required this.marketCapitalization,
    required this.name,
    required this.phone,
    required this.shareOutstanding,
    required this.ticker,
    required this.weburl,
  });

  factory CompanyProfile.fromJson(Map<String, dynamic> json) {
    return CompanyProfile(
      country: json['country'] ?? '',
      currency: json['currency'] ?? '',
      exchange: json['exchange'] ?? '',
      finnhubIndustry: json['finnhubIndustry'] ?? '',
      ipo: json['ipo'] ?? '',
      logo: json['logo'] ?? '',
      marketCapitalization: (json['marketCapitalization'] ?? 0).toDouble(),
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      shareOutstanding: (json['shareOutstanding'] ?? 0).toDouble(),
      ticker: json['ticker'] ?? '',
      weburl: json['weburl'] ?? '',
    );
  }
}
