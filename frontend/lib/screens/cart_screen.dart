import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/commerce_models.dart';
import '../providers/commerce_provider.dart';
import '../utils/app_config.dart';
import 'auth_screen.dart';

class BuyerCartScreen extends StatefulWidget {
  const BuyerCartScreen({super.key});

  @override
  State<BuyerCartScreen> createState() => _BuyerCartScreenState();
}

class _BuyerCartScreenState extends State<BuyerCartScreen> {
  final _addressController = TextEditingController(text: '123 Local Demo Street');

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommerceProvider>();

    // If guest, show message to sign in
    if (provider.isGuest) {
      return SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.shopping_cart, size: 48, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text('Cart is only available for buyers', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    const Text('Sign in as a buyer to add items to your cart and checkout.'),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () {
                        provider.showAuth();
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AuthScreen()));
                      },
                      icon: const Icon(Icons.login),
                      label: const Text('Sign in'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Your cart', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          if (provider.cartItems.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: Text('Your cart is empty.')),
            )
          else
            ...provider.cartItems.map(
              (item) => _CartItemCard(
                item: item,
                onIncrease: () => provider.updateCartItem(item.product, item.quantity + 1),
                onDecrease: () => provider.updateCartItem(item.product, item.quantity - 1),
                onRemove: () => provider.removeFromCart(item.product),
              ),
            ),
          const SizedBox(height: 20),
          TextField(controller: _addressController, decoration: const InputDecoration(labelText: 'Shipping address'), minLines: 2, maxLines: 3),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: Text('Subtotal: \$${provider.cartSubtotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
              const SizedBox(width: 12),
              FilledButton(
                onPressed: provider.busy
                    ? null
                    : () async {
                        await provider.checkout(_addressController.text);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Checkout complete')));
                        }
                      },
                child: const Text('Checkout'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({required this.item, required this.onIncrease, required this.onDecrease, required this.onRemove});

  final CartItem item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final product = item.product;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: product.imageUrl.isEmpty
            ? const CircleAvatar(child: Icon(Icons.shopping_bag))
            : ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(_resolveImageUrl(product.imageUrl), width: 48, height: 48, fit: BoxFit.cover)),
        title: Text(product.name),
        subtitle: Text('Qty ${item.quantity} • \$${product.price.toStringAsFixed(2)}'),
        trailing: Wrap(
          spacing: 4,
          children: [
            IconButton(onPressed: item.quantity > 1 ? onDecrease : onRemove, icon: const Icon(Icons.remove_circle_outline)),
            IconButton(onPressed: onIncrease, icon: const Icon(Icons.add_circle_outline)),
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