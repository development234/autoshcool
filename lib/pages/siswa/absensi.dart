// lib/pages/siswa/absensi.dart
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import '../../services/supabase_service.dart';

class AbsensiPage extends StatefulWidget {
  const AbsensiPage({super.key});

  @override
  State<AbsensiPage> createState() => _AbsensiPageState();
}

class _AbsensiPageState extends State<AbsensiPage> {
  final SupabaseService _service = SupabaseService();
  List<Map<String, dynamic>> _absensi = [];
  List<Map<String, dynamic>> _filteredAbsensi = [];
  bool _isLoading = true;
  String? _siswaId;
  String _selectedMonth = DateFormat('MM').format(DateTime.now());
  String _selectedYear = DateFormat('yyyy').format(DateTime.now());
  Map<String, int> _statistik = {};
  String _debugInfo = '';

  // List bulan
  final List<String> _months = [
    '01', '02', '03', '04', '05', '06',
    '07', '08', '09', '10', '11', '12'
  ];
  final List<String> _monthNames = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  // List tahun (5 tahun terakhir)
  List<String> _years = [];

  @override
  void initState() {
    super.initState();
    _generateYears();
    _loadData();
  }

  void _generateYears() {
    final currentYear = DateTime.now().year;
    _years = List.generate(5, (index) => (currentYear - index).toString());
  }

  Future<void> _loadData() async {
    try {
      final user = _service.getCurrentUser();
      print('🔍 Current user: ${user?.email ?? 'null'}');
      
      if (user != null) {
        _siswaId = user.id;
        print('✅ Siswa ID: $_siswaId');
        await _loadAbsensi();
      } else {
        // Coba ambil dari database langsung
        print('⚠️ No current user, trying to get from database...');
        setState(() {
          _debugInfo = 'Silakan login terlebih dahulu';
          _isLoading = false;
        });
        Fluttertoast.showToast(msg: 'Silakan login terlebih dahulu');
      }
    } catch (e) {
      print('❌ Error loading data: $e');
      setState(() {
        _debugInfo = 'Error: $e';
        _isLoading = false;
      });
      Fluttertoast.showToast(msg: 'Error: $e');
    }
  }

