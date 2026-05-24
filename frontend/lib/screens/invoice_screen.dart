import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/commerce_models.dart';
import '../providers/commerce_provider.dart';
import '../utils/app_config.dart';

class InvoiceScreen extends StatelessWidget {
  const InvoiceScreen({super.key, required this.orderId});

  final int orderId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Invoice>(
      future: context.read<CommerceProvider>().fetchInvoice(orderId),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text(snapshot.error.toString())));
        }

        final invoice = snapshot.data!;

        return Scaffold(
          appBar: AppBar(title: Text('Invoice ${invoice.invoiceNumber}')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Buyer: ${invoice.buyer.name}', style: const TextStyle(fontWeight: FontWeight.w800)),
              Text('Shop: ${invoice.shop.name}'),
              Text('Status: ${invoice.order.status}'),
              Text('Address: ${invoice.order.shippingAddress}'),
              const SizedBox(height: 16),
              ...invoice.order.items.map(
                (item) => ListTile(
                  leading: item.imageUrl.isEmpty ? const Icon(Icons.receipt_long) : Image.network(_resolveImageUrl(item.imageUrl), width: 48, height: 48, fit: BoxFit.cover),
                  title: Text(item.productName),
                  subtitle: Text('Qty ${item.quantity}'),
                  trailing: Text('\$${(item.quantity * item.price).toStringAsFixed(2)}'),
                ),
              ),
              const Divider(),
              Text('Total: \$${invoice.order.total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            ],
          ),
        );
      },
    );
  }

  String _resolveImageUrl(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return imageUrl;
    }
    return '$apiBaseUrl$imageUrl';
  }
}