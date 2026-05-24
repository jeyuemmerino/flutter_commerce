import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/commerce_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommerceProvider>();
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
          FilledButton.tonalIcon(
            onPressed: provider.logout,
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}