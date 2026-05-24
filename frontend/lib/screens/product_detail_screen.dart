import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/commerce_models.dart';
import '../providers/commerce_provider.dart';
import '../utils/app_config.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommerceProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: product.imageUrl.isEmpty
                ? Container(
                    height: 240,
                    color: const Color(0xFFE2E8F0),
                    child: const Center(child: Icon(Icons.image_not_supported, size: 72)),
                  )
                : Image.network(
                    _resolveImageUrl(product.imageUrl),
                    height: 240,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 240,
                      color: const Color(0xFFE2E8F0),
                      child: const Center(child: Icon(Icons.image_not_supported, size: 72)),
                    ),
                  ),
          ),
          const SizedBox(height: 20),
          Text(product.shopName, style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(product.name, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(product.description),
          const SizedBox(height: 16),
          Row(
            children: [
              Text('\$${product.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
              const Spacer(),
              Text('Stock: ${product.stock}'),
            ],
          ),
          const SizedBox(height: 20),
          if (provider.isBuyer)
            FilledButton.icon(
              onPressed: () async {
                await provider.addToCart(product);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to cart')));
                }
              },
              icon: const Icon(Icons.shopping_cart),
              label: const Text('Add to cart'),
            ),
        ],
      ),
    );
  }

  String _resolveImageUrl(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return imageUrl;
    }
    return '$apiBaseUrl$imageUrl';
  }
}