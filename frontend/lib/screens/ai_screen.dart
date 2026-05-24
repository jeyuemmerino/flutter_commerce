import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/marketplace_models.dart';
import '../providers/marketplace_provider.dart';
import '../widgets/section_card.dart';

class AiScreen extends StatefulWidget {
  const AiScreen({super.key});

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MarketplaceProvider>();
    final recommendations = provider.recommendations;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'AI Features',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 16),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Description generator', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Product name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _categoryController,
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: provider.isBusy
                      ? null
                      : () async {
                          await provider.generateProductDescription(
                            _nameController.text.trim().isEmpty ? 'Demo product' : _nameController.text.trim(),
                            _categoryController.text.trim().isEmpty ? 'General' : _categoryController.text.trim(),
                          );
                        },
                  child: const Text('Generate description'),
                ),
                if (provider.generatedDescription != null) ...[
                  const SizedBox(height: 12),
                  Text(provider.generatedDescription!),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sales insights', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                if (provider.salesInsight == null)
                  const Text('No insights available yet.')
                else
                  ...provider.salesInsight!.insights.map(
                    (insight) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('- '),
                          Expanded(child: Text(insight)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (recommendations != null) ...[
            _RecommendationSection(title: 'Trending products', products: recommendations.trending),
            const SizedBox(height: 12),
            _RecommendationSection(title: 'Similar category', products: recommendations.similarCategory),
            const SizedBox(height: 12),
            _RecommendationSection(title: 'Frequently bought together', products: recommendations.frequentlyBoughtTogether),
          ],
        ],
      ),
    );
  }
}

class _RecommendationSection extends StatelessWidget {
  const _RecommendationSection({required this.title, required this.products});

  final String title;
  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          if (products.isEmpty)
            const Text('No products yet.')
          else
            ...products.map(
              (product) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text('${product.name} - ${_money(product.price)}'),
              ),
            ),
        ],
      ),
    );
  }
}

String _money(double value) => '\$${value.toStringAsFixed(2)}';