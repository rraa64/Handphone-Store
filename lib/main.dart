import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'pages/login_page.dart';
import 'pages/product_list_page.dart';

const String supabaseUrl = 'https://uxkqptzhabpiqaipxxhn.supabase.co';
const String supabaseAnonKey = 'sb_publishable_TFQnVlBqC0EoGdHR8uVVlQ_F49Z-1Cg';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aplikasi Penjualan HP',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
        fontFamily: 'Roboto',
      ),
      home: session == null ? const LoginPage() : const ProductListPage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/products': (context) => const ProductListPage(),
      },
    );
  }
}
