import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/commerce_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/themes.dart';
import 'auth_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _isEditing = false;
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<CommerceProvider>().currentUser;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
          
          if (user == null) ...[
            // Guest view
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('You are viewing as a guest', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    const Text('Sign in to access orders, cart, and profile features.'),
                    const SizedBox(height: 16),
                    FilledButton(onPressed: () {
                      provider.showAuth();
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AuthScreen()));
                    }, child: const Text('Sign in')),
                  ],
                ),
              ),
            ),
          ] else ...[
            // User information
            Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(user.name),
                subtitle: Text('${user.role} • ${user.email}'),
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
            
            // Edit Profile Section
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Profile Settings', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  TextButton.icon(
                    onPressed: () => setState(() => _isEditing = !_isEditing),
                    icon: Icon(_isEditing ? Icons.close : Icons.edit),
                    label: Text(_isEditing ? 'Cancel' : 'Edit'),
                  ),
                ],
              ),
            ),
            
            if (_isEditing) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Name'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _passwordController,
                        obscureText: !_showPassword,
                        decoration: InputDecoration(
                          labelText: 'New Password (optional)',
                          suffixIcon: IconButton(
                            icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => setState(() => _showPassword = !_showPassword),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (provider.error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(provider.error!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                        ),
                      FilledButton(
                        onPressed: provider.busy ? null : () {
                          // ignore: unawaited_futures
                          provider.updateProfile(
                            name: _nameController.text,
                            email: _emailController.text,
                            password: _passwordController.text.isEmpty ? null : _passwordController.text,
                          ).then((_) {
                            if (mounted && !provider.busy && provider.error == null) {
                              setState(() => _isEditing = false);
                              _passwordController.clear();
                              // ignore: use_build_context_synchronously
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Profile updated successfully')),
                              );
                            }
                          });
                        },
                        child: provider.busy ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Save Changes'),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Name:', style: TextStyle(fontWeight: FontWeight.w500)),
                          Text(user.name),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Email:', style: TextStyle(fontWeight: FontWeight.w500)),
                          Text(user.email),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
          ],
          
          // Theme Settings
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
          
          if (user != null)
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