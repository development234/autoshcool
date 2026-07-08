// lib/pages/guru/homepage_guru.dart
import 'package:autoschool/pages/guru/absensi.dart';
import 'package:autoschool/pages/guru/buat_materi_ajar.dart';
import 'package:autoschool/pages/guru/buat_tugas.dart';
import 'package:autoschool/pages/guru/input_nilai.dart';
import 'package:autoschool/pages/siswa/profile.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../services/supabase_service.dart';

class GuruHomePage extends StatefulWidget {
  const GuruHomePage({super.key});

  @override
  State<GuruHomePage> createState() => _GuruHomePageState();
}

class _GuruHomePageState extends State<GuruHomePage> {
  final SupabaseService _service = SupabaseService();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  
  // Data dummy untuk statistik
  Map<String, int> _statistics = {
    'siswa': 32,
    'tugas': 8,
    'materi': 12,
    'absensi': 95,
  };

  // 🔥 DATA DUMMY
  final List<Map<String, dynamic>> _dummyMateri = [
    {
      'judul': 'Bab 1: Pengenalan Matematika Dasar',
      'subtitle': 'Kelas 10A - 15 Juli 2026',
      'status': 'Selesai',
    },
    {
      'judul': 'Bab 2: Persamaan Linear',
      'subtitle': 'Kelas 10A - 16 Juli 2026',
      'status': 'Proses',
    },
    {
      'judul': 'Bab 3: Fungsi Kuadrat',
      'subtitle': 'Kelas 10B - 17 Juli 2026',
      'status': 'Belum',
    },
    {
      'judul': 'Bab 4: Trigonometri Dasar',
      'subtitle': 'Kelas 10A - 18 Juli 2026',
      'status': 'Selesai',
    },
    {
      'judul': 'Bab 5: Statistika',
      'subtitle': 'Kelas 10B - 19 Juli 2026',
      'status': 'Proses',
    },
  ];

  final List<Map<String, dynamic>> _dummyTugas = [
    {
      'judul': 'Tugas 1: Latihan Persamaan Linear',
      'subtitle': 'Deadline: 20 Juli 2026',
      'status': 'Selesai',
    },
    {
      'judul': 'Tugas 2: Soal Fungsi Kuadrat',
      'subtitle': 'Deadline: 22 Juli 2026',
      'status': 'Proses',
    },
    {
      'judul': 'Tugas 3: Trigonometri',
      'subtitle': 'Deadline: 25 Juli 2026',
      'status': 'Belum',
    },
    {
      'judul': 'Tugas 4: Statistika',
      'subtitle': 'Deadline: 28 Juli 2026',
      'status': 'Belum',
    },
    {
      'judul': 'Tugas 5: Ujian Tengah Semester',
      'subtitle': 'Deadline: 30 Juli 2026',
      'status': 'Proses',
    },
  ];

  final List<Map<String, dynamic>> _dummyAbsensi = [
    {
      'judul': 'Senin, 15 Juli 2026',
      'subtitle': 'Kelas 10A - Jam 07:30',
      'status': 'Hadir',
    },
    {
      'judul': 'Selasa, 16 Juli 2026',
      'subtitle': 'Kelas 10A - Jam 07:30',
      'status': 'Hadir',
    },
    {
      'judul': 'Rabu, 17 Juli 2026',
      'subtitle': 'Kelas 10B - Jam 07:30',
      'status': 'Izin',
    },
    {
      'judul': 'Kamis, 18 Juli 2026',
      'subtitle': 'Kelas 10A - Jam 07:30',
      'status': 'Sakit',
    },
    {
      'judul': 'Jumat, 19 Juli 2026',
      'subtitle': 'Kelas 10B - Jam 07:30',
      'status': 'Hadir',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final user = _service.getCurrentUser();
      if (user != null) {
        final data = await _service.getUserData(user.id);
        if (data != null) {
          setState(() {
            _userData = data;
            _isLoading = false;
          });
          print('✅ Guru data loaded: ${data['nama']}');
        } else {
          setState(() {
            _userData = {
              'id': user.id,
              'email': user.email,
              'nama': user.email?.split('@').first ?? 'Guru',
              'role': 'guru',
              'nip': '-',
            };
            _isLoading = false;
          });
        }
      } else {
        setState(() => _isLoading = false);
        Fluttertoast.showToast(msg: 'Silakan login kembali');
      }
    } catch (e) {
      print('❌ Error loading data: $e');
      setState(() => _isLoading = false);
      Fluttertoast.showToast(msg: 'Error: $e');
    }
  }

