import 'package:autoschool/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../services/supabase_service.dart';

class WaliSiswaPage extends StatefulWidget {
  const WaliSiswaPage({super.key});

  @override
  State<WaliSiswaPage> createState() => _WaliSiswaPageState();
}

class _WaliSiswaPageState extends State<WaliSiswaPage> {
  final SupabaseService _service = SupabaseService();


  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Wali Siswa', style: TextStyle(fontSize: 14),),
        backgroundColor: const Color.fromARGB(255, 1, 155, 129),
        foregroundColor: Colors.white,
       
      ),
      body: Column(
    ),
    );
  }

}