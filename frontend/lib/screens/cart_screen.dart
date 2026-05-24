import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/marketplace_provider.dart';
import '../widgets/section_card.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key, required this.onCheckout});

  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MarketplaceProvider>();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cart',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: provider.cartItems.isEmpty
                  ? const Center(child: Text('Your cart is empty. Add a few products to get started.'))
                  : ListView.separated(
                      itemCount: provider.cartItems.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = provider.cartItems[index];
                        return SectionCard(
                          child: Row(
                            children: [
                              Container(
                                width: 54,
                                height: 54,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1F2937),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Center(
                                  child: Text(
                                    item.product.category.isEmpty ? '?' : item.product.category.substring(0, 1).toUpperCase(),
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                                    const SizedBox(height: 4),
                                    Text(_money(item.product.price)),
                                    const SizedBox(height: 4),
                                    Text('Line total: ${_money(item.lineTotal)}', style: const TextStyle(color: Color(0xFF6B7280))),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  IconButton(
                                    onPressed: () => provider.increaseQuantity(item.product),
                                    icon: const Icon(Icons.add_circle_outline),
                                  ),
                                  Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  IconButton(
                                    onPressed: () => provider.decreaseQuantity(item.product),
                                    icon: const Icon(Icons.remove_circle_outline),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 12),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Subtotal', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(_money(provider.cartSubtotal), style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: provider.cartItems.isEmpty ? null : onCheckout,
                    icon: const Icon(Icons.payments),
                    label: const Text('Proceed to checkout'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _money(double value) => '\$${value.toStringAsFixed(2)}';
}