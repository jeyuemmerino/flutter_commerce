import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/commerce_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/themes.dart';
import 'auth_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommerceProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final user = provider.currentUser;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Profile', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(user?.name ?? 'Guest'),
              subtitle: Text(user == null ? 'Browsing locally' : '${user.role} • ${user.email}'),
            ),
          ),
          const SizedBox(height: 12),
          if (provider.currentShop != null)
            Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.storefront)),
                title: Text(provider.currentShop!.name),
                subtitle: Text(provider.currentShop!.description),
              ),
            ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text('Theme Settings', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: DropdownButton<String>(
                isExpanded: true,
                value: themeProvider.currentTheme,
                onChanged: (themeName) {
                  if (themeName != null) {
                    themeProvider.setTheme(themeName);
                  }
                },
                items: AppThemes.allThemes.keys.map((themeName) {
                  final themeNames = AppThemes.themeNames;
                  return DropdownMenuItem<String>(
                    value: themeName,
                    child: Row(
                      children: [
                        const Icon(Icons.palette, size: 18),
                        const SizedBox(width: 8),
                        Text(themeNames[themeName] ?? themeName),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (user == null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('You are viewing as a guest. Sign in to access orders, cart and profile features.'),
                    const SizedBox(height: 12),
                    FilledButton(onPressed: () {
                      // Push auth screen so guest can sign in/register
                      provider.showAuth();
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AuthScreen()));
                    }, child: const Text('Sign in')),
                  ],
                ),
              ),
            ),
          ] else ...[
            FilledButton.tonalIcon(
              onPressed: provider.logout,
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
            ),
          ],
        ],
      ),
    );
  }
}