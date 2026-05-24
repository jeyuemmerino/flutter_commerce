import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/marketplace_provider.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MarketplaceProvider>();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              onChanged: provider.setSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search products, categories, or descriptions',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${provider.filteredProducts.length} matching products',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                itemCount: provider.filteredProducts.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  mainAxisExtent: 320,
                ),
                itemBuilder: (context, index) {
                  final product = provider.filteredProducts[index];
                  return ProductCard(
                    product: product,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
                    ),
                    onAddToCart: () => provider.addToCart(product),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}