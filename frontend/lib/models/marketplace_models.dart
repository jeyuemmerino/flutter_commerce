class Product {
  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.category,
    this.imageUrl,
  });

  final int id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String category;
  final String? imageUrl;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: _asInt(json['id']),
      name: _asString(json['name']),
      description: _asString(json['description']),
      price: _asDouble(json['price']),
      stock: _asInt(json['stock']),
      category: _asString(json['category']),
      imageUrl: json['image_url']?.toString() ?? json['imageUrl']?.toString(),
    );
  }
}

class CartItem {
  CartItem({required this.product, required this.quantity});

  final Product product;
  int quantity;

  double get lineTotal => product.price * quantity;

  Map<String, dynamic> toOrderPayload() {
    return {
      'productId': product.id,
      'quantity': quantity,
    };
  }
}

class OrderSummary {
  const OrderSummary({
    required this.id,
    required this.items,
    required this.subtotal,
    required this.discountAmount,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    this.couponCode,
  });

  final int id;
  final List<CartItem> items;
  final double subtotal;
  final double discountAmount;
  final double totalPrice;
  final String status;
  final DateTime createdAt;
  final String? couponCode;

  factory OrderSummary.fromJson(Map<String, dynamic> json) {
    final parsedItems = (json['items'] as List<dynamic>? ?? const [])
        .map((item) {
          final map = Map<String, dynamic>.from(item as Map);
          final product = Product(
            id: _asInt(map['productId']),
            name: _asString(map['name']),
            description: '',
            price: _asDouble(map['price']),
            stock: 0,
            category: _asString(map['category']),
          );

          return CartItem(product: product, quantity: _asInt(map['quantity']));
        })
        .toList();

    return OrderSummary(
      id: _asInt(json['id']),
      items: parsedItems,
      subtotal: _asDouble(json['subtotal']),
      discountAmount: _asDouble(json['discountAmount'] ?? json['discount_amount']),
      totalPrice: _asDouble(json['totalPrice'] ?? json['total_price']),
      status: _asString(json['status']),
      createdAt: DateTime.tryParse(_asString(json['created_at'])) ?? DateTime.now(),
      couponCode: json['couponCode']?.toString() ?? json['coupon_code']?.toString(),
    );
  }
}

class AnalyticsSummary {
  const AnalyticsSummary({
    required this.totalRevenue,
    required this.totalOrders,
    required this.topProducts,
    required this.categoryPerformance,
    required this.bestSellingCategory,
  });

  final double totalRevenue;
  final int totalOrders;
  final List<Map<String, dynamic>> topProducts;
  final List<Map<String, dynamic>> categoryPerformance;
  final String bestSellingCategory;

  factory AnalyticsSummary.fromJson(Map<String, dynamic> json) {
    return AnalyticsSummary(
      totalRevenue: _asDouble(json['totalRevenue']),
      totalOrders: _asInt(json['totalOrders']),
      topProducts: (json['topProducts'] as List<dynamic>? ?? const [])
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList(),
      categoryPerformance: (json['categoryPerformance'] as List<dynamic>? ?? const [])
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList(),
      bestSellingCategory: _asString(json['bestSellingCategory']),
    );
  }
}

class RecommendationBundle {
  const RecommendationBundle({
    required this.trending,
    required this.similarCategory,
    required this.frequentlyBoughtTogether,
  });

  final List<Product> trending;
  final List<Product> similarCategory;
  final List<Product> frequentlyBoughtTogether;

  factory RecommendationBundle.fromJson(Map<String, dynamic> json) {
    List<Product> parseProducts(String key) {
      return (json[key] as List<dynamic>? ?? const [])
          .map((item) => Product.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    }

    return RecommendationBundle(
      trending: parseProducts('trending'),
      similarCategory: parseProducts('similarCategory'),
      frequentlyBoughtTogether: parseProducts('frequentlyBoughtTogether'),
    );
  }
}

class CouponValidationResult {
  const CouponValidationResult({
    required this.valid,
    required this.message,
    this.code,
    this.discountType,
    this.value = 0,
  });

  final bool valid;
  final String message;
  final String? code;
  final String? discountType;
  final double value;

  factory CouponValidationResult.fromJson(Map<String, dynamic> json) {
    final coupon = json['coupon'] is Map ? Map<String, dynamic>.from(json['coupon'] as Map) : <String, dynamic>{};

    return CouponValidationResult(
      valid: json['valid'] == true,
      message: _asString(json['message']),
      code: coupon['code']?.toString(),
      discountType: coupon['discountType']?.toString(),
      value: _asDouble(coupon['value']),
    );
  }
}

class DescriptionResult {
  const DescriptionResult({required this.description});

  final String description;

  factory DescriptionResult.fromJson(Map<String, dynamic> json) {
    return DescriptionResult(description: _asString(json['description']));
  }
}

class SalesInsightResult {
  const SalesInsightResult({required this.insights});

  final List<String> insights;

  factory SalesInsightResult.fromJson(Map<String, dynamic> json) {
    return SalesInsightResult(
      insights: (json['insights'] as List<dynamic>? ?? const []).map((item) => item.toString()).toList(),
    );
  }
}

int _asInt(dynamic value) => int.tryParse(value?.toString() ?? '') ?? 0;

double _asDouble(dynamic value) => double.tryParse(value?.toString() ?? '') ?? 0;

String _asString(dynamic value) => value?.toString() ?? '';