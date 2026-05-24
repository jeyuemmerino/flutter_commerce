import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/commerce_models.dart';
import '../providers/commerce_provider.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key, required this.forSeller, required this.onOpenInvoice});

  final bool forSeller;
  final void Function(Order order) onOpenInvoice;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommerceProvider>();
    final orders = forSeller ? provider.shopOrders : provider.buyerOrders;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(forSeller ? 'Shop orders' : 'My orders', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          if (orders.isEmpty)
            const Padding(padding: EdgeInsets.symmetric(vertical: 40), child: Center(child: Text('No orders yet.')))
          else
            ...orders.map((order) => _OrderCard(order: order, forSeller: forSeller, onOpenInvoice: () => onOpenInvoice(order))),
        ],
      ),
    );
  }
}

class _OrderCard extends StatefulWidget {
  const _OrderCard({required this.order, required this.forSeller, required this.onOpenInvoice});

  final Order order;
  final bool forSeller;
  final VoidCallback onOpenInvoice;

  @override
  State<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<_OrderCard> {
  static const List<String> _supportedStatuses = ['pending', 'shipped', 'delivered'];

  String? _status;

  @override
  void initState() {
    super.initState();
    _status = _normalizeStatus(widget.order.status);
  }

  @override
  void didUpdateWidget(covariant _OrderCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.order.status != widget.order.status) {
      _status = _normalizeStatus(widget.order.status);
    }
  }

  String _normalizeStatus(String status) {
    return _supportedStatuses.contains(status) ? status : _supportedStatuses.first;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<CommerceProvider>();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text('${widget.order.shopName} #${widget.order.id}', style: const TextStyle(fontWeight: FontWeight.w800))),
                Text(widget.order.status),
              ],
            ),
            const SizedBox(height: 8),
            Text('Buyer: ${widget.order.buyerName}'),
            Text('Total: \$${widget.order.total.toStringAsFixed(2)}'),
            Text('Address: ${widget.order.shippingAddress}'),
            const SizedBox(height: 12),
            if (widget.forSeller)
              DropdownButtonFormField<String>(
                initialValue: _status,
                items: const [
                  DropdownMenuItem(value: 'pending', child: Text('Pending')),
                  DropdownMenuItem(value: 'shipped', child: Text('Shipped')),
                  DropdownMenuItem(value: 'delivered', child: Text('Delivered')),
                ],
                onChanged: (value) => setState(() => _status = value),
                decoration: const InputDecoration(labelText: 'Update status'),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (widget.forSeller)
                  FilledButton(
                    onPressed: _status == null || _status == widget.order.status
                        ? null
                        : () async {
                            try {
                              await provider.setOrderStatus(widget.order.id, _status!);
                            } catch (_) {
                              if (!context.mounted) {
                                return;
                              }

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Failed to update order status')),
                              );
                              setState(() => _status = _normalizeStatus(widget.order.status));
                            }
                          },
                    child: const Text('Save status'),
                  ),
                const Spacer(),
                OutlinedButton(
                  onPressed: widget.onOpenInvoice,
                  child: const Text('Invoice'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}