// test_http.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🔐 Testing HTTP login...');
  
  final url = Uri.parse('https://wxignavgqqgwncvbwvvj.supabase.co/auth/v1/token?grant_type=password');
  
  final response = await http.post(
    url,
    headers: {
      'apikey': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind4aWduYXZncXFnd25jdmJ3dnZqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODMyNDc1NDUsImV4cCI6MjA5ODgyMzU0NX0.qIq_5Y83Fe6g0Qj1B1_NFnCz5A5de7hTpaGhwb2DdQM',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'email': 'siswa@tester.com',
      'password': 'siswa123',
    }),
  );
  
  print('Status: ${response.statusCode}');
  print('Body: ${response.body}');
}