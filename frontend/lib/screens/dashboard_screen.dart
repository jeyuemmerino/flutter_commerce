import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/marketplace_provider.dart';
import '../widgets/section_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MarketplaceProvider>();
    final analytics = provider.analytics;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: provider.bootstrap,
        child: ListView(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Text(
              'Seller Dashboard',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 16),
            if (analytics == null)
              const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
            else ...[
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _MetricCard(label: 'Revenue', value: _money(analytics.totalRevenue)),
                  _MetricCard(label: 'Orders', value: '${analytics.totalOrders}'),
                  _MetricCard(label: 'Best category', value: analytics.bestSellingCategory),
                ],
              ),
              const SizedBox(height: 18),
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Top products', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 12),
                    ...analytics.topProducts.map(
                      (item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Expanded(child: Text(item['name'].toString(), style: const TextStyle(fontWeight: FontWeight.w600))),
                            Text('${item['quantity']} sold'),
                          ],
                        ),
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
                    Text('Category performance', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 12),
                    ...analytics.categoryPerformance.map(
                      (item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Expanded(child: Text(item['category'].toString())),
                            Text(_money(double.tryParse(item['revenue'].toString()) ?? 0)),
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