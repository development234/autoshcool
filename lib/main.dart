// lib/main.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth/login.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🚀 ============ STARTING AUTOSCHOOL ============');
  print('📍 URL: ${Constants.supabaseUrl}');
  print('🔑 Key: ${Constants.supabaseAnonKey.substring(0, 30)}...');
  
  try {
    await Supabase.initialize(
      url: Constants.supabaseUrl,
      // ignore: deprecated_member_use
      anonKey: Constants.supabaseAnonKey,
    );
    print('✅ Supabase initialized successfully!');
    
    // Test connection
    final client = Supabase.instance.client;
    final response = await client.from('users').select().limit(1);
    print('✅ Database connected!');
    print('📊 Response: $response');
    
  } catch (e) {
    print('❌ Error: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AutoSchool',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}