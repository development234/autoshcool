// lib/pages/admin/crud_user.dart
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../services/supabase_service.dart';

class CrudUserPage extends StatefulWidget {
  const CrudUserPage({super.key});

  @override
  State<CrudUserPage> createState() => _CrudUserPageState();
}

class _CrudUserPageState extends State<CrudUserPage> {
  final SupabaseService _service = SupabaseService();
  
  // 🔥 DATA
  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  bool _isLoading = true;
  
  // 🔥 PAGINATION
  int _currentPage = 1;
  final int _pageSize = 15;
  
  // 🔥 FILTER
  String _searchQuery = '';
  String _selectedRole = 'Semua';
  final List<String> _roleOptions = ['Semua', 'siswa', 'guru', 'walimurid', 'admin'];
  
  // 🔥 GETTER
  int get _totalPages => _filteredUsers.isEmpty ? 1 : (_filteredUsers.length / _pageSize).ceil();
  List<Map<String, dynamic>> get _paginatedUsers {
    final start = (_currentPage - 1) * _pageSize;
    final end = start + _pageSize;
    if (start >= _filteredUsers.length) return [];
    return _filteredUsers.sublist(start, end > _filteredUsers.length ? _filteredUsers.length : end);
  }

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  // 🔥 LOAD USERS
  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await _service.getAllUsers();
      setState(() {
        _allUsers = users;
        _filteredUsers = users;
        _isLoading = false;
        _currentPage = 1;
      });
      print('✅ Loaded ${users.length} users');
    } catch (e) {
      print('❌ Error loading users: $e');
      setState(() => _isLoading = false);
      Fluttertoast.showToast(msg: 'Gagal memuat data user');
    }
  }

  // 🔥 FILTER USERS
  void _filterUsers() {
    setState(() {
      _filteredUsers = _allUsers.where((user) {
        final nama = (user['nama'] ?? '').toLowerCase();
        final email = (user['email'] ?? '').toLowerCase();
        final kelas = (user['kelas'] ?? '').toLowerCase();
        final role = user['role'] ?? '';
        final query = _searchQuery.toLowerCase();
        
        // Filter by role
        if (_selectedRole != 'Semua' && role != _selectedRole) {
          return false;
        }
        
        // Filter by search query
        if (query.isNotEmpty) {
          return nama.contains(query) || 
                 email.contains(query) || 
                 kelas.contains(query);
        }
        
        return true;
      }).toList();
      _currentPage = 1;
    });
  }
  
  Future<void> _deleteUser(String userId, String nama) async {
    
    if (userId == null || userId.isEmpty || userId == 'null') {
      Fluttertoast.showToast(msg: 'ID user tidak valid');
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus user "$nama"?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                // 🔥 PAKAI deleteUser ATAU deleteData
                await _service.deleteUser(userId);
                // Atau: await _service.deleteData('users', userId);
                
                Fluttertoast.showToast(
                  msg: 'User berhasil dihapus',
                  backgroundColor: Colors.green,
                  textColor: Colors.white,
                );
                await _loadUsers();
              } catch (e) {
                Fluttertoast.showToast(
                  msg: 'Gagal menghapus user: $e',
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  // 🔥 SHOW USER DETAIL
  void _showUserDetail(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(20),
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person,
                      color: Colors.blue.shade700,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user['nama'] ?? 'User',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          user['role'] ?? 'user',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              _buildDetailRow('Email', user['email'] ?? '-'),
              _buildDetailRow('Role', user['role'] ?? '-'),
              _buildDetailRow('Kelas', user['kelas'] ?? '-'),
              _buildDetailRow('NIS', user['nis'] ?? '-'),
              _buildDetailRow('NIP', user['nip'] ?? '-'),
              _buildDetailRow('ID', user['id'] ?? '-'),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Tutup'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 EDIT USER (SEDERHANA)
  void _editUser(Map<String, dynamic> user) {
    // TODO: Implement edit user page
    Fluttertoast.showToast(msg: 'Fitur edit user sedang dalam pengembangan');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manajemen User',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 1, 155, 129),
        foregroundColor: Colors.white,
        elevation: 4,
        centerTitle: true,
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadUsers,
          ),
        ],
      ),
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
        child: Column(
          children: [
            // 🔥 BARIS 1: HEADER
            _buildHeader(),
            
            // 🔥 BARIS 2: FILTER
            _buildFilterSection(),
            
            // 🔥 BARIS 3: TABEL
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredUsers.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.people_outline, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'Tidak ada data user',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : _buildUserTable(),
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 BARIS 1: HEADER
  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        //color: Colors.white,
        //borderEnd: BorderBot.circular(12),
        
       
        //border: Border.bottom(
        //  color: const Color.fromARGB(255, 1, 155, 129).withOpacity(0.2),
       // ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 1, 155, 129).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.people,
              size: 28,
              color: Color.fromARGB(255, 1, 155, 129),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Data User',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 1, 155, 129),
                  ),
                ),
                Text(
                  _formatDate(DateTime.now()),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Total: ${_filteredUsers.length}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  // 🔥 BARIS 2: FILTER
  Widget _buildFilterSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
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
      child: Row(
        children: [
          // 🔥 SEARCH
          Expanded(
            flex: 3,
            child: TextField(
              decoration: InputDecoration(
                hintText: '🔍 Cari nama, email, kelas...',
                hintStyle: TextStyle(fontSize: 12, color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color.fromARGB(255, 1, 155, 129)),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                isDense: true,
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                          _filterUsers();
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                _filterUsers();
              },
            ),
          ),
          const SizedBox(width: 10),
          
          // 🔥 ROLE FILTER
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<String>(
              value: _selectedRole,
              decoration: InputDecoration(
                hintText: 'Role',
                hintStyle: TextStyle(fontSize: 12, color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color.fromARGB(255, 1, 155, 129)),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                isDense: true,
              ),
              items: _roleOptions.map((role) {
                return DropdownMenuItem(
                  value: role,
                  child: Text(
                    role,
                    style: TextStyle(fontSize: 12),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedRole = value!;
                });
                _filterUsers();
              },
            ),
          ),
          
        ],
      ),
      
    );
    
  }


 // 🔥 BARIS 3: TABEL USER - FULLY RESPONSIVE
Widget _buildUserTable() {
  final paginatedData = _paginatedUsers;
  
  return LayoutBuilder(
    builder: (context, constraints) {
      // 🔥 DETEKSI UKURAN LAYAR
      final screenWidth = constraints.maxWidth;
      final isMobile = screenWidth < 600;
      final isTablet = screenWidth >= 600 && screenWidth < 900;
      final isDesktop = screenWidth >= 900;
      
      // 🔥 LEBAR KOLOM RESPONSIVE
      final double noWidth = isMobile ? 30 : 40;
      final double namaWidth = isMobile ? 80 : (isTablet ? 120 : 150);
      final double emailWidth = isMobile ? 120 : (isTablet ? 150 : 200);
      final double roleWidth = isMobile ? 60 : (isTablet ? 70 : 80);
      final double kelasWidth = isMobile ? 50 : (isTablet ? 60 : 80);
      final double aksiWidth = isMobile ? 90 : (isTablet ? 100 : 120);
      
      // 🔥 TOTAL LEBAR TABEL
      final double totalWidth = noWidth + namaWidth + emailWidth + roleWidth + kelasWidth + aksiWidth + 40; // + spacing
      
      // 🔥 APAKAH PERLU SCROLL?
      final bool needScroll = totalWidth > screenWidth - 24;
      
      return Column(
        children: [
          // 🔥 TABLE
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
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
              child: needScroll
                  ? SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: totalWidth,
                        child: _buildTableContent(paginatedData, noWidth, namaWidth, emailWidth, roleWidth, kelasWidth, aksiWidth),
                      ),
                    )
                  : _buildTableContent(paginatedData, noWidth, namaWidth, emailWidth, roleWidth, kelasWidth, aksiWidth),
            ),
          ),
          
          // 🔥 PAGINATION
          if (_filteredUsers.length > _pageSize)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 🔥 INFO HALAMAN (Sembunyikan di mobile)
                  if (!isMobile)
                    Text(
                      '${((_currentPage - 1) * _pageSize) + 1} - ${_currentPage * _pageSize > _filteredUsers.length ? _filteredUsers.length : _currentPage * _pageSize} dari ${_filteredUsers.length}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  if (isMobile) const Spacer(),
                  
                  // 🔥 TOMBOL PAGINATION
                  Row(
                    children: [
                      // Tombol Previous
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _currentPage > 1 ? Colors.blue : Colors.grey.shade300,
                          ),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.chevron_left,
                            size: isMobile ? 18 : 20,
                            color: _currentPage > 1 ? Colors.blue : Colors.grey.shade400,
                          ),
                          onPressed: _currentPage > 1
                              ? () => setState(() => _currentPage--)
                              : null,
                          constraints: BoxConstraints(
                            minWidth: isMobile ? 28 : 30,
                            minHeight: isMobile ? 28 : 30,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                      
                      // 🔥 INFORMASI HALAMAN (Mobile: compact)
                      if (isMobile)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '$_currentPage/$_totalPages',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '$_currentPage / $_totalPages',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      
                      // Tombol Next
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _currentPage < _totalPages ? Colors.blue : Colors.grey.shade300,
                          ),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.chevron_right,
                            size: isMobile ? 18 : 20,
                            color: _currentPage < _totalPages ? Colors.blue : Colors.grey.shade400,
                          ),
                          onPressed: _currentPage < _totalPages
                              ? () => setState(() => _currentPage++)
                              : null,
                          constraints: BoxConstraints(
                            minWidth: isMobile ? 28 : 30,
                            minHeight: isMobile ? 28 : 30,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      );
    },
  );
}

  // 🔥 BUILD TABLE CONTENT
  Widget _buildTableContent(
    List<Map<String, dynamic>> paginatedData,
    double noWidth,
    double namaWidth,
    double emailWidth,
    double roleWidth,
    double kelasWidth,
    double aksiWidth,
  ) {
    return Column(
      children: [
        // 🔥 HEADER
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
          child: Row(
            children: [
              // No
              SizedBox(
                width: noWidth,
                child: Text(
                  'No',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  textAlign: TextAlign.right,
                ),
              ),
              const SizedBox(width: 4),
              // Nama
              SizedBox(
                width: namaWidth,
                child: Text(
                  'Nama',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  textAlign: TextAlign.right,
                ),
              ),
              const SizedBox(width: 4),
              // Email
              SizedBox(
                width: emailWidth,
                child: Text(
                  'Email',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  textAlign: TextAlign.right,
                ),
              ),
              const SizedBox(width: 4),
              // Role
              SizedBox(
                width: roleWidth,
                child: Text(
                  'Role',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  textAlign: TextAlign.right,
                ),
              ),
              const SizedBox(width: 4),
              // Kelas
              SizedBox(
                width: kelasWidth,
                child: Text(
                  'Kelas',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  textAlign: TextAlign.right,
                ),
              ),
              const SizedBox(width: 4),
              // Aksi
              SizedBox(
                width: aksiWidth,
                child: Text(
                  'Aksi',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        
        // 🔥 DATA
        paginatedData.isEmpty
            ? SizedBox(
                height: 200,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('Tidak ada data'),
                    ],
                  ),
                ),
              )
            : Column(
                children: paginatedData.map((user) {
                  final realIndex = ((_currentPage - 1) * _pageSize) + paginatedData.indexOf(user) + 1;
                  return _buildUserRow(
                    user,
                    realIndex,
                    noWidth,
                    namaWidth,
                    emailWidth,
                    roleWidth,
                    kelasWidth,
                    aksiWidth,
                  );
                }).toList(),
              ),
      ],
    );
  }

  // 🔥 ROW USER - RESPONSIVE
  Widget _buildUserRow(
    Map<String, dynamic> user,
    int index,
    double noWidth,
    double namaWidth,
    double emailWidth,
    double roleWidth,
    double kelasWidth,
    double aksiWidth,
  ) {
    // 🔥 ROLE COLOR
    Color roleColor;
    switch (user['role']) {
      case 'admin':
        roleColor = Colors.red;
        break;
      case 'guru':
        roleColor = Colors.orange;
        break;
      case 'siswa':
        roleColor = Colors.green;
        break;
      case 'walimurid':
        roleColor = Colors.purple;
        break;
      default:
        roleColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100),
        ),
      ),
      child: Row(
        children: [
          // 🔥 No
          SizedBox(
            width: noWidth,
            child: Text(
              '$index',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 4),
          
          // 🔥 Nama
          SizedBox(
            width: namaWidth,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    user['nama'] ?? '-',
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(width: 4),
                CircleAvatar(
                  radius: 12,
                  backgroundColor: roleColor.withOpacity(0.1),
                  child: Text(
                    (user['nama'] ?? 'U')[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: roleColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          
          // 🔥 Email
          SizedBox(
            width: emailWidth,
            child: Text(
              user['email'] ?? '-',
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 4),
          
          // 🔥 Role
          SizedBox(
            width: roleWidth,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: roleColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                user['role'] ?? 'user',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: roleColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          
          // 🔥 Kelas
          SizedBox(
            width: kelasWidth,
            child: Text(
              user['kelas'] ?? '-',
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 4),
          
          // 🔥 Aksi
          SizedBox(
            width: aksiWidth,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // LIHAT
                IconButton(
                  icon: const Icon(Icons.visibility, size: 18, color: Colors.blue),
                  onPressed: () => _showUserDetail(user),
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  padding: EdgeInsets.zero,
                  tooltip: 'Lihat Detail',
                ),
                // EDIT
                IconButton(
                  icon: const Icon(Icons.edit, size: 18, color: Colors.orange),
                  onPressed: () => _editUser(user),
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  padding: EdgeInsets.zero,
                  tooltip: 'Edit User',
                ),
                // HAPUS
                IconButton(
                  icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                  onPressed: () => _deleteUser(user['id'], user['nama'] ?? 'User'),
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  padding: EdgeInsets.zero,
                  tooltip: 'Hapus User',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


}