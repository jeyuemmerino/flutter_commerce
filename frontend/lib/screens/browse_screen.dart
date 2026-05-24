import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/commerce_models.dart';
import '../providers/commerce_provider.dart';
import '../utils/app_config.dart';

class BrowseScreen extends StatelessWidget {
  const BrowseScreen({super.key, required this.onProductTap});

  final void Function(Product product) onProductTap;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommerceProvider>();
    final products = provider.filteredProducts;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: const Text('Browse products'),
            actions: [IconButton(onPressed: provider.reloadCurrentView, icon: const Icon(Icons.refresh))],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(72),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: TextField(
                  onChanged: provider.setSearchQuery,
                  decoration: InputDecoration(
                    hintText: 'Search products or shops',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
              ),
            ),
          ),
          if (products.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 64),
                child: Center(child: Text('No products found.')),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisExtent: 320,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final product = products[index];
                    return _ProductCard(
                      product: product,
                      isBuyer: provider.isBuyer,
                      onTap: () => onProductTap(product),
                      onAddToCart: provider.isBuyer ? () => provider.addToCart(product) : null,
                    );
                  },
                  childCount: products.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product, required this.onTap, required this.onAddToCart, required this.isBuyer});

  final Product product;
  final VoidCallback onTap;
  final VoidCallback? onAddToCart;
  final bool isBuyer;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.2,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: product.imageUrl.isEmpty
                    ? Container(
                        color: const Color(0xFFE2E8F0),
                        child: const Center(child: Icon(Icons.image_not_supported, size: 44)),
                      )
                    : Image.network(
                        _resolveImageUrl(product.imageUrl),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFFE2E8F0),
                          child: const Center(child: Icon(Icons.image_not_supported, size: 44)),
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.shopName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange)),
                  const SizedBox(height: 4),
                  Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(product.category, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text('\$${product.price.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  if (isBuyer)
                    FilledButton(onPressed: onAddToCart, child: const Text('Add to cart'))
                  else
                    const Text('Tap to view details'),
                ],
              ),
            ),
          ],
        ),
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