// lib/pages/guru/absensi.dart
import 'package:flutter/material.dart';

class GuruAbsensiPage extends StatelessWidget {
  const GuruAbsensiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Absensi Guru',
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
        child: Text('Halaman Absensi Guru'),
      ),
    );
  }
}