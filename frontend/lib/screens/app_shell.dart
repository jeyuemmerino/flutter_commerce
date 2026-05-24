import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/commerce_models.dart';
import '../providers/commerce_provider.dart';
import 'browse_screen.dart';
import 'cart_screen.dart';
import 'invoice_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';
import 'product_detail_screen.dart';
import 'product_form_screen.dart';
import 'shop_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommerceProvider>();

    if (provider.isGuest) {
      // Guest view with navigation bar
      final guestPages = [
        BrowseScreen(
          onProductTap: (product) => _openProduct(context, product),
          onGuestExit: () {
            provider.showLaunch();
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
        const BuyerCartScreen(),
        const ProfileScreen(),
      ];

      const guestDestinations = [
        NavigationDestination(icon: Icon(Icons.storefront_outlined), selectedIcon: Icon(Icons.storefront), label: 'Shop'),
        NavigationDestination(icon: Icon(Icons.shopping_cart_outlined), selectedIcon: Icon(Icons.shopping_cart), label: 'Cart'),
        NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
      ];

      return Scaffold(
        body: IndexedStack(index: _index.clamp(0, guestPages.length - 1), children: guestPages),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index.clamp(0, guestDestinations.length - 1),
          onDestinationSelected: (value) => setState(() => _index = value),
          destinations: guestDestinations,
        ),
      );
    }

    // Ensure we're in a valid state; if not, show loading
    if (!provider.isSeller && !provider.isBuyer) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final isSeller = provider.isSeller;
    final pages = isSeller
        ? [
            ShopScreen(
              onAddProduct: () => _openProductForm(context),
              onEditProduct: (product) => _openProductForm(context, product: product),
              onProductTap: (product) => _openProduct(context, product),
            ),
            OrdersScreen(forSeller: true, onOpenInvoice: (order) => _openInvoice(context, order.id)),
            const ProfileScreen(),
          ]
        : [
            BrowseScreen(onProductTap: (product) => _openProduct(context, product)),
            const BuyerCartScreen(),
            OrdersScreen(forSeller: false, onOpenInvoice: (order) => _openInvoice(context, order.id)),
            const ProfileScreen(),
          ];

    final destinations = isSeller
        ? const [
            NavigationDestination(icon: Icon(Icons.storefront_outlined), selectedIcon: Icon(Icons.storefront), label: 'Shop'),
            NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Orders'),
            NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
          ]
        : const [
            NavigationDestination(icon: Icon(Icons.storefront_outlined), selectedIcon: Icon(Icons.storefront), label: 'Browse'),
            NavigationDestination(icon: Icon(Icons.shopping_cart_outlined), selectedIcon: Icon(Icons.shopping_cart), label: 'Cart'),
            NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Orders'),
            NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
          ];

    // Defensive check: ensure we have valid destinations (should always be true)
    if (destinations.length < 2 || pages.length != destinations.length) {
      return const Scaffold(
        body: Center(
          child: Text('Navigation configuration error'),
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(index: _index.clamp(0, pages.length - 1), children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index.clamp(0, destinations.length - 1),
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: destinations,
      ),
    );
  }

  void _openProduct(BuildContext context, Product product) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)));
  }

  void _openProductForm(BuildContext context, {Product? product}) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProductFormScreen(product: product)));
  }

  void _openInvoice(BuildContext context, int orderId) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => InvoiceScreen(orderId: orderId)));
  }
}