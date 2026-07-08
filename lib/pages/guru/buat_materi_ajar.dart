// lib/pages/guru/buat_materi_ajar.dart
import 'package:flutter/material.dart';

class BuatMateriAjarPage extends StatelessWidget {
  const BuatMateriAjarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Materi Ajar',
        style: TextStyle(
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 1, 155, 129),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Halaman Buat Materi Ajar'),
      ),
    );
  }
}