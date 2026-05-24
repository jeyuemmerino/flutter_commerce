class AuthUser {
  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.avatarUrl,
  });

  final int id;
  final String name;
  final String email;
  final String role;
  final String avatarUrl;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: _asInt(json['id']),
      name: _asString(json['name']),
      email: _asString(json['email']),
      role: _asString(json['role']),
      avatarUrl: _asString(json['avatarUrl'] ?? json['avatar_url']),
    );
  }
}

class Shop {
  const Shop({
    required this.id,
    required this.ownerUserId,
    required this.name,
    required this.description,
    required this.logoUrl,
  });

  final int id;
  final int ownerUserId;
  final String name;
  final String description;
  final String logoUrl;

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: _asInt(json['id']),
      ownerUserId: _asInt(json['ownerUserId'] ?? json['owner_user_id']),
      name: _asString(json['name']),
      description: _asString(json['description']),
      logoUrl: _asString(json['logoUrl'] ?? json['logo_url']),
    );
  }
}

class Product {
  const Product({
    required this.id,
    required this.shopId,
    required this.shopName,
    required this.ownerUserId,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.category,
    required this.imageUrl,
  });

  final int id;
  final int shopId;
  final String shopName;
  final int ownerUserId;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String category;
  final String imageUrl;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: _asInt(json['id']),
      shopId: _asInt(json['shopId'] ?? json['shop_id']),
      shopName: _asString(json['shopName'] ?? json['shop_name']),
      ownerUserId: _asInt(json['ownerUserId'] ?? json['owner_user_id']),
      name: _asString(json['name']),
      description: _asString(json['description']),
      price: _asDouble(json['price']),
      stock: _asInt(json['stock']),
      category: _asString(json['category']),
      imageUrl: _asString(json['imageUrl'] ?? json['image_url']),
    );
  }
}

class CartItem {
  const CartItem({
    required this.id,
    required this.cartId,
    required this.productId,
    required this.quantity,
    required this.product,
  });

  final int id;
  final int cartId;
  final int productId;
  final int quantity;
  final Product product;

  double get lineTotal => product.price * quantity;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: _asInt(json['id']),
      cartId: _asInt(json['cartId'] ?? json['cart_id']),
      productId: _asInt(json['productId'] ?? json['product_id']),
      quantity: _asInt(json['quantity']),
      product: Product.fromJson(Map<String, dynamic>.from(json['product'] as Map)),
    );
  }
}

class OrderItem {
  const OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.imageUrl,
  });

  final int id;
  final int productId;
  final String productName;
  final double price;
  final int quantity;
  final String imageUrl;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: _asInt(json['id']),
      productId: _asInt(json['productId'] ?? json['product_id']),
      productName: _asString(json['productName'] ?? json['product_name']),
      price: _asDouble(json['price']),
      quantity: _asInt(json['quantity']),
      imageUrl: _asString(json['imageUrl'] ?? json['image_url']),
    );
  }
}

class Order {
  const Order({
    required this.id,
    required this.buyerUserId,
    required this.shopId,
    required this.status,
    required this.subtotal,
    required this.total,
    required this.shippingAddress,
    required this.shopName,
    required this.buyerName,
    required this.items,
    required this.createdAt,
  });

  final int id;
  final int buyerUserId;
  final int shopId;
  final String status;
  final double subtotal;
  final double total;
  final String shippingAddress;
  final String shopName;
  final String buyerName;
  final List<OrderItem> items;
  final DateTime createdAt;

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: _asInt(json['id']),
      buyerUserId: _asInt(json['buyerUserId'] ?? json['buyer_user_id']),
      shopId: _asInt(json['shopId'] ?? json['shop_id']),
      status: _asString(json['status']),
      subtotal: _asDouble(json['subtotal']),
      total: _asDouble(json['total']),
      shippingAddress: _asString(json['shippingAddress'] ?? json['shipping_address']),
      shopName: _asString(json['shopName'] ?? json['shop_name']),
      buyerName: _asString(json['buyerName'] ?? json['buyer_name']),
      items: (json['items'] as List<dynamic>? ?? const [])
          .map((item) => OrderItem.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
      createdAt: DateTime.tryParse(_asString(json['createdAt'] ?? json['created_at'])) ?? DateTime.now(),
    );
  }
}

