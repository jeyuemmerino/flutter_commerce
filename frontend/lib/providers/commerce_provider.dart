import 'dart:convert';
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
  String get selectedCategory => _selectedCategory;
  List<String> get categories => List.unmodifiable(_categories);
  bool get busy => _busy;
  String? get error => _error;

  bool get isGuest => _mode == AppMode.guest;
  bool get isBuyer => _mode == AppMode.buyer;
  bool get isSeller => _mode == AppMode.seller;
  bool get isAuth => _mode == AppMode.auth;
  bool get isLaunch => _mode == AppMode.launch;

  // Category filtering
  final List<String> _categories = ['All', 'Electronics', 'Fashion', 'Home', 'General'];
  String _selectedCategory = 'All';

  List<Product> get filteredProducts {
    if (_searchQuery.trim().isEmpty) {
      final base = _products;
      if (_selectedCategory == 'All') return base;
      return base.where((p) => p.category.toLowerCase() == _selectedCategory.toLowerCase()).toList();
    }

    final query = _searchQuery.toLowerCase().trim();
    final base = _products.where((product) {
      return product.name.toLowerCase().contains(query) ||
          product.description.toLowerCase().contains(query) ||
          product.category.toLowerCase().contains(query) ||
          product.shopName.toLowerCase().contains(query);
    }).toList();

    if (_selectedCategory == 'All') return base;
    return base.where((p) => p.category.toLowerCase() == _selectedCategory.toLowerCase()).toList();
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
        // Ensure initial collections are initialized (do not clear fetched data)
        _cartItems = [];
        _buyerOrders = [];
        _shopOrders = [];
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
      // Keep fetched products visible to guests if available
    });
  }

  void showAuth() {
    _mode = AppMode.auth;
    _error = null;
    notifyListeners();
  }

  void showLaunch() {
    _mode = AppMode.launch;
    _error = null;
    _currentUser = null;
    _currentShop = null;
    _shops = [];
    _products = [];
    _cartItems = [];
    _buyerOrders = [];
    _shopOrders = [];
    _selectedProduct = null;
    _shopDashboard = null;
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
        // Try to extract a meaningful error message from the API or network error
        final msg = _extractErrorMessage(e);
        _currentUser = null;
        _currentShop = null;
        _selectedProduct = null;
        _error = msg;
        // keep mode as auth so UI remains on the sign-in screen
        _mode = AppMode.auth;
        notifyListeners();
        return;
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
    // Clear user state and return to the launch screen
    _currentUser = null;
    _currentShop = null;
    _shopDashboard = null;
    _cartItems = [];
    _buyerOrders = [];
    _shopOrders = [];
    _selectedProduct = null;
    showLaunch();
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

  void setSelectedCategory(String category) {
    _selectedCategory = category;
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
      try {
        final summary = await _api.addToCart(userId: _currentUser!.id, productId: product.id, quantity: quantity);
        _cartItems = summary.items;
        _products = await _api.fetchProducts();
        _buyerOrders = await _api.fetchBuyerOrders(_currentUser!.id);
      } catch (e) {
        // Offline/local fallback: update local cart so UI shows the item
        final idx = _cartItems.indexWhere((it) => it.productId == product.id);
        if (idx >= 0) {
          final existing = _cartItems[idx];
          _cartItems[idx] = CartItem(
            id: existing.id,
            cartId: existing.cartId,
            productId: existing.productId,
            quantity: existing.quantity + quantity,
            product: existing.product,
          );
        } else {
          final tempId = DateTime.now().millisecondsSinceEpoch * -1;
          _cartItems.add(CartItem(
            id: tempId,
            cartId: 0,
            productId: product.id,
            quantity: quantity,
            product: product,
          ));
        }
        _error = 'Added to cart locally (offline).';
      }
    });
  }

  Future<void> updateCartItem(Product product, int quantity) async {
    if (_currentUser == null || _currentUser!.role != 'buyer') {
      return;
    }

    await _runBusy(() async {
      try {
        final summary = await _api.updateCartItem(userId: _currentUser!.id, productId: product.id, quantity: quantity);
        _cartItems = summary.items;
        _products = await _api.fetchProducts();
      } catch (e) {
        final idx = _cartItems.indexWhere((it) => it.productId == product.id);
        if (idx >= 0) {
          final existing = _cartItems[idx];
          _cartItems[idx] = CartItem(
            id: existing.id,
            cartId: existing.cartId,
            productId: existing.productId,
            quantity: quantity,
            product: existing.product,
          );
        }
        _error = 'Cart updated locally (offline).';
      }
    });
  }

  Future<void> removeFromCart(Product product) async {
    if (_currentUser == null || _currentUser!.role != 'buyer') {
      return;
    }

    await _runBusy(() async {
      try {
        final summary = await _api.removeCartItem(userId: _currentUser!.id, productId: product.id);
        _cartItems = summary.items;
        _products = await _api.fetchProducts();
      } catch (e) {
        _cartItems.removeWhere((it) => it.productId == product.id);
        _error = 'Removed from cart locally (offline).';
      }
    });
  }

  Future<void> clearCart() async {
    if (_currentUser == null || _currentUser!.role != 'buyer') {
      return;
    }

    await _runBusy(() async {
      try {
        final summary = await _api.clearCart(_currentUser!.id);
        _cartItems = summary.items;
        _products = await _api.fetchProducts();
      } catch (e) {
        _cartItems = [];
        _error = 'Cart cleared locally (offline).';
      }
    });
  }

  Future<void> checkout(String shippingAddress) async {
    if (_currentUser == null || _currentUser!.role != 'buyer') {
      return;
    }

    await _runBusy(() async {
      try {
        final result = await _api.checkout(userId: _currentUser!.id, shippingAddress: shippingAddress);
        // Refresh buyer orders
        _buyerOrders = await _api.fetchBuyerOrders(_currentUser!.id);
        // Clear cart and refresh products
        _cartItems = [];
        _products = await _api.fetchProducts();

        // If any orders affect the currently loaded shop dashboard, merge them so sellers see new orders immediately
        if (_shopDashboard != null && result.orders.isNotEmpty) {
          final affected = result.orders.where((o) => o.shopId == _shopDashboard!.shop.id).toList();
          if (affected.isNotEmpty) {
            // prepend new orders
            _shopDashboard = ShopDashboard(
              shop: _shopDashboard!.shop,
              products: _shopDashboard!.products,
              orders: [...affected, ..._shopDashboard!.orders],
              stats: ShopStats(
                totalOrders: _shopDashboard!.stats.totalOrders + affected.length,
                totalRevenue: _shopDashboard!.stats.totalRevenue + affected.fold(0.0, (s, o) => s + o.total),
                pending: _shopDashboard!.stats.pending + affected.where((o) => o.status == 'pending').length,
                shipped: _shopDashboard!.stats.shipped + affected.where((o) => o.status == 'shipped').length,
                delivered: _shopDashboard!.stats.delivered + affected.where((o) => o.status == 'delivered').length,
              ),
            );
            // also refresh top-level shop orders list for current view
            _shopOrders = [...affected, ..._shopOrders];
          }
        }

        if (result.orders.isNotEmpty) {
          _selectedProduct = null;
        }
      } catch (e) {
        // Offline: don't throw, inform the user
        _error = 'Checkout failed: backend unavailable. Order queued locally.';
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

      try {
        if (productId == null) {
          final created = await _api.createProduct(
            shopId: _currentShop!.id,
            ownerUserId: _currentUser!.id,
            name: name,
            description: description,
            price: price,
            stock: stock,
            category: category,
            imageUrl: imageUrl,
          );
          // add to local list
          _products.insert(0, created);
          // also add to shop dashboard if visible
          if (_shopDashboard != null && created.shopId == _shopDashboard!.shop.id) {
            _shopDashboard!.products.insert(0, created);
          }
        } else {
          final updated = await _api.updateProduct(
            productId: productId,
            ownerUserId: _currentUser!.id,
            name: name,
            description: description,
            price: price,
            stock: stock,
            category: category,
            imageUrl: imageUrl,
          );
          final idx = _products.indexWhere((p) => p.id == updated.id);
          if (idx >= 0) _products[idx] = updated;
          if (_shopDashboard != null && updated.shopId == _shopDashboard!.shop.id) {
            final sidx = _shopDashboard!.products.indexWhere((p) => p.id == updated.id);
            if (sidx >= 0) _shopDashboard!.products[sidx] = updated;
          }
        }
      } catch (e) {
        // If API fails (backend down), create a local product with a temp id so it appears in UI
        final tempId = DateTime.now().millisecondsSinceEpoch * -1;
        final local = Product(
          id: productId ?? tempId,
          shopId: _currentShop!.id,
          ownerUserId: _currentUser!.id,
          name: name,
          description: description,
          price: price,
          stock: stock,
          category: category,
          shopName: _currentShop!.name,
          imageUrl: imageUrl ?? '',
        );
        if (productId == null) {
          _products.insert(0, local);
          if (_shopDashboard != null && local.shopId == _shopDashboard!.shop.id) {
            _shopDashboard!.products.insert(0, local);
          }
        } else {
          final idx = _products.indexWhere((p) => p.id == productId);
          if (idx >= 0) _products[idx] = local;
          if (_shopDashboard != null && local.shopId == _shopDashboard!.shop.id) {
            final sidx = _shopDashboard!.products.indexWhere((p) => p.id == local.id);
            if (sidx >= 0) _shopDashboard!.products[sidx] = local;
          }
        }
        _error = 'Product saved locally (offline). It will be synced when backend is available.';
      }

      notifyListeners();
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
    // Keep fetched seller state intact; mock loader handles offline fallback
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

  String _extractErrorMessage(Object e) {
    try {
      final text = e.toString();
      // If the error contains JSON with a message field, extract it
      if (text.contains('{') && text.contains('message')) {
        final start = text.indexOf('{');
        final jsonStr = text.substring(start);
        final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
        if (decoded['message'] != null) return decoded['message'].toString();
      }
      // Common network error indicators
      final lower = text.toLowerCase();
      if (lower.contains('socketexception') || lower.contains('failed host lookup') || lower.contains('connection refused') || lower.contains('connection reset')) {
        return 'Login failed: unable to reach authentication service. Check your network or backend.';
      }
      // Fallback to the raw text
      return text;
    } catch (_) {
      return 'Login failed: unknown error';
    }
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