import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/commerce_models.dart';
import '../providers/commerce_provider.dart';
import '../utils/app_config.dart';
import 'auth_screen.dart';

class BrowseScreen extends StatelessWidget {
  const BrowseScreen({super.key, required this.onProductTap, this.onGuestExit});

  final void Function(Product product) onProductTap;
  final VoidCallback? onGuestExit;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommerceProvider>();
    final products = provider.filteredProducts;

    return SafeArea(
      top: true,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            centerTitle: true,
            automaticallyImplyLeading: false,
            toolbarHeight: 64,
            titleTextStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black),
            title: const Text('Browse products'),
            actions: [
              IconButton(onPressed: provider.reloadCurrentView, icon: const Icon(Icons.refresh)),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(140),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: provider.categories.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 8),
                        itemBuilder: (context, idx) {
                          final c = provider.categories[idx];
                          final selected = provider.selectedCategory == c;
                          return ChoiceChip(
                            label: Text(c),
                            selected: selected,
                            onSelected: (_) => provider.setSelectedCategory(c),
                            selectedColor: Theme.of(context).colorScheme.primary.withAlpha((0.12 * 255).round()),
                            backgroundColor: Colors.grey.shade100,
                            labelStyle: TextStyle(color: selected ? Theme.of(context).colorScheme.primary : Colors.black87),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Search field beneath chips
                    TextField(
                      onChanged: provider.setSearchQuery,
                      decoration: InputDecoration(
                        hintText: 'Search products or shops',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (onGuestExit != null)
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton.tonalIcon(
                          onPressed: onGuestExit,
                          icon: const Icon(Icons.exit_to_app),
                          label: const Text('Exit guest'),
                        ),
                      ),
                  ],
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
                      childAspectRatio: 0.72,
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: product.imageUrl.isEmpty
                        ? Container(
                            color: const Color(0xFFE2E8F0),
                            child: Center(
                              child: Text(
                                (product.name.isNotEmpty ? product.name[0] : '?').toUpperCase(),
                                style: const TextStyle(fontSize: 48, color: Colors.white, fontWeight: FontWeight.w800),
                              ),
                            ),
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
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.shopName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange)),
                      const SizedBox(height: 6),
                      Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text('\$${product.price.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w900)),
                          const Spacer(),
                          if (isBuyer)
                            FilledButton(onPressed: onAddToCart, child: const Text('Add'))
                          else
                            FilledButton(onPressed: () {
                              final provider = context.read<CommerceProvider>();
                              provider.showAuth();
                              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AuthScreen()));
                            }, child: const Text('Sign in')),
                        ],
                      )
                    ],
                  ),
                ),
              ],
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