class ShopStats {
  const ShopStats({
    required this.totalOrders,
    required this.totalRevenue,
    required this.pending,
    required this.shipped,
    required this.delivered,
  });

  final int totalOrders;
  final double totalRevenue;
  final int pending;
  final int shipped;
  final int delivered;

  factory ShopStats.fromJson(Map<String, dynamic> json) {
    return ShopStats(
      totalOrders: _asInt(json['totalOrders']),
      totalRevenue: _asDouble(json['totalRevenue']),
      pending: _asInt(json['pending']),
      shipped: _asInt(json['shipped']),
      delivered: _asInt(json['delivered']),
    );
  }
}

class ShopDashboard {
  const ShopDashboard({
    required this.shop,
    required this.products,
    required this.orders,
    required this.stats,
  });

  final Shop shop;
  final List<Product> products;
  final List<Order> orders;
  final ShopStats stats;

  factory ShopDashboard.fromJson(Map<String, dynamic> json) {
    return ShopDashboard(
      shop: Shop.fromJson(Map<String, dynamic>.from(json['shop'] as Map)),
      products: (json['products'] as List<dynamic>? ?? const [])
          .map((item) => Product.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
      orders: (json['orders'] as List<dynamic>? ?? const [])
          .map((item) => Order.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
      stats: ShopStats.fromJson(Map<String, dynamic>.from(json['stats'] as Map)),
    );
  }
}

class CartSummary {
  const CartSummary({
    required this.items,
    required this.subtotal,
  });

  final List<CartItem> items;
  final double subtotal;

  factory CartSummary.fromJson(Map<String, dynamic> json) {
    return CartSummary(
      items: (json['items'] as List<dynamic>? ?? const [])
          .map((item) => CartItem.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
      subtotal: _asDouble(json['subtotal']),
    );
  }
}

class CheckoutResult {
  const CheckoutResult({required this.orders});

  final List<Order> orders;

  factory CheckoutResult.fromJson(Map<String, dynamic> json) {
    return CheckoutResult(
      orders: (json['orders'] as List<dynamic>? ?? const [])
          .map((item) => Order.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
    );
  }
}

class Invoice {
  const Invoice({
    required this.invoiceNumber,
    required this.buyer,
    required this.shop,
    required this.order,
  });

  final String invoiceNumber;
  final AuthUser buyer;
  final Shop shop;
  final Order order;

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      invoiceNumber: _asString(json['invoiceNumber']),
      buyer: AuthUser.fromJson(Map<String, dynamic>.from(json['buyer'] as Map)),
      shop: Shop.fromJson(Map<String, dynamic>.from(json['shop'] as Map)),
      order: Order.fromJson(Map<String, dynamic>.from(json['order'] as Map)),
    );
  }
}

class ApiAuthResult {
  const ApiAuthResult({required this.user, required this.shop});

  final AuthUser user;
  final Shop? shop;

  factory ApiAuthResult.fromJson(Map<String, dynamic> json) {
    return ApiAuthResult(
      user: AuthUser.fromJson(Map<String, dynamic>.from(json['user'] as Map)),
      shop: json['shop'] == null ? null : Shop.fromJson(Map<String, dynamic>.from(json['shop'] as Map)),
    );
  }
}

String _asString(dynamic value) => value?.toString() ?? '';

int _asInt(dynamic value) => int.tryParse(value?.toString() ?? '') ?? 0;

double _asDouble(dynamic value) => double.tryParse(value?.toString() ?? '') ?? 0;