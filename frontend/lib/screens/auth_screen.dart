import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/commerce_provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  String _role = 'buyer';

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

    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Sign in' : 'Register'),
        leading: IconButton(
          onPressed: () {
            // switch to guest mode and clear navigation stack to avoid returning to a product detail
            provider.goGuest();
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ToggleButtons(
                      isSelected: [_isLogin, !_isLogin],
                      onPressed: (index) => setState(() => _isLogin = index == 0),
                      children: const [Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Login')), Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Register'))],
                    ),
                    const SizedBox(height: 20),
                    if (!_isLogin) ...[
                      TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name')),
                      const SizedBox(height: 12),
                    ],
                    TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
                    const SizedBox(height: 12),
                    TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
                    const SizedBox(height: 12),
                    if (!_isLogin) ...[
                      DropdownButtonFormField<String>(
                        initialValue: _role,
                        items: const [
                          DropdownMenuItem(value: 'buyer', child: Text('Buyer')),
                          DropdownMenuItem(value: 'seller', child: Text('Seller')),
                        ],
                        onChanged: (value) => setState(() => _role = value ?? 'buyer'),
                        decoration: const InputDecoration(labelText: 'Role'),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (provider.error != null) ...[
                      Text(provider.error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 12),
                    ],
                    FilledButton(
                      onPressed: provider.busy
                          ? null
                          : () async {
                              try {
                                if (_isLogin) {
                                  await provider.login(email: _emailController.text, password: _passwordController.text);
                                } else {
                                  await provider.register(
                                    name: _nameController.text,
                                    email: _emailController.text,
                                    password: _passwordController.text,
                                    role: _role,
                                  );
                                }
                              } catch (_) {
                                // provider.error is already set.
                              }
                            },
                      child: Text(provider.busy ? 'Please wait...' : (_isLogin ? 'Login' : 'Create account')),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}