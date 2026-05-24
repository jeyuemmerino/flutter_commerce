import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/commerce_provider.dart';

class ShopFormScreen extends StatefulWidget {
  const ShopFormScreen({super.key});

  @override
  State<ShopFormScreen> createState() => _ShopFormScreenState();
}

class _ShopFormScreenState extends State<ShopFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommerceProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Create shop')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Shop name'), validator: _required),
            const SizedBox(height: 12),
            TextFormField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3, validator: _required),
            const SizedBox(height: 12),
            if (provider.error != null) Text(provider.error!, style: const TextStyle(color: Colors.red)),
            FilledButton(
              onPressed: provider.busy ? null : _save,
              child: const Text('Create shop'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = context.read<CommerceProvider>();
    await provider.createShop(name: _nameController.text, description: _descriptionController.text);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  String? _required(String? value) => value == null || value.trim().isEmpty ? 'Required' : null;
}