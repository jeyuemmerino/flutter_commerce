import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/commerce_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/section_card.dart';
import 'product_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onSelectCheckout});

  final VoidCallback onSelectCheckout;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommerceProvider>();
    final featuredProducts = provider.products.take(4).toList();
    final categories = provider.products.map((product) => product.category).toSet().toList();

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: SectionCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Local Marketplace Demo',
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Browse products, simulate checkout, and explore seller analytics with no auth or cloud services.',
                      style: TextStyle(color: Color(0xFF6B7280)),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        FilledButton.icon(
                          onPressed: onSelectCheckout,
                          icon: const Icon(Icons.local_fire_department),
                          label: const Text('Go to checkout'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: provider.bootstrap,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Refresh data'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: categories
                    .map((category) => Chip(
                          label: Text(category),
                          backgroundColor: const Color(0xFFF3E7D7),
                        ))
                    .toList(),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 14)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    'Featured products',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const Spacer(),
                  Text('${provider.products.length} items'),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                mainAxisExtent: 320,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final product = featuredProducts[index];
                  return ProductCard(
                    product: product,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
                    ),
                    onAddToCart: () => provider.addToCart(product),
                  );
                },
                childCount: featuredProducts.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}