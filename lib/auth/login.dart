// lib/auth/login.dart
import 'dart:ui';

import 'package:autoschool/pages/admin/homepage_admin.dart';
import 'package:autoschool/pages/guru/homepage_guru.dart';
import 'package:autoschool/pages/siswa/homepage.dart';
import 'package:autoschool/pages/walimurid/homepage_wali.dart';
import 'package:autoschool/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final SupabaseService _service = SupabaseService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      Fluttertoast.showToast(msg: 'Email dan password harus diisi');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await _service.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (user != null) {
        Fluttertoast.showToast(
          msg: 'Login berhasil! Selamat datang ${user.nama}',
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        
        // Navigasi berdasarkan role
        Widget destination;
        switch (user.role) {
          case 'admin':
            destination = const AdminHomePage();
            break;
          case 'siswa':
            destination = const HomePage();
            break;
          case 'guru':
            destination = const GuruHomePage(); // Ganti dengan GuruHomePage nanti
            break;
          case 'walimurid':
            destination = const HomepageWali(); // Ganti dengan WaliHomePage nanti
            break;
          default:
            destination = const HomePage();
        }

        Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (_) => destination),
        );
      } else {
        Fluttertoast.showToast(
          msg: 'Login gagal: User tidak ditemukan',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Login gagal: $e',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

// lib/auth/login.dart - Bagian Build dengan UI Modern
@override
Widget build(BuildContext context) {
  // 🔥 DETEKSI UKURAN LAYAR
  final screenWidth = MediaQuery.of(context).size.width;
  final isDesktop = screenWidth > 800;
  final isTablet = screenWidth > 600 && screenWidth <= 800;
  
  // 🔥 UKURAN RESPONSIVE
  final double containerWidth = isDesktop ? 450 : (isTablet ? 380 : double.infinity);
  final double paddingMain = isDesktop ? 40 : (isTablet ? 32 : 24);
  final double iconSize = isDesktop ? 90 : (isTablet ? 80 : 70);
  final double titleSize = isDesktop ? 38 : (isTablet ? 34 : 30);
  final double fontSize = isDesktop ? 16 : (isTablet ? 15 : 14);

  return Scaffold(
    // 🔥 BACKGROUND GRADIENT MODERN
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromARGB(255, 2, 160, 160),  // Light Green
            Color.fromARGB(255, 125, 194, 189),  // Light Teal
            Color.fromARGB(255, 244, 246, 247),  // Light Cyan
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(paddingMain),
            child: Container(
              constraints: BoxConstraints(maxWidth: containerWidth),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 🔥 GLASSMORPHISM CARD UNTUK LOGO
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      //color: Colors.white.withOpacity(0.7),
                      //borderRadius: BorderRadius.circular(20),

 
                    ),
                    child: Column(
                      children: [
                        // 🔥 ICON DENGAN BACKGROUND GLOW
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color.fromARGB(255, 2, 78, 69),
                                Color.fromARGB(255, 231, 230, 150),
                                Color.fromARGB(255, 18, 85, 78),
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(255, 0, 82, 73).withOpacity(0.4),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.school,
                            size: 55,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // 🔥 TITLE DENGAN GRADIENT TEXT
                        ShaderMask(
                          shaderCallback: (bounds) => const RadialGradient(
                           // begin: Alignment.topLeft,
                            //end: Alignment.bottomRight,
                            colors: [
                              Color.fromARGB(255, 241, 241, 223),
                              Color.fromARGB(255, 228, 226, 119),
                              Color.fromARGB(255, 243, 178, 1),
                            ],
                          ).createShader(bounds),
                          child: RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Auto',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                TextSpan(
                                  text: 'School',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 0, 94, 97), // Biru
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          'Sistem Manajemen Sekolah',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color.fromARGB(255, 1, 99, 82),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 🔥 QUICK LOGIN BUTTONS - MODERN
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.08),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.teal.withOpacity(0.1),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00897B).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.info_outline,
                                color: Color(0xFF00897B),
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Text(
                              'Akun Testing',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                                color: Color(0xFF00695C),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        // 🔥 WRAP UNTUK RESPONSIVE
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 2,
                          runSpacing: 8,
                          children: [
                            _buildQuickLoginButton(
                              'Siswa',
                              'siswa@tester.com',
                              'siswa123',
                              const Color(0xFF1565C0),
                              Icons.person,
                            ),
      
                            _buildQuickLoginButton(
                              'Guru',
                              'guru1@tester.com',
                              'guru123',
                              const Color(0xFF2E7D32),
                              Icons.school,
                            ),
                            _buildQuickLoginButton(
                              'Wali',
                              'walimurid1@tester.com',
                              'wali123',
                              const Color(0xFF6A1B9A),
                              Icons.family_restroom,
                            ),
                            _buildQuickLoginButton(
                              'Admin',
                              'admin@tester.com',
                              'admin123',
                              const Color(0xFFBF360C),
                              Icons.admin_panel_settings,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 🔥 FORM LOGIN - MODERN
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.08),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.teal.withOpacity(0.1),
                      ),
                    ),
                    child: Column(
                      children: [
                        // 🔥 EMAIL FIELD
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: TextStyle(
                              color: Colors.grey[600],
                              fontSize: fontSize,
                            ),
                            prefixIcon: Icon(
                              Icons.email,
                              color: Color.fromARGB(255, 243, 178, 1),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey[300]!,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey[300]!,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color.fromARGB(255, 243, 178, 1),
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: isDesktop ? 18 : 14,
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(fontSize: fontSize),
                        ),
                        const SizedBox(height: 16),
                        
                        // 🔥 PASSWORD FIELD
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(
                              color: Colors.grey[600],
                              fontSize: fontSize,
                            ),
                            prefixIcon: Icon(
                              Icons.lock,
                              color: Color.fromARGB(255, 243, 178, 1),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                color: Colors.grey[500],
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey[300]!,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey[300]!,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color.fromARGB(255, 243, 178, 1),
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: isDesktop ? 18 : 14,
                            ),
                          ),
                          onSubmitted: (_) => _login(),
                          style: TextStyle(fontSize: fontSize),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // 🔥 LOGIN BUTTON - MODERN
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF00695C),
                          Color.fromARGB(255, 22, 139, 128),
                          Color.fromARGB(255, 243, 178, 1),
                          
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00897B).withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: isDesktop ? 56 : 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.login,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Login',
                                    style: TextStyle(
                                      fontSize: isDesktop ? 18 : 16,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                      
                    ),
                  ),

                  const SizedBox(height: 30),

                  Container(
                     child: RichText(
                      
                            text: const TextSpan(
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              
                              children: [
                                TextSpan(
                                  text: 'kin',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 247, 202, 1),
                                  ),
                                ),
                                TextSpan(
                                  text: 'blackid',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 0, 94, 97), // Biru
                                  ),
                                ),
                              ],
                              text: "......@2026"
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}


// 🔥 QUICK LOGIN BUTTON - TANPA FITTEDBOX
Widget _buildQuickLoginButton(
  String label,
  String email,
  String password,
  Color color,
  IconData icon,
) {
  return SizedBox(
    width: 72,
    height: 32,
    child: ElevatedButton(
      onPressed: () {
        setState(() {
          _emailController.text = email;
          _passwordController.text = password;
        });
        Future.delayed(const Duration(milliseconds: 500), _login);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.15),
        foregroundColor: color,
        elevation: 0,
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: color.withOpacity(0.3)),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      ),
    ),
  );
}
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}