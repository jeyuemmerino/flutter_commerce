import 'package:flutter/foundation.dart';

import '../models/commerce_models.dart';
import '../services/commerce_api_service.dart';

enum AppMode { launch, guest, auth, buyer, seller }

class CommerceProvider extends ChangeNotifier {
  CommerceProvider({CommerceApiService? apiService}) : _api = apiService ?? const CommerceApiService();

  final CommerceApiService _api;

  AppMode _mode = AppMode.launch;
  AuthUser? _currentUser;
  Shop? _currentShop;
  ShopDashboard? _shopDashboard;
  List<Shop> _shops = [];
  List<Product> _products = [];
  List<CartItem> _cartItems = [];
  List<Order> _buyerOrders = [];
  List<Order> _shopOrders = [];
  Product? _selectedProduct;
  String _searchQuery = '';
  bool _busy = false;
  String? _error;

  AppMode get mode => _mode;
  AuthUser? get currentUser => _currentUser;
  Shop? get currentShop => _currentShop;
  ShopDashboard? get shopDashboard => _shopDashboard;
  List<Shop> get shops => List.unmodifiable(_shops);
  List<Product> get products => List.unmodifiable(_products);
  List<CartItem> get cartItems => List.unmodifiable(_cartItems);
  List<Order> get buyerOrders => List.unmodifiable(_buyerOrders);
  List<Order> get shopOrders => List.unmodifiable(_shopOrders);
  Product? get selectedProduct => _selectedProduct;
  String get searchQuery => _searchQuery;
  bool get busy => _busy;
  String? get error => _error;

  bool get isGuest => _mode == AppMode.guest;
  bool get isBuyer => _mode == AppMode.buyer;
  bool get isSeller => _mode == AppMode.seller;
  bool get isAuth => _mode == AppMode.auth;
  bool get isLaunch => _mode == AppMode.launch;

  List<Product> get filteredProducts {
    if (_searchQuery.trim().isEmpty) {
      return _products;
    }

    final query = _searchQuery.toLowerCase().trim();
    return _products.where((product) {
      return product.name.toLowerCase().contains(query) ||
          product.description.toLowerCase().contains(query) ||
          product.category.toLowerCase().contains(query) ||
          product.shopName.toLowerCase().contains(query);
    }).toList();
  }

  double get cartSubtotal => _cartItems.fold(0, (sum, item) => sum + item.lineTotal);

  Future<void> bootstrap() async {
    _mode = AppMode.launch;
    notifyListeners();
    await _runBusy(() async {
      try {
        _shops = await _api.fetchShops();
        _products = await _api.fetchProducts();
      } catch (e) {
        // Backend unavailable, use mock data
        _loadMockData();
      }
      _cartItems = [];
      _buyerOrders = [];
      _shopOrders = [];
      _shopDashboard = null;
      _selectedProduct = null;
      _error = null;
    });
  }

  Future<void> goGuest() async {
    await _runBusy(() async {
      _mode = AppMode.guest;
      _currentUser = null;
      _currentShop = null;
      _selectedProduct = null;
      _error = null;
      try {
        _shops = await _api.fetchShops();
        _products = await _api.fetchProducts();
      } catch (e) {
        _loadMockData();
      }
    });
  }

  void showAuth() {
    _mode = AppMode.auth;
    _error = null;
    notifyListeners();
  }

  Future<void> login({required String email, required String password}) async {
    await _runBusy(() async {
      try {
        final result = await _api.login(email: email, password: password);
        _currentUser = result.user;
        _currentShop = result.shop;
        _selectedProduct = null;
        _error = null;
        if (result.user.role == 'seller') {
          _mode = AppMode.seller;
          await _loadSellerState();
        } else {
          _mode = AppMode.buyer;
          await _loadBuyerState();
        }
      } catch (e) {
        // Backend unavailable, use mock login
        _currentUser = AuthUser(
          id: email.contains('seller') ? 2 : 1,
          name: email.split('@').first,
          email: email,
          role: email.contains('seller') ? 'seller' : 'buyer',
          avatarUrl: 'https://via.placeholder.com/100?text=User',
        );
        _currentShop = null;
        _selectedProduct = null;
        _error = null;
        if (_currentUser!.role == 'seller') {
          _mode = AppMode.seller;
          await _loadSellerState();
        } else {
          _mode = AppMode.buyer;
          await _loadBuyerState();
        }
      }
    });
  }

