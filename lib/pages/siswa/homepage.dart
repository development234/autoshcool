// lib/pages/siswa/homepage.dart
import 'package:autoschool/pages/siswa/absensi.dart';
import 'package:autoschool/pages/siswa/jadwal.dart';
import 'package:autoschool/pages/siswa/materi.dart';
import 'package:autoschool/pages/siswa/prestasi.dart';
import 'package:autoschool/pages/siswa/profile.dart';
import 'package:autoschool/pages/siswa/tugas.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../services/supabase_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SupabaseService _service = SupabaseService();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  
  // 🔥 DATA DARI DATABASE
  List<Map<String, dynamic>> _materiList = [];
  List<Map<String, dynamic>> _jadwalList = [];
  List<Map<String, dynamic>> _tugasList = [];
  List<Map<String, dynamic>> _absensiList = [];
  
  // 🔥 STATISTIK
  int _totalAbsensi = 0;
  int _totalTugas = 0;
  int _totalMateri = 0;

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
        print('✅ User found: ${user.email}');
        
        // 🔥 AMBIL DATA USER
        final data = _service.getUserDataFromAuth();
        
        if (data != null) {
          print('✅ Data: ${data['nama']} - ${data['role']}');
          setState(() {
            _userData = data;
          });
        } else {
          setState(() {
            _userData = {
              'id': user.id,
              'email': user.email,
              'nama': user.email?.split('@').first ?? 'User',
              'role': 'siswa',
              'kelas': '-',
              'nis': '-',
            };
          });
        }
        
        // 🔥 AMBIL DATA DARI DATABASE
        await _loadDataFromDatabase();
        
        setState(() => _isLoading = false);
        
      } else {
        print('❌ No user');
        setState(() => _isLoading = false);
        Fluttertoast.showToast(msg: 'Silakan login kembali');
      }
    } catch (e) {
      print('❌ Error: $e');
      setState(() => _isLoading = false);
      Fluttertoast.showToast(msg: 'Error loading data: $e');
    }
  }