  Future<void> _loadAbsensi() async {
    if (_siswaId == null) {
      print('❌ Siswa ID is null');
      setState(() {
        _isLoading = false;
        _debugInfo = 'Siswa ID tidak ditemukan';
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      print('📊 Fetching absensi for siswa: $_siswaId');
      
      // Ambil semua data absensi siswa tanpa filter
      final data = await _service.getDataWithFilter(
        'absensi',
        filters: {'siswa_id': _siswaId},
        orderBy: 'tanggal',
        ascending: false,
      );
      
      print('✅ Total absensi fetched: ${data.length}');
      
      if (data.isNotEmpty) {
        print('📊 Sample data: ${data.first}');
      }
      
      setState(() {
        _absensi = data;
        _filterByMonthYear();
        _hitungStatistik(_filteredAbsensi);
        _isLoading = false;
        _debugInfo = 'Total data: ${data.length}, Filtered: ${_filteredAbsensi.length}';
      });
      
    } catch (e) {
      print('❌ Error loading absensi: $e');
      setState(() {
        _isLoading = false;
        _debugInfo = 'Error: $e';
      });
      Fluttertoast.showToast(msg: 'Gagal memuat absensi: $e');
    }
  }

  void _filterByMonthYear() {
    if (_absensi.isEmpty) {
      print('⚠️ No absensi data to filter');
      setState(() {
        _filteredAbsensi = [];
        _hitungStatistik([]);
      });
      return;
    }
    
    print('🔍 Filtering data for month: $_selectedMonth, year: $_selectedYear');
    
    _filteredAbsensi = _absensi.where((item) {
      final tanggal = item['tanggal']?.toString() ?? '';
      if (tanggal.isEmpty) {
        print('⚠️ Empty tanggal in item: $item');
        return false;
      }
      
      try {
        // Parse tanggal dengan format yang benar
        DateTime date;
        if (tanggal.contains('T')) {
          date = DateTime.parse(tanggal);
        } else {
          date = DateTime.parse('$tanggal 00:00:00');
        }
        
        final month = DateFormat('MM').format(date);
        final year = DateFormat('yyyy').format(date);
        
        final match = month == _selectedMonth && year == _selectedYear;
        if (match) {
          print('✅ Match: $tanggal -> $year-$month');
        }
        return match;
      } catch (e) {
        print('❌ Error parsing date: $tanggal, error: $e');
        return false;
      }
    }).toList();
    
    print('📊 Filtered data: ${_filteredAbsensi.length}');
    
    if (_filteredAbsensi.isNotEmpty) {
      print('📊 First filtered: ${_filteredAbsensi.first}');
    }
    
    _hitungStatistik(_filteredAbsensi);
  }

  void _hitungStatistik(List<Map<String, dynamic>> data) {
    _statistik = {
      'hadir': 0,
      'izin': 0,
      'sakit': 0,
      'alpha': 0,
    };
    
    for (var item in data) {
      final status = item['status']?.toString().toLowerCase() ?? 'alpha';
      if (_statistik.containsKey(status)) {
        _statistik[status] = (_statistik[status] ?? 0) + 1;
      }
    }
    
    print('📊 Statistics: $_statistik');
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'hadir':
        return Colors.green;
      case 'izin':
        return Colors.orange;
      case 'sakit':
        return Colors.blue;
      case 'alpha':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'hadir':
        return 'Hadir';
      case 'izin':
        return 'Izin';
      case 'sakit':
        return 'Sakit';
      case 'alpha':
        return 'Alpha';
      default:
        return 'Tidak Diketahui';
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'hadir':
        return Icons.check_circle;
      case 'izin':
        return Icons.event_note;
      case 'sakit':
        return Icons.healing;
      case 'alpha':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  String _getDayName(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
      return days[date.weekday - 1];
    } catch (e) {
      return '';
    }
  }

  int _getDayNumber(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return date.day;
    } catch (e) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Absensi', style: TextStyle(fontSize: 14),),
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
            icon: const Icon(Icons.refresh),
            onPressed: _loadAbsensi,
          ),
        ],
      ),
      body: Column(
        children: [
          // Debug Info (untuk membantu debugging)
          if (_debugInfo.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.yellow[100],
              child: Text(
                _debugInfo,
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          
          // Filter Bulan dan Tahun
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey[50],
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedMonth,
                    decoration: InputDecoration(
                      labelText: 'Bulan',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    items: _months.asMap().entries.map((entry) {
                      int index = entry.key;
                      String month = entry.value;
                      return DropdownMenuItem(
                        value: month,
                        child: Text(_monthNames[index]),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedMonth = value;
                          _filterByMonthYear();
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedYear,
                    decoration: InputDecoration(
                      labelText: 'Tahun',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    items: _years.map((year) {
                      return DropdownMenuItem(
                        value: year,
                        child: Text(year),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedYear = value;
                          _filterByMonthYear();
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Statistik
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatistikItem('Hadir', _statistik['hadir'] ?? 0, Colors.green),
                _buildStatistikItem('Izin', _statistik['izin'] ?? 0, Colors.orange),
                _buildStatistikItem('Sakit', _statistik['sakit'] ?? 0, Colors.blue),
                _buildStatistikItem('Alpha', _statistik['alpha'] ?? 0, Colors.red),
              ],
            ),
          ),
          
          // Info bulan
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.blue.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bulan: ${_monthNames[int.parse(_selectedMonth) - 1]} $_selectedYear',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Total: ${_filteredAbsensi.length} hari',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // List absensi
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredAbsensi.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Belum ada data absensi',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Untuk bulan ${_monthNames[int.parse(_selectedMonth) - 1]} $_selectedYear',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[400],
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Tombol reload untuk debugging
                            ElevatedButton.icon(
                              onPressed: _loadAbsensi,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Muat Ulang'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredAbsensi.length,
                        itemBuilder: (context, index) {
                          final item = _filteredAbsensi[index];
                          final status = item['status']?.toString().toLowerCase() ?? 'alpha';
                          final statusColor = _getStatusColor(status);
                          final tanggal = item['tanggal']?.toString() ?? '';
                          final dayName = _getDayName(tanggal);
                          final dayNumber = _getDayNumber(tanggal);

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  left: BorderSide(
                                    color: statusColor,
                                    width: 4,
                                  ),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    // Tanggal
                                    Container(
                                      width: 50,
                                      child: Column(
                                        children: [
                                          Text(
                                            dayNumber.toString(),
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            dayName,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    // Status
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        _getStatusIcon(status),
                                        color: statusColor,
                                        size: 30,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    // Info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            tanggal.isNotEmpty ? 
                                                DateFormat('EEEE, d MMMM yyyy', 'id_ID')
                                                    .format(DateTime.parse(tanggal)) 
                                                : 'Tanggal tidak tersedia',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: statusColor,
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  _getStatusText(status),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              if (item['keterangan'] != null && 
                                                  item['keterangan'].toString().isNotEmpty) ...[
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    item['keterangan'],
                                                    style: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontSize: 12,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.chevron_right,
                                      color: Colors.grey[400],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistikItem(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}