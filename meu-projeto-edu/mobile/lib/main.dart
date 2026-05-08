import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ui/home_page.dart';
import 'ui/login_page.dart';
import 'ui/register_page.dart';

void main() {
  runApp(const ProviderScope(child: MeuProjetoEduApp()));
}

class MeuProjetoEduApp extends StatelessWidget {
  const MeuProjetoEduApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meu Projeto Edu',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
