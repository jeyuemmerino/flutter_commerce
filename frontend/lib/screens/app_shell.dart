import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/marketplace_provider.dart';
import 'ai_screen.dart';
import 'cart_screen.dart';
import 'checkout_screen.dart';
import 'dashboard_screen.dart';
import 'home_screen.dart';
import 'search_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  void _setIndex(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MarketplaceProvider>();

    final pages = [
      HomeScreen(onSelectCheckout: () => _setIndex(3)),
      const SearchScreen(),
      CartScreen(onCheckout: () => _setIndex(3)),
      const CheckoutScreen(),
      const DashboardScreen(),
      const AiScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _setIndex,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.search_outlined), selectedIcon: Icon(Icons.search), label: 'Search'),
          NavigationDestination(icon: Icon(Icons.shopping_cart_outlined), selectedIcon: Icon(Icons.shopping_cart), label: 'Cart'),
          NavigationDestination(icon: Icon(Icons.payments_outlined), selectedIcon: Icon(Icons.payments), label: 'Checkout'),
          NavigationDestination(icon: Icon(Icons.insights_outlined), selectedIcon: Icon(Icons.insights), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.auto_awesome_outlined), selectedIcon: Icon(Icons.auto_awesome), label: 'AI'),
        ],
      ),
      floatingActionButton: provider.cartItems.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _setIndex(2),
              icon: const Icon(Icons.shopping_bag),
              label: Text('${provider.cartItems.length} in cart'),
            ),
    );
  }
}