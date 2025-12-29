import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/finnhub_models.dart';

/// Finnhub API Remote Data Source
/// 
/// Provides access to Finnhub's free tier API for:
/// - Analyst recommendations (Buy/Hold/Sell)
/// - Price targets (High/Low/Mean)
/// - Basic financials (P/E, EPS, Market Cap)
/// - Company news
/// - Earnings calendar
/// - Company profile
/// 
/// Rate limit: 60 requests/minute on free tier
class FinnhubRemoteDataSource {
  static const String _baseUrl = 'https://finnhub.io/api/v1';
  
  // TODO: Move to environment config / secure storage
  // Get free API key from https://finnhub.io/register
  static const String _apiKey = 'YOUR_FINNHUB_API_KEY';
  
  final http.Client _client;

  FinnhubRemoteDataSource({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
  };

  String _buildUrl(String endpoint, Map<String, String> params) {
    params['token'] = _apiKey;
    final queryString = params.entries.map((e) => '${e.key}=${e.value}').join('&');
    return '$_baseUrl$endpoint?$queryString';
  }

  /// Get analyst recommendations for a stock
  /// Returns list of monthly recommendations (most recent first)
  Future<List<AnalystRecommendation>> getAnalystRecommendations(String symbol) async {
    try {
      final url = _buildUrl('/stock/recommendation', {'symbol': symbol});
      final response = await _client.get(Uri.parse(url), headers: _headers);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => AnalystRecommendation.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching analyst recommendations: $e');
      return [];
    }
  }

  /// Get price target consensus for a stock
  Future<PriceTarget?> getPriceTarget(String symbol) async {
    try {
      final url = _buildUrl('/stock/price-target', {'symbol': symbol});
      final response = await _client.get(Uri.parse(url), headers: _headers);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data['symbol'] != null) {
          return PriceTarget.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching price target: $e');
      return null;
    }
  }

  /// Get basic financial metrics for a stock
  Future<BasicFinancials?> getBasicFinancials(String symbol) async {
    try {
      final url = _buildUrl('/stock/metric', {'symbol': symbol, 'metric': 'all'});
      final response = await _client.get(Uri.parse(url), headers: _headers);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        data['symbol'] = symbol;
        return BasicFinancials.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching basic financials: $e');
      return null;
    }
  }

  /// Get company news
  /// [from] and [to] should be in format 'YYYY-MM-DD'
  Future<List<StockNews>> getCompanyNews(String symbol, {String? from, String? to}) async {
    try {
      final now = DateTime.now();
      final params = {
        'symbol': symbol,
        'from': from ?? now.subtract(const Duration(days: 7)).toString().split(' ')[0],
        'to': to ?? now.toString().split(' ')[0],
      };
      
      final url = _buildUrl('/company-news', params);
      final response = await _client.get(Uri.parse(url), headers: _headers);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => StockNews.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching company news: $e');
      return [];
    }
  }

  /// Get earnings calendar for a stock
  /// [from] and [to] should be in format 'YYYY-MM-DD'  
  Future<List<EarningsEvent>> getEarningsCalendar(String symbol, {String? from, String? to}) async {
    try {
      final now = DateTime.now();
      final params = {
        'symbol': symbol,
        'from': from ?? now.toString().split(' ')[0],
        'to': to ?? now.add(const Duration(days: 90)).toString().split(' ')[0],
      };
      
      final url = _buildUrl('/calendar/earnings', params);
      final response = await _client.get(Uri.parse(url), headers: _headers);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> earnings = data['earningsCalendar'] ?? [];
        return earnings
            .where((e) => e['symbol'] == symbol)
            .map((json) => EarningsEvent.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching earnings calendar: $e');
      return [];
    }
  }

  /// Get company profile
  Future<CompanyProfile?> getCompanyProfile(String symbol) async {
    try {
      final url = _buildUrl('/stock/profile2', {'symbol': symbol});
      final response = await _client.get(Uri.parse(url), headers: _headers);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data['ticker'] != null) {
          return CompanyProfile.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching company profile: $e');
      return null;
    }
  }

  /// Get peers (similar stocks) for a symbol
  Future<List<String>> getPeers(String symbol) async {
    try {
      final url = _buildUrl('/stock/peers', {'symbol': symbol});
      final response = await _client.get(Uri.parse(url), headers: _headers);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<String>();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching peers: $e');
      return [];
    }
  }

  /// Get real-time quote for a stock
  Future<Map<String, dynamic>?> getQuote(String symbol) async {
    try {
      final url = _buildUrl('/quote', {'symbol': symbol});
      final response = await _client.get(Uri.parse(url), headers: _headers);
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching quote: $e');
      return null;
    }
  }

  void dispose() {
    _client.close();
  }
}

