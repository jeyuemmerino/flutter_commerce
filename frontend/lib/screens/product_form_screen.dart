import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/commerce_models.dart';
import '../providers/commerce_provider.dart';
import '../services/commerce_api_service.dart';

class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key, this.product});

  final Product? product;

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _categoryController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  Uint8List? _pickedBytes;
  String? _pickedName;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _nameController = TextEditingController(text: product?.name ?? '');
    _descriptionController = TextEditingController(text: product?.description ?? '');
    _categoryController = TextEditingController(text: product?.category ?? 'General');
    _priceController = TextEditingController(text: product?.price.toStringAsFixed(2) ?? '0');
    _stockController = TextEditingController(text: product?.stock.toString() ?? '0');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommerceProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(widget.product == null ? 'Add product' : 'Edit product')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name'), validator: _required),
            const SizedBox(height: 12),
            TextFormField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Description'), maxLines: 4, validator: _required),
            const SizedBox(height: 12),
            // Category dropdown (robust: de-duplicate provider categories and ensure initial value exists)
            Consumer<CommerceProvider>(builder: (context, provider, _) {
              final unique = provider.categories.toSet().toList();
              final initial = unique.contains(_categoryController.text) ? _categoryController.text : null;
              return DropdownButtonFormField<String>(
                initialValue: initial ?? (unique.isNotEmpty ? unique.first : null),
                items: unique.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => _categoryController.text = v ?? 'General',
                decoration: const InputDecoration(labelText: 'Category'),
                validator: _required,
              );
            }),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: TextFormField(controller: _priceController, decoration: const InputDecoration(labelText: 'Price'), keyboardType: TextInputType.number, validator: _required)),
                const SizedBox(width: 12),
                Expanded(child: TextFormField(controller: _stockController, decoration: const InputDecoration(labelText: 'Stock'), keyboardType: TextInputType.number, validator: _required)),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: Text(_pickedName == null ? 'Pick product image' : 'Image: $_pickedName'),
            ),
            const SizedBox(height: 12),
            if (provider.error != null) Text(provider.error!, style: const TextStyle(color: Colors.red)),
            FilledButton(
              onPressed: provider.busy || _saving ? null : _save,
              child: Text(widget.product == null ? 'Create product' : 'Save product'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    if (result == null || result.files.isEmpty) {
      return;
    }

    setState(() {
      _pickedBytes = result.files.single.bytes;
      _pickedName = result.files.single.name;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = context.read<CommerceProvider>();
    setState(() => _saving = true);
    try {
      await provider.addOrUpdateProduct(
        productId: widget.product?.id,
        name: _nameController.text,
        description: _descriptionController.text,
        category: _categoryController.text,
        price: double.tryParse(_priceController.text) ?? 0,
        stock: int.tryParse(_stockController.text) ?? 0,
        pickedImage: _pickedBytes == null ? null : PickedFileData(bytes: _pickedBytes, name: _pickedName),
      );
      if (mounted) {
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  String? _required(String? value) => value == null || value.trim().isEmpty ? 'Required' : null;
}