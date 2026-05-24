import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/marketplace_models.dart';
import '../utils/app_config.dart';

class ApiService {
  const ApiService();

  Uri _uri(String path, [Map<String, dynamic>? queryParameters]) {
    return Uri.parse('$apiBaseUrl$path').replace(
      queryParameters: queryParameters?.map((key, value) => MapEntry(key, value.toString())),
    );
  }

  Future<List<Product>> fetchProducts() async {
    final response = await http.get(_uri('/api/products'));
    _ensureSuccess(response);
    final data = jsonDecode(response.body) as List<dynamic>;
    return data.map((item) => Product.fromJson(Map<String, dynamic>.from(item as Map))).toList();
  }

  Future<List<OrderSummary>> fetchOrders() async {
    final response = await http.get(_uri('/api/orders'));
    _ensureSuccess(response);
    final data = jsonDecode(response.body) as List<dynamic>;
    return data.map((item) => OrderSummary.fromJson(Map<String, dynamic>.from(item as Map))).toList();
  }

  Future<OrderSummary> placeOrder(List<CartItem> items, {String couponCode = ''}) async {
    final response = await http.post(
      _uri('/api/orders'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'items': items.map((item) => item.toOrderPayload()).toList(),
        'couponCode': couponCode,
      }),
    );

    _ensureSuccess(response);
    return OrderSummary.fromJson(Map<String, dynamic>.from(jsonDecode(response.body) as Map));
  }

  Future<CouponValidationResult> validateCoupon(String code) async {
    final response = await http.post(
      _uri('/api/coupons/validate'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'code': code}),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return CouponValidationResult.fromJson(Map<String, dynamic>.from(jsonDecode(response.body) as Map));
    }

    final message = response.body.isEmpty ? 'Coupon validation failed' : response.body;
    return CouponValidationResult(valid: false, message: message);
  }

  Future<AnalyticsSummary> fetchAnalytics() async {
    final response = await http.get(_uri('/api/analytics'));
    _ensureSuccess(response);
    return AnalyticsSummary.fromJson(Map<String, dynamic>.from(jsonDecode(response.body) as Map));
  }

  Future<RecommendationBundle> fetchRecommendations({int? productId}) async {
    final response = await http.get(
      _uri(
        '/api/ai/recommendations',
        productId == null ? null : {'productId': productId},
      ),
    );
    _ensureSuccess(response);
    return RecommendationBundle.fromJson(Map<String, dynamic>.from(jsonDecode(response.body) as Map));
  }

  Future<DescriptionResult> generateDescription(String name, String category) async {
    final response = await http.post(
      _uri('/api/ai/generate-description'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'category': category}),
    );
    _ensureSuccess(response);
    return DescriptionResult.fromJson(Map<String, dynamic>.from(jsonDecode(response.body) as Map));
  }

  Future<SalesInsightResult> fetchSalesInsight() async {
    final response = await http.get(_uri('/api/ai/sales-insight'));
    _ensureSuccess(response);
    return SalesInsightResult.fromJson(Map<String, dynamic>.from(jsonDecode(response.body) as Map));
  }

  void _ensureSuccess(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    final body = response.body.isEmpty ? 'Request failed' : response.body;
    throw Exception(body);
  }
}