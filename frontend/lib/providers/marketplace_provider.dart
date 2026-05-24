import 'package:flutter/foundation.dart';

import '../models/marketplace_models.dart';
import '../services/api_service.dart';

class MarketplaceProvider extends ChangeNotifier {
  MarketplaceProvider({ApiService? apiService}) : _apiService = apiService ?? const ApiService();

  final ApiService _apiService;

  final List<Product> _products = [];
  final List<CartItem> _cartItems = [];
  final List<OrderSummary> _orders = [];

  AnalyticsSummary? _analytics;
  RecommendationBundle? _recommendations;
  SalesInsightResult? _salesInsight;
  String? _bootstrapError;
  bool _isBootstrapping = true;
  bool _isBusy = false;
  String _searchQuery = '';
  String? _generatedDescription;
  int? _activeProductId;

  List<Product> get products => List.unmodifiable(_products);
  List<CartItem> get cartItems => List.unmodifiable(_cartItems);
  List<OrderSummary> get orders => List.unmodifiable(_orders);
  AnalyticsSummary? get analytics => _analytics;
  RecommendationBundle? get recommendations => _recommendations;
  SalesInsightResult? get salesInsight => _salesInsight;
  String? get bootstrapError => _bootstrapError;
  bool get isBootstrapping => _isBootstrapping;
  bool get isBusy => _isBusy;
  String? get generatedDescription => _generatedDescription;
  int? get activeProductId => _activeProductId;

  List<Product> get filteredProducts {
    if (_searchQuery.trim().isEmpty) {
      return products;
    }

    final query = _searchQuery.toLowerCase().trim();
    return products.where((product) {
      return product.name.toLowerCase().contains(query) ||
          product.description.toLowerCase().contains(query) ||
          product.category.toLowerCase().contains(query);
    }).toList();
  }

  double get cartSubtotal => _cartItems.fold(0, (sum, item) => sum + item.lineTotal);

  Future<void> bootstrap() async {
    _isBootstrapping = true;
    _bootstrapError = null;
    notifyListeners();

    try {
      _products
        ..clear()
        ..addAll(await _apiService.fetchProducts());

      _orders
        ..clear()
        ..addAll(await _apiService.fetchOrders());

      _analytics = await _apiService.fetchAnalytics();

      if (_products.isNotEmpty) {
        _activeProductId = _products.first.id;
        _recommendations = await _apiService.fetchRecommendations(productId: _products.first.id);
        _salesInsight = await _apiService.fetchSalesInsight();
      }
    } catch (error) {
      _bootstrapError = error.toString();
    } finally {
      _isBootstrapping = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void setActiveProduct(Product product) {
    _activeProductId = product.id;
    notifyListeners();
    loadRecommendationsForProduct(product.id);
  }

  Product? get activeProduct {
    if (_activeProductId == null) {
      return null;
    }

    for (final product in _products) {
      if (product.id == _activeProductId) {
        return product;
      }
    }

    return null;
  }

  Future<void> loadRecommendationsForProduct(int productId) async {
    try {
      _recommendations = await _apiService.fetchRecommendations(productId: productId);
      _salesInsight = await _apiService.fetchSalesInsight();
      notifyListeners();
    } catch (_) {
      // Keep the current data if the AI endpoints temporarily fail.
    }
  }

  void addToCart(Product product, {int quantity = 1}) {
    final index = _cartItems.indexWhere((item) => item.product.id == product.id);

    if (index >= 0) {
      _cartItems[index].quantity += quantity;
    } else {
      _cartItems.add(CartItem(product: product, quantity: quantity));
    }

    notifyListeners();
  }

  void increaseQuantity(Product product) {
    addToCart(product, quantity: 1);
  }

  void decreaseQuantity(Product product) {
    final index = _cartItems.indexWhere((item) => item.product.id == product.id);

    if (index < 0) {
      return;
    }

    final item = _cartItems[index];
    if (item.quantity <= 1) {
      _cartItems.removeAt(index);
    } else {
      item.quantity -= 1;
    }

    notifyListeners();
  }

  void removeFromCart(Product product) {
    _cartItems.removeWhere((item) => item.product.id == product.id);
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  Future<CouponValidationResult> validateCoupon(String code) async {
    return _apiService.validateCoupon(code);
  }

  Future<OrderSummary> checkout({String couponCode = ''}) async {
    if (_cartItems.isEmpty) {
      throw Exception('Cart is empty');
    }

    _isBusy = true;
    notifyListeners();

    try {
      final order = await _apiService.placeOrder(_cartItems, couponCode: couponCode);
      _orders.insert(0, order);
      _cartItems.clear();
      _analytics = await _apiService.fetchAnalytics();
      _products
        ..clear()
        ..addAll(await _apiService.fetchProducts());
      _salesInsight = await _apiService.fetchSalesInsight();
      if (_activeProductId != null) {
        _recommendations = await _apiService.fetchRecommendations(productId: _activeProductId);
      }
      return order;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<void> generateProductDescription(String name, String category) async {
    _isBusy = true;
    notifyListeners();

    try {
      final result = await _apiService.generateDescription(name, category);
      _generatedDescription = result.description;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }
}