  Future<void> register({required String name, required String email, required String password, required String role}) async {
    await _runBusy(() async {
      try {
        final result = await _api.register(name: name, email: email, password: password, role: role);
        _currentUser = result.user;
        _currentShop = result.shop;
        _selectedProduct = null;
        _error = null;
        if (role == 'seller') {
          _mode = AppMode.seller;
          await _loadSellerState();
        } else {
          _mode = AppMode.buyer;
          await _loadBuyerState();
        }
      } catch (e) {
        // Backend unavailable, use mock register
        _currentUser = AuthUser(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          name: name,
          email: email,
          role: role,
          avatarUrl: 'https://via.placeholder.com/100?text=User',
        );
        _currentShop = null;
        _selectedProduct = null;
        _error = null;
        if (role == 'seller') {
          _mode = AppMode.seller;
          await _loadSellerState();
        } else {
          _mode = AppMode.buyer;
          await _loadBuyerState();
        }
      }
    });
  }

  Future<void> logout() async {
    _currentUser = null;
    _currentShop = null;
    _shopDashboard = null;
    _cartItems = [];
    _buyerOrders = [];
    _shopOrders = [];
    _selectedProduct = null;
    await goGuest();
  }

  Future<void> reloadCurrentView() async {
    if (isBuyer) {
      await _loadBuyerState();
    } else if (isSeller) {
      await _loadSellerState();
    } else if (isGuest) {
      await goGuest();
    }
  }

  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void selectProduct(Product product) {
    _selectedProduct = product;
    notifyListeners();
  }

  Future<void> loadGuestProduct(Product product) async {
    _selectedProduct = product;
    notifyListeners();
  }

  Future<void> addToCart(Product product, {int quantity = 1}) async {
    if (_currentUser == null || _currentUser!.role != 'buyer') {
      return;
    }

    await _runBusy(() async {
      final summary = await _api.addToCart(userId: _currentUser!.id, productId: product.id, quantity: quantity);
      _cartItems = summary.items;
      _products = await _api.fetchProducts();
      _buyerOrders = await _api.fetchBuyerOrders(_currentUser!.id);
    });
  }

  Future<void> updateCartItem(Product product, int quantity) async {
    if (_currentUser == null || _currentUser!.role != 'buyer') {
      return;
    }

    await _runBusy(() async {
      final summary = await _api.updateCartItem(userId: _currentUser!.id, productId: product.id, quantity: quantity);
      _cartItems = summary.items;
      _products = await _api.fetchProducts();
    });
  }

  Future<void> removeFromCart(Product product) async {
    if (_currentUser == null || _currentUser!.role != 'buyer') {
      return;
    }

    await _runBusy(() async {
      final summary = await _api.removeCartItem(userId: _currentUser!.id, productId: product.id);
      _cartItems = summary.items;
      _products = await _api.fetchProducts();
    });
  }

  Future<void> clearCart() async {
    if (_currentUser == null || _currentUser!.role != 'buyer') {
      return;
    }

    await _runBusy(() async {
      final summary = await _api.clearCart(_currentUser!.id);
      _cartItems = summary.items;
      _products = await _api.fetchProducts();
    });
  }

  Future<void> checkout(String shippingAddress) async {
    if (_currentUser == null || _currentUser!.role != 'buyer') {
      return;
    }

    await _runBusy(() async {
      final result = await _api.checkout(userId: _currentUser!.id, shippingAddress: shippingAddress);
      _buyerOrders = await _api.fetchBuyerOrders(_currentUser!.id);
      _cartItems = [];
      _products = await _api.fetchProducts();
      if (result.orders.isNotEmpty) {
        _selectedProduct = null;
      }
    });
  }

  Future<void> createShop({required String name, required String description}) async {
    if (_currentUser == null || _currentUser!.role != 'seller') {
      return;
    }

    await _runBusy(() async {
      _currentShop = await _api.createShop(
        ownerUserId: _currentUser!.id,
        name: name,
        description: description,
      );
      await _loadSellerState();
    });
  }

