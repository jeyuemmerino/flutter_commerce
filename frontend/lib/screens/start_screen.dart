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
          child: Column(
            children: [
              // Theme selector at top
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: AppThemes.allThemes.keys.map((themeName) {
                      final themeNames = AppThemes.themeNames;
                      final isSelected = themeProvider.isTheme(themeName);
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          selected: isSelected,
                          onSelected: (selected) {
                            themeProvider.setTheme(themeName);
                          },
                          label: Text(themeNames[themeName] ?? themeName),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              // Main content
              Expanded(
                child: Center(
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
                              Text('Marketplace Demo', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}