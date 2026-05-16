import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/auth/presentation/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://fobhrwazvwqshiiydpjl.supabase.co',
    anonKey: 'sb_publishable_M_bXu7mNfnRy-Dz2AG282g_t5EO2MFa',
  );

  runApp(const SocietyApp());
}

class SocietyApp extends StatelessWidget {
  const SocietyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Society Member App',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: const AuthGate(),
    );
  }
}



