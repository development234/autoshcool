// lib/pages/guru/input_nilai.dart
import 'package:flutter/material.dart';

class InputNilaiPage extends StatelessWidget {
  const InputNilaiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Nilai',
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
        child: Text('Halaman Input Nilai'),
      ),
    );
  }
}