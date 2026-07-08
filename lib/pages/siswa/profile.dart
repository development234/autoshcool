import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../services/supabase_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final SupabaseService _service = SupabaseService();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;

  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _kelasController = TextEditingController();
  final _nisController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final user = _service.getCurrentUser();
      if (user != null) {
        final data = await _service.getUserData(user.id);
        if (data != null) {
          setState(() {
            _userData = data;
            _namaController.text = data['nama'] ?? '';
            _emailController.text = data['email'] ?? '';
            _kelasController.text = data['kelas'] ?? '';
            _nisController.text = data['nis'] ?? '';
          });
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (_userData == null) return;
    
    setState(() => _isSaving = true);

    try {
      final updates = {
        'nama': _namaController.text,
      };
      
      if (_kelasController.text.isNotEmpty) {
        updates['kelas'] = _kelasController.text;
      }
      
      if (_nisController.text.isNotEmpty) {
        updates['nis'] = _nisController.text;
      }

      await _service.updateUserProfile(_userData!['id'], updates);
      
      setState(() {
        _userData!.addAll(updates);
        _isEditing = false;
      });
      
      Fluttertoast.showToast(msg: 'Profil berhasil diperbarui');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Gagal menyimpan: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        final file = File(image.path);
        final user = _service.getCurrentUser();
        
        if (user != null && _userData != null) {
          final path = 'foto/${user.id}.jpg';
          final url = await _service.uploadFile('avatars', path, file);
          
          await _service.updateUserProfile(_userData!['id'], {'foto': url});
          
          setState(() {
            _userData!['foto'] = url;
          });
          
          Fluttertoast.showToast(msg: 'Foto berhasil diupload');
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Gagal upload foto: $e');
    }
  }

  Widget _buildProfileImage() {
    return Stack(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[300],
            image: _userData?['foto'] != null
                ? DecorationImage(
                    image: NetworkImage(_userData!['foto']),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: _userData?['foto'] == null
              ? Icon(
                  Icons.person,
                  size: 60,
                  color: Colors.grey[600],
                )
              : null,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 18,
              ),
              onPressed: _pickImage,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.blue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableField(String label, String value, TextEditingController controller,
      {IconData? icon, bool enabled = true}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.blue),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: controller,
                  enabled: _isEditing && enabled,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    border: _isEditing && enabled
                        ? const OutlineInputBorder()
                        : InputBorder.none,
                    contentPadding: _isEditing && enabled
                        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
                        : EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontSize: 14),),
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
        actions: [
          if (!_isLoading)
            IconButton(
              icon: Icon(_isEditing ? Icons.save : Icons.edit),
              onPressed: _isSaving
                  ? null
                  : () {
                      if (_isEditing) {
                        _saveProfile();
                      } else {
                        setState(() => _isEditing = true);
                      }
                    },
            ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _isEditing = false;
                  _loadProfile();
                });
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Profile Image
                  Center(child: _buildProfileImage()),
                  const SizedBox(height: 24),
                  
                  // User info
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildEditableField(
                            'Nama Lengkap',
                            _userData?['nama'] ?? '',
                            _namaController,
                            icon: Icons.person,
                          ),
                          _buildEditableField(
                            'Email',
                            _userData?['email'] ?? '',
                            _emailController,
                            icon: Icons.email,
                            enabled: false,
                          ),
                          if (_userData?['role'] == 'siswa') ...[
                            _buildEditableField(
                              'Kelas',
                              _userData?['kelas'] ?? '',
                              _kelasController,
                              icon: Icons.class_,
                            ),
                            _buildEditableField(
                              'NIS',
                              _userData?['nis'] ?? '',
                              _nisController,
                              icon: Icons.numbers,
                            ),
                          ],
                          _buildInfoRow(
                            'Role',
                            _userData?['role']?.toUpperCase() ?? 'SISWA',
                            Icons.assignment_ind,
                          ),
                          _buildInfoRow(
                            'Bergabung Sejak',
                            _userData?['created_at']?.substring(0, 10) ??
                                'Tanggal tidak tersedia',
                            Icons.calendar_today,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Logout button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving
                          ? null
                          : () async {
                              await _service.signOut();
                              if (mounted) {
                                Navigator.pushReplacementNamed(context, '/login');
                              }
                            },
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _kelasController.dispose();
    _nisController.dispose();
    super.dispose();
  }
}

extension on SupabaseService {
  Future<dynamic> uploadFile(String s, String path, File file) async {}
}