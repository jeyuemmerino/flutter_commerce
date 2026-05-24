import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/marketplace_models.dart';
import '../providers/marketplace_provider.dart';
import '../widgets/section_card.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.product});

  final Product product;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MarketplaceProvider>().setActiveProduct(widget.product);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MarketplaceProvider>();
    final recommendations = provider.recommendations;

    return Scaffold(
      appBar: AppBar(title: Text(widget.product.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: const Color(0xFF1F2937),
                  ),
                  child: Center(
                    child: Text(
                      widget.product.category.isEmpty ? '?' : widget.product.category.substring(0, 1).toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 52),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(widget.product.category, style: const TextStyle(color: Color(0xFFB45309), fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(widget.product.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                Text(widget.product.description),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(_money(widget.product.price), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                    const Spacer(),
                    Text('Stock: ${widget.product.stock}'),
                  ],
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: () => provider.addToCart(widget.product),
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('Add to cart'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (recommendations != null) ...[
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Frequently bought together', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),
                  if (recommendations.frequentlyBoughtTogether.isEmpty)
                    const Text('No co-purchase data yet.')
                  else
                    ...recommendations.frequentlyBoughtTogether.map(
                      (product) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text('${product.name} - ${_money(product.price)}'),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Simulated AI description', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                Text(
                  provider.generatedDescription ??
                      'Use the AI tab to generate a marketing-style description for ${widget.product.name}.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _money(double value) => '\$${value.toStringAsFixed(2)}';