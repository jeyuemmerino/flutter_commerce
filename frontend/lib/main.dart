import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/commerce_provider.dart';
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
    return ChangeNotifierProvider(
      create: (_) => CommerceProvider()..bootstrap(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Local Commerce Demo',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0EA5A4), brightness: Brightness.light),
          scaffoldBackgroundColor: const Color(0xFFF8FAFC),
          appBarTheme: const AppBarTheme(backgroundColor: Color(0xFFF8FAFC), foregroundColor: Color(0xFF0F172A)),
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
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
      ),
    );
  }
}


