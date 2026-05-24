import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1F2937), Color(0xFFB45309), Color(0xFFF6F1EB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.storefront, color: Colors.white, size: 48),
              ),
              const SizedBox(height: 18),
              const Text(
                'Local Marketplace',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Loading products, analytics, and AI insights...',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 24),
              const SizedBox(
                width: 120,
                child: LinearProgressIndicator(minHeight: 4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}