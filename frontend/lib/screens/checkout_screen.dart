import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/marketplace_provider.dart';
import '../widgets/section_card.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _couponController = TextEditingController();
  String _statusMessage = '';

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  Future<void> _checkout(MarketplaceProvider provider) async {
    if (provider.cartItems.isEmpty) {
      setState(() => _statusMessage = 'Add items to the cart before checking out.');
      return;
    }

    try {
      final order = await provider.checkout(couponCode: _couponController.text.trim());
      if (!mounted) {
        return;
      }

      setState(() {
        _statusMessage = 'Order #${order.id} completed successfully. Mock payment approved.';
        _couponController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_statusMessage)),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() => _statusMessage = error.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_statusMessage)),
      );
    }
  }

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
              'Checkout',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 16),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _couponController,
                    decoration: const InputDecoration(
                      labelText: 'Coupon code',
                      prefixIcon: Icon(Icons.local_offer_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Items: ${provider.cartItems.length}'),
                  Text('Subtotal: ${_money(provider.cartSubtotal)}'),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: provider.isBusy ? null : () => _checkout(provider),
                    icon: const Icon(Icons.verified),
                    label: Text(provider.isBusy ? 'Processing...' : 'Mock pay now'),
                  ),
                  if (_statusMessage.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(_statusMessage, style: const TextStyle(color: Color(0xFF6B7280))),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('Recent orders', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Expanded(
              child: provider.orders.isEmpty
                  ? const Center(child: Text('No completed orders yet.'))
                  : ListView.separated(
                      itemCount: provider.orders.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final order = provider.orders[index];
                        return SectionCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Order #${order.id}', style: const TextStyle(fontWeight: FontWeight.w800)),
                              const SizedBox(height: 6),
                              Text('${order.items.length} item(s) - ${order.status}'),
                              Text('Total: ${_money(order.totalPrice)}'),
                              Text('Placed: ${order.createdAt.toLocal()}'),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _money(double value) => '\$${value.toStringAsFixed(2)}';
}