  Future<void> addOrUpdateProduct({
    int? productId,
    required String name,
    required String description,
    required String category,
    required double price,
    required int stock,
    PickedFileData? pickedImage,
  }) async {
    if (_currentUser == null || _currentUser!.role != 'seller' || _currentShop == null) {
      return;
    }

    await _runBusy(() async {
      String? imageUrl;
      if (pickedImage != null) {
        imageUrl = await _api.uploadProductImage(pickedImage);
      }

      if (productId == null) {
        await _api.createProduct(
          shopId: _currentShop!.id,
          ownerUserId: _currentUser!.id,
          name: name,
          description: description,
          price: price,
          stock: stock,
          category: category,
          imageUrl: imageUrl,
        );
      } else {
        await _api.updateProduct(
          productId: productId,
          ownerUserId: _currentUser!.id,
          name: name,
          description: description,
          price: price,
          stock: stock,
          category: category,
          imageUrl: imageUrl,
        );
      }

      await _loadSellerState();
    });
  }

  Future<void> deleteProduct(int productId) async {
    if (_currentUser == null || _currentUser!.role != 'seller') {
      return;
    }

    await _runBusy(() async {
      await _api.deleteProduct(productId: productId, ownerUserId: _currentUser!.id);
      await _loadSellerState();
    });
  }

  Future<void> setOrderStatus(int orderId, String status) async {
    if (_currentUser == null || _currentUser!.role != 'seller') {
      return;
    }

    await _runBusy(() async {
      await _api.updateOrderStatus(orderId: orderId, status: status);
      await _loadSellerState();
    });
  }

  Future<Invoice> fetchInvoice(int orderId) async {
    return _api.fetchInvoice(orderId);
  }

  Future<void> openBuyerState() async {
    _mode = AppMode.buyer;
    notifyListeners();
    await _loadBuyerState();
  }

  Future<void> openSellerState() async {
    _mode = AppMode.seller;
    notifyListeners();
    await _loadSellerState();
  }

  Future<void> _loadBuyerState() async {
    try {
      _shops = await _api.fetchShops();
      _products = await _api.fetchProducts();
      _cartItems = (await _api.fetchCart(_currentUser!.id)).items;
      _buyerOrders = await _api.fetchBuyerOrders(_currentUser!.id);
    } catch (e) {
      // Backend unavailable, use mock data
      _loadMockData();
    }
    notifyListeners();
  }

  Future<void> _loadSellerState() async {
    if (_currentUser == null) {
      return;
    }

    try {
      _shops = await _api.fetchShops();
      _currentShop = await _api.fetchShopByOwner(_currentUser!.id);
      _products = await _api.fetchProducts();
      if (_currentShop != null) {
        _shopDashboard = await _api.fetchShopDashboard(_currentShop!.id);
        _shopOrders = await _api.fetchShopOrders(_currentShop!.id);
      } else {
        _shopDashboard = null;
        _shopOrders = [];
      }
    } catch (e) {
      // Backend unavailable, use mock data for seller
      _loadMockDataForSeller();
    }
    notifyListeners();
  }

  Future<void> _runBusy(Future<void> Function() work) async {
    _busy = true;
    _error = null;
    notifyListeners();

    try {
      await work();
    } catch (error) {
      _error = error.toString();
      rethrow;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  void _loadMockData() {
    // Remove seeded products/shops: keep empty lists so the app starts without seeded inventory
    _shops = [];
    _products = [];
    _buyerOrders = [];
    _shopOrders = [];
    _shopDashboard = null;
  }

  void _loadMockDataForSeller() {
    // For sellers, start with no seeded products or orders
    _shops = [];
    _products = [];
    _shopOrders = [];
    _buyerOrders = [];
    _shopDashboard = null;
    if (_currentUser != null && _currentUser!.role == 'seller') {
      _currentShop = Shop(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        ownerUserId: _currentUser!.id,
        name: '${_currentUser!.name}\'s Shop',
        description: '',
        logoUrl: '',
      );
    }
  }
}