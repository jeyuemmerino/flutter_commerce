import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/commerce_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/app_shell.dart';
import 'screens/auth_screen.dart';
import 'screens/start_screen.dart';

void main() {
  runApp(const CommerceApp());
}

class CommerceApp extends StatelessWidget {
  const CommerceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CommerceProvider()..bootstrap(),
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Local Commerce Demo',
            theme: themeProvider.themeData,
            home: Consumer<CommerceProvider>(
              builder: (context, provider, _) {
                if (provider.isLaunch) {
                  return StartScreen(onGuest: provider.goGuest, onAuth: provider.showAuth);
                }

                if (provider.isAuth) {
                  return const AuthScreen();
                }

                return const AppShell();
              },
            ),
          );
        },
      ),
    );
  }
}


