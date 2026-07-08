// lib/pages/admin/homepage_admin.dart
import 'package:autoschool/pages/admin/crud_guru.dart';
import 'package:autoschool/pages/admin/crud_keuangan.dart';
import 'package:autoschool/pages/admin/crud_siswa.dart';
import 'package:autoschool/pages/admin/crud_user.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../services/supabase_service.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final SupabaseService _service = SupabaseService();
  Map<String, dynamic>? _adminData;
  Map<String, int> _statistics = {};
  bool _isLoading = true;
  // 🔥 VARIABLES UNTUK USER TABLE
  List<Map<String, dynamic>> _users = [];
  bool _isLoadingUsers = false;
  int _currentPage = 1;
  int _pageSize = 5;

int get _totalPages => (_users.length / _pageSize).ceil();
  // 🔥 DATA DUMMY UNTUK STATISTIK (SEMENTARA)
  final Map<String, int> _dummyStats = {
    'total': 25,
    'siswa': 15,
    'guru': 5,
    'walimurid': 5,
  };

  @override
  void initState() {
    super.initState();
    _loadData(); // 🔥 PANGGIL _loadData()
  }

  // 🔥 LOAD DATA - SAMA SEPERTI DI HOMEPAGE SISWA
  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final user = _service.getCurrentUser();
      
      if (user != null) {
        print('✅ Admin user found: ${user.email}');
        
        // 🔥 AMBIL DATA DARI AUTH
        final data = _service.getUserDataFromAuth();
        
        if (data != null) {
          print('✅ Admin data: ${data['nama']} - ${data['role']}');
          setState(() {
            _adminData = data;
          });
        } else {
          // 🔥 FALLBACK: BUAT DATA SENDIRI
          setState(() {
            _adminData = {
              'id': user.id,
              'email': user.email,
              'nama': user.email?.split('@').first ?? 'Admin',
              'role': 'admin',
            };
          });
        }
        
        // 🔥 AMBIL STATISTIK DARI DATABASE
        await _loadStatistics();
        
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

  // 🔥 LOAD STATISTIK DAN USER
  Future<void> _loadStatistics() async {
    setState(() {
      _isLoading = true;
      _isLoadingUsers = true;
    });

    try {
      // 🔥 AMBIL SEMUA USER
      final allUsers = await _service.getAllUsers();
      
      // 🔥 HITUNG STATISTIK
      final total = allUsers.length;
      final siswa = allUsers.where((u) => u['role'] == 'siswa').length;
      final guru = allUsers.where((u) => u['role'] == 'guru').length;
      final walimurid = allUsers.where((u) => u['role'] == 'walimurid').length;
      final admin = allUsers.where((u) => u['role'] == 'admin').length;
      
      setState(() {
        _statistics = {
          'total': total,
          'siswa': siswa,
          'guru': guru,
          'walimurid': walimurid,
          'admin': admin,
        };
        _users = allUsers;
        _isLoading = false;
        _isLoadingUsers = false;
      });
      
      print('✅ Statistics: total=$total, siswa=$siswa, guru=$guru, walimurid=$walimurid');
      
    } catch (e) {
      print('⚠️ Error: $e');
      setState(() {
        _isLoading = false;
        _isLoadingUsers = false;
      });
    }
  }

  // 🔥 STATISTICS SECTION - RESPONSIVE
  Widget _buildStatisticsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '📊 Statistik',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width < 600 ? 18 : 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _formatDate(DateTime.now()),
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width < 600 ? 9 : 10,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // 🔥 SCROLL HORIZONTAL - RESPONSIVE
        SizedBox(
          height: MediaQuery.of(context).size.width < 600 ? 110 : 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildStatCard(
                'Total User',
                _statistics['total']?.toString() ?? '0',
                Icons.people,
                Colors.blue,
                'Total',
              ),
              _buildStatCard(
                'Siswa',
                _statistics['siswa']?.toString() ?? '0',
                Icons.school,
                Colors.green,
                'Students',
              ),
              _buildStatCard(
                'Guru',
                _statistics['guru']?.toString() ?? '0',
                Icons.person,
                Colors.orange,
                'Teachers',
              ),
              _buildStatCard(
                'Wali Murid',
                _statistics['walimurid']?.toString() ?? '0',
                Icons.family_restroom,
                Colors.purple,
                'Parents',
              ),
              _buildStatCard(
                'Admin',
                _statistics['admin']?.toString() ?? '1',
                Icons.admin_panel_settings,
                Colors.red,
                'Admins',
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 🔥 INFographic CARD - FULLY RESPONSIVE
  Widget _buildStatCard(String title, String value, IconData icon, Color color, String subtitle) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 🔥 DETEKSI UKURAN LAYAR
        final screenWidth = MediaQuery.of(context).size.width;
        final isMobile = screenWidth < 600;
        final isTablet = screenWidth >= 600 && screenWidth < 900;
        final isDesktop = screenWidth >= 900;
        
        // 🔥 UKURAN RESPONSIVE
        final double cardWidth = isMobile ? 120 : (isTablet ? 140 : 160);
        final double paddingCard = isMobile ? 10 : (isTablet ? 12 : 14);
        final double iconSize = isMobile ? 20 : (isTablet ? 24 : 28);
        final double fontSizeValue = isMobile ? 16 : (isTablet ? 20 : 24);
        final double fontSizeTitle = isMobile ? 10 : (isTablet ? 11 : 12);
        final double borderRadius = isMobile ? 12 : (isTablet ? 14 : 16);
        
        return Container(
          width: cardWidth,
          margin: const EdgeInsets.only(right: 8),
          padding: EdgeInsets.all(paddingCard),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: isMobile
              ? _buildMobileStatCard(value, title, icon, color, fontSizeValue, fontSizeTitle)
              : _buildDesktopStatCard(value, title, icon, color, fontSizeValue, fontSizeTitle, iconSize),
        );
      },
    );
  }

  // 🔥 MOBILE VERSION (Vertical Layout)
  Widget _buildMobileStatCard(
    String value,
    String title,
    IconData icon,
    Color color,
    double fontSizeValue,
    double fontSizeTitle,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Icon
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(height: 4),
        // Value
        Text(
          value,
          style: TextStyle(
            fontSize: fontSizeValue,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        // Title
        Text(
          title,
          style: TextStyle(
            fontSize: fontSizeTitle,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // 🔥 DESKTOP/TABLET VERSION (Horizontal Layout)
  Widget _buildDesktopStatCard(
    String value,
    String title,
    IconData icon,
    Color color,
    double fontSizeValue,
    double fontSizeTitle,
    double iconSize,
  ) {
    return Row(
      children: [
        // Icon
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: iconSize,
          ),
        ),
        const SizedBox(width: 10),
        // Text
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: fontSizeValue,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: fontSizeTitle,
                  color: Colors.grey[600],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }


  // 🔥 TABEL USER DENGAN PAGINATION
  Widget _buildUserTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '👥 Daftar User',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: _loadStatistics,
                  tooltip: 'Refresh',
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Total: ${_users.length}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // 🔥 TABLE USER
        Container(
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
              color: Colors.grey.shade200,
            ),
          ),
          child: Column(
            children: [
              // 🔥 HEADER TABLE
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: const Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        'No',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        'Nama',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        'Email',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Role',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Kelas',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // 🔥 LIST USER
              _isLoadingUsers
                  ? const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : _users.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(
                            child: Text(
                              'Belum ada user',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      : Column(
                          children: _users
                              .skip((_currentPage - 1) * _pageSize)
                              .take(_pageSize)
                              .map((user) => _buildUserRow(user))
                              .toList(),
                        ),
              
              // 🔥 PAGINATION
              if (_users.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Menampilkan ${((_currentPage - 1) * _pageSize) + 1} - ${_currentPage * _pageSize > _users.length ? _users.length : _currentPage * _pageSize} dari ${_users.length}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left, size: 20),
                            onPressed: _currentPage > 1
                                ? () {
                                    setState(() {
                                      _currentPage--;
                                    });
                                  }
                                : null,
                            constraints: const BoxConstraints(
                              minWidth: 30,
                              minHeight: 30,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '$_currentPage / ${_totalPages}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right, size: 20),
                            onPressed: _currentPage < _totalPages
                                ? () {
                                    setState(() {
                                      _currentPage++;
                                    });
                                  }
                                : null,
                            constraints: const BoxConstraints(
                              minWidth: 30,
                              minHeight: 30,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // 🔥 ROW USER
  Widget _buildUserRow(Map<String, dynamic> user) {
    // 🔥 Warna role
    Color roleColor;
    IconData roleIcon;
    switch (user['role']) {
      case 'admin':
        roleColor = Colors.red;
        roleIcon = Icons.admin_panel_settings;
        break;
      case 'guru':
        roleColor = Colors.orange;
        roleIcon = Icons.person;
        break;
      case 'siswa':
        roleColor = Colors.green;
        roleIcon = Icons.school;
        break;
      case 'walimurid':
        roleColor = Colors.purple;
        roleIcon = Icons.family_restroom;
        break;
      default:
        roleColor = Colors.grey;
        roleIcon = Icons.person_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              '${_users.indexOf(user) + 1}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: roleColor.withOpacity(0.1),
                  child: Icon(
                    roleIcon,
                    size: 14,
                    color: roleColor,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    user['nama'] ?? '-',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              user['email'] ?? '-',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: roleColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                user['role'] ?? 'user',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: roleColor,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              user['kelas'] ?? '-',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
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
          'Dashboard Admin',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 1, 155, 129),
        foregroundColor: Colors.white,
        toolbarHeight: 45,
        elevation: 4,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromARGB(255, 26, 126, 121),
                Color.fromARGB(255, 13, 144, 161),
                Color.fromARGB(255, 66, 218, 245),
              ],
              stops: [0.0, 0.5, 1.0],
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
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔥 WELCOME CARD
                  _buildWelcomeCard(),
                  
                  const SizedBox(height: 24),
                  
                  // 🔥 STATISTICS - INFographic
                  _buildStatisticsSection(),
                  
                  const SizedBox(height: 24),
                  
                  // 🔥 USER TABLE
                  _buildUserTable(),
                  
                  const SizedBox(height: 24),
                  
                  // 🔥 QUICK ACTIONS
                  _buildQuickActionsSection(),
                ],
              ),
            ),
      
    );
  }

  // 🔥 WELCOME CARD
  Widget _buildWelcomeCard() {
    return Container(

      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          //gradient: const LinearGradient(
           // begin: Alignment.topLeft,
           // end: Alignment.bottomRight,
            //colors: [
             // Color.fromARGB(255, 26, 126, 121),
             // Color.fromARGB(255, 19, 207, 231),
            //],
         // ),
         // borderRadius: BorderRadius.circular(12),
         
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundColor: Color.fromARGB(255, 2, 235, 215),
              child: Icon(
                Icons.admin_panel_settings,
                color: Color.fromARGB(255, 1, 155, 129),
                size: 25,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selamat Datang,',
                    style: TextStyle(
                      color: const Color.fromARGB(255, 1, 114, 129).withOpacity(0.8),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _adminData?['nama'] ?? 'Admin',
                    style: const TextStyle(
                      color: Color.fromARGB(255, 2, 198, 233),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _adminData?['email'] ?? '',
                    style: TextStyle(
                      color: Color.fromARGB(255, 1, 114, 129).withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  // 🔥 QUICK ACTIONS SECTION
  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Akses Cepat',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
          children: [
            _buildActionCard(
              'Kelola User',
              Icons.people,
              Colors.blue,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CrudUserPage(),
                  ),
                );
              },
            ),
            _buildActionCard(
              'Kelola Guru',
              Icons.person,
              Colors.orange,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const GuruPage(),
                  ),
                );
              },
            ),
            _buildActionCard(
              'Kelola Siswa',
              Icons.school,
              Colors.green,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SiswaPage(),
                  ),
                );
              },
            ),
            _buildActionCard(
              'Wali Siswa',
              Icons.family_restroom,
              Colors.purple,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const WaliSiswaPage(),
                  ),
                );
              },
            ),
            _buildActionCard(
              'Keuangan',
              Icons.attach_money,
              Colors.teal,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CrudKeuanganPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
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
              Color.fromARGB(255, 26, 126, 121),
              Color.fromARGB(255, 13, 144, 161),
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
                  // KOLOM 1: ICON
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings,
                      color: Color.fromARGB(255, 1, 155, 129),
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // KOLOM 2: TEXT
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _adminData?['nama'] ?? 'Admin',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Admin',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          _adminData?['email'] ?? '',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // MENU ITEMS
            _buildDrawerItem(
              icon: Icons.dashboard,
              title: 'Dashboard',
              color: Colors.white,
              onTap: () => Navigator.pop(context),
            ),
            const Divider(color: Colors.white24, thickness: 1),
            _buildDrawerItem(
              icon: Icons.people,
              title: 'Kelola User',
              color: Colors.blue,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CrudUserPage()),
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.person,
              title: 'Kelola Guru',
              color: Colors.orange,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GuruPage()),
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.school,
              title: 'Kelola Siswa',
              color: Colors.green,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SiswaPage()),
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.family_restroom,
              title: 'Wali Siswa',
              color: Colors.purple,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WaliSiswaPage()),
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.attach_money,
              title: 'Keuangan',
              color: Colors.teal,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CrudKeuanganPage()),
                );
              },
            ),
            const Divider(color: Colors.white24, thickness: 1),
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

  // 🔥 ACTION CARD
  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
     final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

// 🔥 PAGE SISWA (UNTUK NAVIGASI)
class SiswaPage extends StatelessWidget {
  const SiswaPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Siswa', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 1, 155, 129),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const Center(child: Text('Halaman Kelola Siswa')),
    );
  }
}