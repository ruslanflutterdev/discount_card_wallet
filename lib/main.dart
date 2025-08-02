import 'package:discount_card_wallet/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://zigycvqdtdozvopaswbd.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InppZ3ljdnFkdGRvenZvcGFzd2JkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM4OTc2MDcsImV4cCI6MjA2OTQ3MzYwN30.IgKrXFJckAGrz24eEq-NqkCIxvXRok6igvYbu3alSXI',
  );
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Кошелек дисконтных карт', home: HomeScreen());
  }
}
