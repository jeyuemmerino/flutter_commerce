import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/commerce_models.dart';
import '../providers/commerce_provider.dart';
import '../utils/app_config.dart';
import 'shop_form_screen.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key, required this.onAddProduct, required this.onEditProduct, required this.onProductTap});

  final VoidCallback onAddProduct;
  final void Function(Product product) onEditProduct;
  final void Function(Product product) onProductTap;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommerceProvider>();
    final shop = provider.currentShop;
    final dashboard = provider.shopDashboard;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Shop', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          if (shop == null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('No shop registered yet.'),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ShopFormScreen())),
                      child: const Text('Create shop'),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.storefront)),
                title: Text(shop.name),
                subtitle: Text(shop.description),
              ),
            ),
            const SizedBox(height: 12),
            if (dashboard != null)
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _StatChip(label: 'Orders', value: '${dashboard.stats.totalOrders}'),
                  _StatChip(label: 'Revenue', value: '\$${dashboard.stats.totalRevenue.toStringAsFixed(2)}'),
                  _StatChip(label: 'Pending', value: '${dashboard.stats.pending}'),
                  _StatChip(label: 'Shipped', value: '${dashboard.stats.shipped}'),
                  _StatChip(label: 'Delivered', value: '${dashboard.stats.delivered}'),
                ],
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                FilledButton.icon(
                  onPressed: onAddProduct,
                  icon: const Icon(Icons.add),
                  label: const Text('Add product'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (dashboard != null)
              ...dashboard.products.map(
                (product) => Card(
                  child: ListTile(
                    onTap: () => onProductTap(product),
                    leading: product.imageUrl.isEmpty
                        ? const CircleAvatar(child: Icon(Icons.inventory_2))
                        : ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(_resolveImageUrl(product.imageUrl), width: 48, height: 48, fit: BoxFit.cover)),
                    title: Text(product.name),
                    subtitle: Text('\$${product.price.toStringAsFixed(2)} • ${product.stock} in stock'),
                    trailing: Wrap(
                      children: [
                        IconButton(
                          onPressed: () => onEditProduct(product),
                          icon: const Icon(Icons.edit),
                        ),
                        IconButton(
                          onPressed: () async {
                            try {
                              await provider.deleteProduct(product.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Product deleted')),
                              );
                            } catch (_) {
                              final message = provider.error ?? 'Failed to delete product';
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(message)),
                              );
                            }
                          },
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
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

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text('$label: $value'));
  }
}