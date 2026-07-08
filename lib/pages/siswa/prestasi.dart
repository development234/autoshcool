// TODO Implement this library.
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../services/supabase_service.dart';

class PrestasiPage extends StatefulWidget {
  const PrestasiPage({super.key});

  @override
  State<PrestasiPage> createState() => _PrestasiPageState();
}

class _PrestasiPageState extends State<PrestasiPage> {
  final SupabaseService _service = SupabaseService();


  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prestasi',
          style: TextStyle(
            fontSize: 14,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 1, 155, 129),
        foregroundColor: Colors.white,
        elevation: 4,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromARGB(255, 27, 94, 94),
                Color.fromARGB(255, 11, 121, 136),
                Color.fromARGB(255, 76, 163, 175),
              ],
            ),
          ),
        ),
      ),
      body: const Center(
        child: Text('Halaman Prestasi'),
      ),
    );
  }
}