// lib/pages/siswa/homepage.dart
// Perbaiki bagian _loadDataFromDatabase

  // 🔥 LOAD DATA DARI DATABASE
  Future<void> _loadDataFromDatabase() async {
    try {
      // Ambil data user untuk mendapatkan kelas
      final user = _service.getCurrentUser();
      if (user == null) return;
      
      final userData = await _service.getUserData(user.id);
      final kelas = userData?['kelas'] ?? '';
      
      print('📚 Kelas siswa: $kelas');
      
      // 🔥 AMBIL MATERI berdasarkan kelas
      try {
        final materi = await _service.getMateriByKelas(kelas);
        setState(() {
          _materiList = materi;
          _totalMateri = materi.length;
        });
        print('✅ Materi loaded: ${materi.length}');
      } catch (e) {
        print('⚠️ Error loading materi: $e');
        _materiList = _getDummyMateri();
        _totalMateri = _materiList.length;
      }
      
      // 🔥 AMBIL TUGAS berdasarkan kelas
      try {
        final tugas = await _service.getTugasByKelas(kelas);
        setState(() {
          _tugasList = tugas;
          _totalTugas = tugas.length;
        });
        print('✅ Tugas loaded: ${tugas.length}');
      } catch (e) {
        print('⚠️ Error loading tugas: $e');
        _tugasList = _getDummyTugas();
        _totalTugas = _tugasList.length;
      }
      
      // 🔥 AMBIL ABSENSI berdasarkan siswa
      try {
        final absensi = await _service.getAbsensiBySiswa(user.id);
        setState(() {
          _absensiList = absensi;
          _totalAbsensi = absensi.length;
        });
        print('✅ Absensi loaded: ${absensi.length}');
      } catch (e) {
        print('⚠️ Error loading absensi: $e');
        _absensiList = _getDummyAbsensi();
        _totalAbsensi = _absensiList.length;
      }
      
      // 🔥 AMBIL JADWAL berdasarkan kelas
      try {
        final jadwal = await _service.getJadwalByKelas(kelas);
        setState(() {
          _jadwalList = jadwal;
        });
        print('✅ Jadwal loaded: ${jadwal.length}');
      } catch (e) {
        print('⚠️ Error loading jadwal: $e');
        _jadwalList = _getDummyJadwal();
      }
      
    } catch (e) {
      print('❌ Error loading data from database: $e');
      // Fallback ke dummy data
      _materiList = _getDummyMateri();
      _tugasList = _getDummyTugas();
      _absensiList = _getDummyAbsensi();
      _jadwalList = _getDummyJadwal();
      _totalMateri = _materiList.length;
      _totalTugas = _tugasList.length;
      _totalAbsensi = _absensiList.length;
    }
  }
  
  
  // 🔥 DATA DUMMY (FALLBACK)
  List<Map<String, dynamic>> _getDummyMateri() {
    return [
      {'judul': 'Bab 1: Pengenalan Matematika Dasar', 'subtitle': 'Kelas 10A - 15 Juli 2026', 'status': 'Selesai'},
      {'judul': 'Bab 2: Persamaan Linear', 'subtitle': 'Kelas 10A - 16 Juli 2026', 'status': 'Proses'},
      {'judul': 'Bab 3: Fungsi Kuadrat', 'subtitle': 'Kelas 10B - 17 Juli 2026', 'status': 'Belum'},
      {'judul': 'Bab 4: Trigonometri Dasar', 'subtitle': 'Kelas 10A - 18 Juli 2026', 'status': 'Selesai'},
      {'judul': 'Bab 5: Statistika', 'subtitle': 'Kelas 10B - 19 Juli 2026', 'status': 'Proses'},
    ];
  }

  List<Map<String, dynamic>> _getDummyTugas() {
    return [
      {'judul': 'Tugas 1: Latihan Persamaan Linear', 'subtitle': 'Deadline: 20 Juli 2026', 'status': 'Selesai'},
      {'judul': 'Tugas 2: Soal Fungsi Kuadrat', 'subtitle': 'Deadline: 22 Juli 2026', 'status': 'Proses'},
      {'judul': 'Tugas 3: Trigonometri', 'subtitle': 'Deadline: 25 Juli 2026', 'status': 'Belum'},
      {'judul': 'Tugas 4: Statistika', 'subtitle': 'Deadline: 28 Juli 2026', 'status': 'Belum'},
      {'judul': 'Tugas 5: Ujian Tengah Semester', 'subtitle': 'Deadline: 30 Juli 2026', 'status': 'Proses'},
    ];
  }

  List<Map<String, dynamic>> _getDummyAbsensi() {
    return [
      {'judul': 'Senin, 15 Juli 2026', 'subtitle': 'Kelas 10A - Jam 07:30', 'status': 'Hadir'},
      {'judul': 'Selasa, 16 Juli 2026', 'subtitle': 'Kelas 10A - Jam 07:30', 'status': 'Hadir'},
      {'judul': 'Rabu, 17 Juli 2026', 'subtitle': 'Kelas 10B - Jam 07:30', 'status': 'Izin'},
      {'judul': 'Kamis, 18 Juli 2026', 'subtitle': 'Kelas 10A - Jam 07:30', 'status': 'Sakit'},
      {'judul': 'Jumat, 19 Juli 2026', 'subtitle': 'Kelas 10B - Jam 07:30', 'status': 'Hadir'},
    ];
  }

  List<Map<String, dynamic>> _getDummyJadwal() {
    return [
      {'judul': 'Matematika', 'subtitle': 'Senin, 07:30 - 08:30', 'status': 'Ruang 101'},
      {'judul': 'Bahasa Indonesia', 'subtitle': 'Senin, 08:30 - 09:30', 'status': 'Ruang 102'},
      {'judul': 'Bahasa Inggris', 'subtitle': 'Selasa, 07:30 - 08:30', 'status': 'Ruang 103'},
      {'judul': 'Fisika', 'subtitle': 'Selasa, 08:30 - 09:30', 'status': 'Ruang 201'},
      {'judul': 'Kimia', 'subtitle': 'Rabu, 07:30 - 08:30', 'status': 'Ruang 202'},
    ];
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
      appBar: AppBar(
        title: const Text(
          'AutoSchool - Siswa',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
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
      drawer: _buildDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userData == null
              ? const Center(child: Text('Data tidak ditemukan'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🔥 BARIS 1: GREETING CARD
                      _buildGreetingCard(),
                      
                      const SizedBox(height: 16),
                      
                      // 🔥 BARIS 2: 3 CARD STATISTIK
                      _buildStatisticsRow(),
                      
                      const SizedBox(height: 16),
                      
                      // 🔥 BARIS 3: TABEL MATERI
                      _buildDataTable(
                        title: '📖 Materi Terbaru',
                        icon: Icons.menu_book,
                        color: Colors.blue,
                        data: _materiList,
                        onViewAll: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const MateriPage()),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // 🔥 BARIS 4: TABEL JADWAL
                      _buildDataTable(
                        title: '📅 Jadwal Hari Ini',
                        icon: Icons.schedule,
                        color: Colors.green,
                        data: _jadwalList,
                        onViewAll: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const JadwalPage()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
    );
  }

  // 🔥 BARIS 1: GREETING CARD
  Widget _buildGreetingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromARGB(255, 161, 238, 243),
            Color.fromARGB(255, 229, 235, 236),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 1, 54, 63).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 1, 83, 94),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat Datang,',
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color.fromARGB(255, 1, 105, 131).withOpacity(0.8),
                  ),
                ),
                Text(
                  _userData?['nama'] ?? 'Siswa',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 1, 105, 131),
                  ),
                ),
                Text(
                  '${_userData?['kelas'] ?? '-'} · ${_userData?['nis'] ?? '-'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color.fromARGB(255, 1, 105, 131).withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 BARIS 2: 3 CARD STATISTIK
  Widget _buildStatisticsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Absensi',
            '$_totalAbsensi',
            Icons.check_circle,
            Colors.green,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AbsensiPage()),
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            'Tugas',
            '$_totalTugas',
            Icons.book,
            Colors.blue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TugasPage()),
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            'Materi',
            '$_totalMateri',
            Icons.menu_book,
            Colors.orange,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MateriPage()),
              );
            },
          ),
        ),
      ],
    );
  }

  // 🔥 WIDGET STAT CARD
  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
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
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
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
          data.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text(
                      'Belum ada data',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: data.length > 5 ? 5 : data.length,
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['judul'] ?? item['mata_pelajaran'] ?? 'Item',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  item['subtitle'] ?? item['tanggal'] ?? item['jam_mulai'] ?? '',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
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
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Color.fromARGB(255, 27, 90, 94),
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _userData?['nama'] ?? 'Siswa',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Siswa',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          'Kelas: ${_userData?['kelas'] ?? '-'}',
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
            
            _buildDrawerItem(
              icon: Icons.dashboard,
              title: 'Dashboard',
              color: Colors.white,
              onTap: () => Navigator.pop(context),
            ),
            const Divider(color: Colors.white24, thickness: 1),
            _buildDrawerItem(
              icon: Icons.book,
              title: 'Tugas',
              color: Colors.blue,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const TugasPage()));
              },
            ),
            _buildDrawerItem(
              icon: Icons.schedule,
              title: 'Jadwal',
              color: Colors.green,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const JadwalPage()));
              },
            ),
            _buildDrawerItem(
              icon: Icons.check_circle,
              title: 'Absensi',
              color: Colors.orange,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AbsensiPage()));
              },
            ),
            _buildDrawerItem(
              icon: Icons.stars,
              title: 'Prestasi',
              color: Colors.purple,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const PrestasiPage()));
              },
            ),
            _buildDrawerItem(
              icon: Icons.menu_book,
              title: 'Materi',
              color: Colors.teal,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const MateriPage()));
              },
            ),
            const Divider(color: Colors.white24, thickness: 1),
            _buildDrawerItem(
              icon: Icons.person,
              title: 'Profile',
              color: Colors.pink,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
              },
            ),
            _buildDrawerItem(
              icon: Icons.logout,
              title: 'Logout',
              color: Colors.red,
              onTap: _logout,
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
}