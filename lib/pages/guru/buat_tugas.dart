// lib/pages/guru/buat_tugas.dart
import 'package:flutter/material.dart';

class BuatTugasPage extends StatelessWidget {
  const BuatTugasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Tugas',
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
        child: Text('Halaman Buat Tugas'),
      ),
    );
  }
}