import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
import '../utils/themes.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key, required this.onGuest, required this.onAuth});

  final VoidCallback onGuest;
  final VoidCallback onAuth;

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF334155), Color(0xFFF8FAFC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Main content centered
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Marketplace', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
                            const SizedBox(height: 8),
                            const Text('Browse as a guest, register as buyer or seller, and manage shops, carts, orders, and invoices locally.'),
                            const SizedBox(height: 24),
                            FilledButton.icon(
                              onPressed: onGuest,
                              icon: const Icon(Icons.visibility),
                              label: const Text('Visit as guest'),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: onAuth,
                              icon: const Icon(Icons.login),
                              label: const Text('Sign in / register'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Theme dropdown in top right
              Positioned(
                top: 8,
                right: 8,
                child: PopupMenuButton<String>(
                  onSelected: (themeName) {
                    themeProvider.setTheme(themeName);
                  },
                  itemBuilder: (BuildContext context) {
                    return AppThemes.allThemes.keys.map((themeName) {
                      final themeNames = AppThemes.themeNames;
                      final isSelected = themeProvider.isTheme(themeName);
                      return PopupMenuItem<String>(
                        value: themeName,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isSelected) const Icon(Icons.check, size: 18),
                            if (isSelected) const SizedBox(width: 8),
                            Text(themeNames[themeName] ?? themeName),
                          ],
                        ),
                      );
                    }).toList();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.palette, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          AppThemes.themeNames[themeProvider.currentTheme] ?? 'Theme',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}