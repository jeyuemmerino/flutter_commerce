import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/commerce_provider.dart';
import '../widgets/section_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommerceProvider>();
    final dashboard = provider.shopDashboard;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: provider.reloadCurrentView,
        child: ListView(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Text(
              'Seller Dashboard',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 16),
            if (provider.busy)
              const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
            else if (dashboard == null)
              const Center(
                child: Text(
                  'No shop yet. Create one first!',
                  style: TextStyle(fontSize: 16),
                ),
              )
            else ...[
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _MetricCard(label: 'Revenue', value: _money(dashboard.stats.totalRevenue)),
                  _MetricCard(label: 'Orders', value: '${dashboard.stats.totalOrders}'),
                  _MetricCard(label: 'Pending', value: '${dashboard.stats.pending}'),
                  _MetricCard(label: 'Shipped', value: '${dashboard.stats.shipped}'),
                  _MetricCard(label: 'Delivered', value: '${dashboard.stats.delivered}'),
                ],
              ),
              const SizedBox(height: 18),
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Shop Info', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Expanded(child: Text('Shop Name', style: const TextStyle(fontWeight: FontWeight.w600))),
                          Text(dashboard.shop.name),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Expanded(child: Text('Products', style: const TextStyle(fontWeight: FontWeight.w600))),
                          Text('${dashboard.products.length}'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Recent Orders', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 12),
                    if (dashboard.orders.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text('No orders yet'),
                      )
                    else
                      ...dashboard.orders.map(
                        (order) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Order #${order.id}', style: const TextStyle(fontWeight: FontWeight.w600)),
                                    Text(order.status, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                  ],
                                ),
                              ),
                              Text(_money(order.total)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 3.4,
      child: SectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Color(0xFF6B7280))),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}

String _money(double value) => '\$${value.toStringAsFixed(2)}';