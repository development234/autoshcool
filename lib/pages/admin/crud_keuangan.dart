import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../services/supabase_service.dart';

class CrudKeuanganPage extends StatefulWidget {
  const CrudKeuanganPage({super.key});

  @override
  State<CrudKeuanganPage> createState() => _CrudKeuanganPageState();
}

class _CrudKeuanganPageState extends State<CrudKeuanganPage> {
  final SupabaseService _service = SupabaseService();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Keuangan', style:TextStyle(fontSize:14),),
        backgroundColor: const Color.fromARGB(255, 1, 155, 129),
        foregroundColor: Colors.white,

      ),
      body: Column(
       
    ),
    );
  }

}