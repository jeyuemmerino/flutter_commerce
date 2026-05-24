import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../models/commerce_models.dart';
import '../utils/app_config.dart';

class PickedFileData {
  const PickedFileData({this.bytes, this.path, this.name});

  final Uint8List? bytes;
  final String? path;
  final String? name;
}

class CommerceApiService {
  const CommerceApiService();

  Uri _uri(String path, [Map<String, dynamic>? queryParameters]) {
    return Uri.parse('$apiBaseUrl$path').replace(
      queryParameters: queryParameters?.map((key, value) => MapEntry(key, value.toString())),
    );
  }

  Future<ApiAuthResult> register({required String name, required String email, required String password, required String role}) async {
    final response = await http.post(
      _uri('/api/auth/register'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      }),
    );
    _ensureSuccess(response);
    return ApiAuthResult.fromJson(Map<String, dynamic>.from(jsonDecode(response.body) as Map));
  }

  Future<ApiAuthResult> login({required String email, required String password}) async {
    final response = await http.post(
      _uri('/api/auth/login'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    _ensureSuccess(response);
    return ApiAuthResult.fromJson(Map<String, dynamic>.from(jsonDecode(response.body) as Map));
  }

  Future<ApiAuthResult> fetchMe(int userId) async {
    final response = await http.get(_uri('/api/auth/me/$userId'));
    _ensureSuccess(response);
    return ApiAuthResult.fromJson(Map<String, dynamic>.from(jsonDecode(response.body) as Map));
  }

  Future<AuthUser> updateProfile({
    required int userId,
    required String name,
    required String email,
    String? password,
  }) async {
    final body = {
      'name': name,
      'email': email,
    };
    if (password != null && password.isNotEmpty) {
      body['password'] = password;
    }
    final response = await http.put(
      _uri('/api/auth/profile/$userId'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    _ensureSuccess(response);
    return AuthUser.fromJson(Map<String, dynamic>.from(jsonDecode(response.body) as Map));
  }

  Future<List<Shop>> fetchShops() async {
    final response = await http.get(_uri('/api/shops'));
    _ensureSuccess(response);
    final data = jsonDecode(response.body) as List<dynamic>;
    return data.map((item) => Shop.fromJson(Map<String, dynamic>.from(item as Map))).toList();
  }

  Future<Shop?> fetchShopByOwner(int ownerUserId) async {
    final response = await http.get(_uri('/api/shops/owner/$ownerUserId'));
    if (response.statusCode == 404) {
      return null;
    }
    _ensureSuccess(response);
    return Shop.fromJson(Map<String, dynamic>.from(jsonDecode(response.body) as Map));
  }

  Future<Shop> createShop({required int ownerUserId, required String name, required String description, PickedFileData? logo}) async {
    final response = await http.post(
      _uri('/api/shops'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'ownerUserId': ownerUserId,
        'name': name,
        'description': description,
        'logoUrl': '',
      }),
    );
    _ensureSuccess(response);
    return Shop.fromJson(Map<String, dynamic>.from(jsonDecode(response.body) as Map));
  }

  Future<ShopDashboard> fetchShopDashboard(int shopId) async {
    final response = await http.get(_uri('/api/shops/$shopId/dashboard'));
    _ensureSuccess(response);
    return ShopDashboard.fromJson(Map<String, dynamic>.from(jsonDecode(response.body) as Map));
  }

  Future<List<Product>> fetchProducts({int? shopId}) async {
    final response = await http.get(_uri('/api/products', shopId == null ? null : {'shopId': shopId}));
    _ensureSuccess(response);
    final data = jsonDecode(response.body) as List<dynamic>;
    return data.map((item) => Product.fromJson(Map<String, dynamic>.from(item as Map))).toList();
  }

  Future<Product> fetchProduct(int productId) async {
    final response = await http.get(_uri('/api/products/$productId'));
    _ensureSuccess(response);
    return Product.fromJson(Map<String, dynamic>.from(jsonDecode(response.body) as Map));
  }

  Future<String?> uploadProductImage(PickedFileData file) async {
    final request = http.MultipartRequest('POST', _uri('/api/products/upload-image'));

    if (file.bytes != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        file.bytes!,
        filename: file.name ?? 'product-image.png',
      ));
    } else if (file.path != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        file.path!,
        filename: file.name,
      ));
    } else {
      return null;
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    _ensureSuccess(response);
    return (jsonDecode(response.body) as Map<String, dynamic>)['imageUrl']?.toString();
  }

  Future<Product> createProduct({
    required int shopId,
    required int ownerUserId,
    required String name,
    required String description,
    required double price,
    required int stock,
    required String category,
    String? imageUrl,
  }) async {
    final response = await http.post(
      _uri('/api/products'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'shopId': shopId,
        'ownerUserId': ownerUserId,
        'name': name,
        'description': description,
        'price': price,
        'stock': stock,
        'category': category,
        'imageUrl': imageUrl ?? '',
      }),
    );
    _ensureSuccess(response);
    return Product.fromJson(Map<String, dynamic>.from(jsonDecode(response.body) as Map));
  }

  Future<Product> updateProduct({
    required int productId,
    required int ownerUserId,
    required String name,
    required String description,
    required double price,
    required int stock,
    required String category,
    String? imageUrl,
  }) async {
    final response = await http.put(
      _uri('/api/products/$productId'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'ownerUserId': ownerUserId,
        'name': name,
        'description': description,
        'price': price,
        'stock': stock,
        'category': category,
        'imageUrl': imageUrl ?? '',
      }),
    );
    _ensureSuccess(response);
    return Product.fromJson(Map<String, dynamic>.from(jsonDecode(response.body) as Map));
  }

  Future<void> deleteProduct({required int productId, required int ownerUserId}) async {
    final response = await http.delete(
      _uri('/api/products/$productId', {'ownerUserId': ownerUserId}),
    );
    _ensureSuccess(response);
  }

  Future<CartSummary> fetchCart(int userId) async {
    final response = await http.get(_uri('/api/cart/$userId'));
    _ensureSuccess(response);
    return CartSummary.fromJson(Map<String, dynamic>.from(jsonDecode(response.body) as Map));
  }

  Future<CartSummary> addToCart({required int userId, required int productId, int quantity = 1}) async {
    final response = await http.post(
      _uri('/api/cart/items'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'productId': productId,
        'quantity': quantity,
      }),
    );
    _ensureSuccess(response);
    return CartSummary.fromJson(Map<String, dynamic>.from(jsonDecode(response.body) as Map));
  }

  Future<CartSummary> updateCartItem({required int userId, required int productId, required int quantity}) async {
    final response = await http.put(
      _uri('/api/cart/items/$productId'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'quantity': quantity,
      }),
    );
    _ensureSuccess(response);
    return CartSummary.fromJson(Map<String, dynamic>.from(jsonDecode(response.body) as Map));
  }

  Future<CartSummary> removeCartItem({required int userId, required int productId}) async {
    final response = await http.delete(
      _uri('/api/cart/items/$productId', {'userId': userId}),
    );
    _ensureSuccess(response);
    return CartSummary.fromJson(Map<String, dynamic>.from(jsonDecode(response.body) as Map));
  }

  Future<CartSummary> clearCart(int userId) async {
    final response = await http.delete(_uri('/api/cart/$userId'));
    _ensureSuccess(response);
    return CartSummary.fromJson(Map<String, dynamic>.from(jsonDecode(response.body) as Map));
  }

  Future<CheckoutResult> checkout({required int userId, required String shippingAddress}) async {
    final response = await http.post(
      _uri('/api/orders/checkout'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'shippingAddress': shippingAddress,
      }),
    );
    _ensureSuccess(response);
    return CheckoutResult.fromJson(Map<String, dynamic>.from(jsonDecode(response.body) as Map));
  }

  Future<List<Order>> fetchBuyerOrders(int userId) async {
    final response = await http.get(_uri('/api/orders/buyer/$userId'));
    _ensureSuccess(response);
    final data = jsonDecode(response.body) as List<dynamic>;
    return data.map((item) => Order.fromJson(Map<String, dynamic>.from(item as Map))).toList();
  }

  Future<List<Order>> fetchShopOrders(int shopId) async {
    final response = await http.get(_uri('/api/orders/shop/$shopId'));
    _ensureSuccess(response);
    final data = jsonDecode(response.body) as List<dynamic>;
    return data.map((item) => Order.fromJson(Map<String, dynamic>.from(item as Map))).toList();
  }

  Future<Order> updateOrderStatus({required int orderId, required String status}) async {
    final response = await http.patch(
      _uri('/api/orders/$orderId/status'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'status': status}),
    );
    _ensureSuccess(response);
    return Order.fromJson(Map<String, dynamic>.from(jsonDecode(response.body) as Map));
  }

  Future<Invoice> fetchInvoice(int orderId) async {
    final response = await http.get(_uri('/api/orders/$orderId/invoice'));
    _ensureSuccess(response);
    return Invoice.fromJson(Map<String, dynamic>.from(jsonDecode(response.body) as Map));
  }

  void _ensureSuccess(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    throw Exception(response.body.isEmpty ? 'Request failed' : response.body);
  }
}