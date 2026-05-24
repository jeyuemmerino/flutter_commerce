import 'package:flutter/material.dart';

import '../models/commerce_models.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onAddToCart,
  });

  final Product product;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFFFFF), Color(0xFFF8EFE3)],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x15000000),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF1F2937),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  product.category.isEmpty ? '?' : product.category.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              product.category,
              style: const TextStyle(
                color: Color(0xFFB45309),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              product.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF6B7280)),
            ),
            const Spacer(),
            Row(
              children: [
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: onAddToCart,
                  child: const Text('Add'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}