  void _logout() async {
    await _service.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🔥 APPBAR
      appBar: AppBar(
        title: const Text(
          'AutoSchool - Guru',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 4,
        centerTitle: true,
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
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      
      // 🔥 DRAWER
      drawer: _buildDrawer(),
      
      // 🔥 BODY
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color.fromARGB(255, 211, 243, 237),
              Colors.white,
            ],
          ),
        ),
        child: _isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Memuat data...'),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔥 SECTION 1: GREETING CARD
                    _buildGreetingCard(),
                    
                    const SizedBox(height: 16),
                    
                    // 🔥 SECTION 2: STATISTICS CARDS
                    _buildStatisticsSection(),
                    
                    const SizedBox(height: 16),
                    
                    // 🔥 SECTION 3: TABEL DATA (Materi, Tugas, Absensi)
                    _buildDataTablesSection(),
                  ],
                ),
              ),
      ),
    );
  }

  // 🔥 GREETING CARD
  Widget _buildGreetingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        //gradient: cons//t LinearGradient(
        //  begin: Alignment.topLeft,
          //end: Alignment.bottomRight,
          //colors: [
           // Color.fromARGB(255, 161, 238, 243),
          //  Color.fromARGB(255, 229, 235, 236),
         // ],
       // ),
       // boxShadow: [
        //  BoxShadow(
        //    color: const Color.fromARGB(255, 1, 54, 63).withOpacity(0.3),
        //    blurRadius: 10,
        //    offset: const Offset(0, 4),
        //  ),
      //],
      ),
      child: Row(
        children: [
          // 🔥 KOLOM KIRI - ICON
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 3, 108, 122),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.school,
              size: 40,
              color: Color.fromARGB(255, 235, 249, 250),
            ),
          ),
          const SizedBox(width: 16),
          
          // 🔥 KOLOM KANAN - TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat Datang, ${_userData?['nama'] ?? 'Guru'}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 1, 105, 131),
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  'Anda terdaftar sebagai Guru',
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color.fromARGB(255, 1, 73, 70).withOpacity(0.9),
                  ),
                ),
                // 🔥 GARIS
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  height: 1,
                  color: const Color.fromARGB(255, 1, 72, 85).withOpacity(0.3),
                ),
                // 🔥 INFO NIP
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  child: Row(
                    children: [
                      Icon(
                        Icons.badge,
                        size: 14,
                        color: const Color.fromARGB(255, 1, 78, 88).withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'NIP: ${_userData?['nip'] ?? '-'}',
                        style: TextStyle(
                          fontSize: 11,
                          color: const Color.fromARGB(255, 1, 78, 88).withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.assignment_ind,
                        size: 14,
                        color: const Color.fromARGB(255, 1, 78, 88).withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _userData?['role']?.toUpperCase() ?? 'GURU',
                        style: TextStyle(
                          fontSize: 11,
                          color: const Color.fromARGB(255, 1, 78, 88).withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 STATISTICS SECTION
  Widget _buildStatisticsSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: const Color.fromARGB(255, 1, 155, 129).withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.analytics,
                  size: 16,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Statistik',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 1, 155, 129),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Siswa',
                  _statistics['siswa']?.toString() ?? '0',
                  Icons.school,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Tugas',
                  _statistics['tugas']?.toString() ?? '0',
                  Icons.book,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Materi',
                  _statistics['materi']?.toString() ?? '0',
                  Icons.menu_book,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Absensi',
                  '${_statistics['absensi'] ?? 0}%',
                  Icons.check_circle,
                  Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 🔥 DATA TABLES SECTION
  Widget _buildDataTablesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔥 TABEL 1: MATERI
        _buildDataTable(
          title: '📖 Materi Terbaru',
          icon: Icons.menu_book,
          color: Colors.blue,
          data: _dummyMateri,
          onViewAll: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BuatMateriAjarPage()),
            );
          },
        ),
        const SizedBox(height: 16),

        // 🔥 TABEL 2: TUGAS
        _buildDataTable(
          title: '📋 Tugas Terbaru',
          icon: Icons.assignment,
          color: Colors.orange,
          data: _dummyTugas,
          onViewAll: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BuatTugasPage()),
            );
          },
        ),
        const SizedBox(height: 16),
        
        // 🔥 TABEL 3: ABSENSI
        _buildDataTable(
          title: '✅ Absensi Hari Ini',
          icon: Icons.check_circle,
          color: Colors.green,
          data: _dummyAbsensi,
          onViewAll: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GuruAbsensiPage()),
            );
          },
        ),
      ],
    );
  }

  // 🔥 WIDGET DATA TABLE
  Widget _buildDataTable({
    required String title,
    required IconData icon,
    required Color color,
    required List<Map<String, dynamic>> data,
    required VoidCallback onViewAll,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔥 HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      size: 16,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: onViewAll,
                style: TextButton.styleFrom(
                  foregroundColor: color,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Lihat Semua →',
                  style: TextStyle(fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // 🔥 LIST DATA
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: data.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Colors.grey[200],
            ),
            itemBuilder: (context, index) {
              final item = data[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    // Icon status
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.circle,
                        size: 10,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['judul'] ?? item['nama'] ?? 'Item',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            item['subtitle'] ?? item['tanggal'] ?? '',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Status/Tanggal
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getStatusColor(item['status']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        item['status'] ?? 'Active',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: _getStatusColor(item['status']),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 🔥 GET STATUS COLOR
  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'selesai':
      case 'hadir':
        return Colors.green;
      case 'proses':
      case 'izin':
        return Colors.orange;
      case 'belum':
      case 'sakit':
        return Colors.red;
      case 'alpha':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  // 🔥 DRAWER
  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 27, 90, 94),
              Color.fromARGB(255, 46, 107, 125),
            ],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // 🔥 HEADER DRAWER - 1 BARIS 2 KOLOM
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 🔥 KOLOM 1: ICON
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.school,
                      color: Color(0xFF2E7D32),
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // 🔥 KOLOM 2: TEXT
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _userData?['nama'] ?? 'Guru',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Guru',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          'NIP: ${_userData?['nip'] ?? '-'}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // 🔥 MENU ITEMS
            _buildDrawerItem(
              icon: Icons.dashboard,
              title: 'Dashboard',
              color: Colors.white,
              onTap: () => Navigator.pop(context),
            ),
            
            _buildDrawerItem(
              icon: Icons.grade,
              title: 'Input Nilai',
              color: Colors.amber,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const InputNilaiPage()),
                );
              },
            ),
            
            _buildDrawerItem(
              icon: Icons.check_circle,
              title: 'Absensi',
              color: Colors.green,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GuruAbsensiPage()),
                );
              },
            ),
            
            _buildDrawerItem(
              icon: Icons.assignment_add,
              title: 'Buat Tugas',
              color: Colors.orange,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BuatTugasPage()),
                );
              },
            ),
            
            _buildDrawerItem(
              icon: Icons.create_new_folder,
              title: 'Buat Materi',
              color: Colors.purple,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BuatMateriAjarPage()),
                );
              },
            ),
            
            _buildDrawerItem(
              icon: Icons.person,
              title: 'Profile',
              color: Colors.teal,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()),
                );
              },
            ),
            
            _buildDrawerItem(
              icon: Icons.logout,
              title: 'Logout',
              color: Colors.red,
              onTap: () {
                Navigator.pop(context);
                _showLogoutDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 WIDGET DRAWER ITEM
  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color, size: 24),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: Colors.white54,
        size: 16,
      ),
      onTap: onTap,
      hoverColor: Colors.white.withOpacity(0.1),
      splashColor: Colors.white.withOpacity(0.2),
    );
  }

  // 🔥 WIDGET STAT CARD
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 9,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // 🔥 DIALOG LOGOUT
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}