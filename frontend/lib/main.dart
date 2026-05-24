import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/marketplace_provider.dart';
import 'screens/app_shell.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const MarketplaceApp());
}

class MarketplaceApp extends StatelessWidget {
  const MarketplaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MarketplaceProvider()..bootstrap(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Local Marketplace Demo',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFDD6B20),
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: const Color(0xFFF6F1EB),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFF6F1EB),
            foregroundColor: Color(0xFF1F2937),
          ),
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        home: Consumer<MarketplaceProvider>(
          builder: (context, provider, _) {
            if (provider.isBootstrapping) {
              return const SplashScreen();
            }

            if (provider.bootstrapError != null && provider.products.isEmpty) {
              return Scaffold(
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.cloud_off, size: 56),
                        const SizedBox(height: 12),
                        Text(
                          'Could not load the local marketplace.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          provider.bootstrapError!,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: provider.bootstrap,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return const AppShell();
          },
        ),
      ),
    );
  }
}


