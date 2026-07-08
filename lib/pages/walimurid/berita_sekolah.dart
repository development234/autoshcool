// lib/pages/walimurid/berita_sekolah.dart
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../services/supabase_service.dart';

class BeritaSekolahPage extends StatefulWidget {
  const BeritaSekolahPage({super.key});

  @override
  State<BeritaSekolahPage> createState() => _BeritaSekolahPageState();
}

class _BeritaSekolahPageState extends State<BeritaSekolahPage> {
  final SupabaseService _service = SupabaseService();
  List<Map<String, dynamic>> _berita = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBerita();
  }

  // 🔥 LOAD BERITA - MENGGUNAKAN METHOD getAllBerita
  Future<void> _loadBerita() async {
    setState(() => _isLoading = true);
    try {
      print('📰 Loading berita...');
      
      // 🔥 Gunakan method getAllBerita
      final data = await _service.getAllBerita();
      
      setState(() {
        _berita = data;
        _isLoading = false;
      });
      
      print('✅ Berita loaded: ${_berita.length} items');
      
    } catch (e) {
      print('❌ Error loading berita: $e');
      setState(() => _isLoading = false);
      
      //FALLBACK: Gunakan data dummy jika error
      _useDummyData();
    }
  }

  // 🔥 FALLBACK DATA DUMMY
  void _useDummyData() {
    print('📰 Using dummy data...');
    final dummyData = [
      {
        'id': '1',
        'judul': 'Upacara Bendera Peringatan HUT RI ke-80',
        'deskripsi': 'Sekolah mengadakan upacara bendera dalam rangka memperingati Hari Kemerdekaan Republik Indonesia yang ke-79. Seluruh siswa, guru, dan staf diwajibkan mengikuti upacara dengan pakaian seragam lengkap.',
        'foto': 'https://picsum.photos/seed/berita1/400/200',
        'tanggal': '2026-08-17',
      },
      {
        'id': '2',
        'judul': 'Pengumuman Hasil Ujian Semester Ganjil',
        'deskripsi': 'Hasil ujian semester ganjil telah diumumkan. Siswa dapat melihat nilai melalui portal sekolah atau menghubungi wali kelas masing-masing. Pengambilan rapor akan dilaksanakan pada tanggal 20 Desember 2026.',
        'foto': 'https://picsum.photos/seed/berita2/400/200',
        'tanggal': '2026-12-15',
      },
      {
        'id': '3',
        'judul': 'Kegiatan Ekstrakurikuler Baru: Robotik',
        'deskripsi': 'Sekolah membuka ekstrakurikuler baru yaitu Robotik. Kegiatan ini akan diadakan setiap hari Sabtu pukul 09.00-12.00. Pendaftaran dibuka hingga 31 Januari 2026.',
        'foto': 'https://picsum.photos/seed/berita3/400/200',
        'tanggal': '2026-01-10',
      },
      {
        'id': '4',
        'judul': 'Lomba Cerdas Cermat Tingkat Kota',
        'deskripsi': 'Tim Cerdas Cermat sekolah berhasil meraih juara 2 dalam lomba tingkat kota. Selamat kepada tim yang telah berjuang dan mengharumkan nama sekolah.',
        'foto': 'https://picsum.photos/seed/berita4/400/200',
        'tanggal': '2026-02-20',
      },
      {
        'id': '5',
        'judul': 'Peringatan Hari Guru Nasional',
        'deskripsi': 'Sekolah mengadakan acara peringatan Hari Guru Nasional. Acara akan diisi dengan pentas seni, pemberian penghargaan untuk guru teladan, dan ramah tamah.',
        'foto': 'https://picsum.photos/seed/berita5/400/200',
        'tanggal': '2026-11-25',
      },
 
    ];
    
    setState(() {
      _berita = dummyData;
      _isLoading = false;
    });
    Fluttertoast.showToast(msg: 'Menggunakan data contoh');
  }

  String _formatTanggal(String? tanggal) {
    if (tanggal == null) return '-';
    try {
      final date = DateTime.parse(tanggal);
      final bulan = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
      return '${date.day} ${bulan[date.month - 1]} ${date.year}';
    } catch (e) {
      return tanggal;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Berita Sekolah',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
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
                Color(0xFF1B969A),
                Color.fromRGBO(39, 155, 176, 1),
                Color.fromARGB(255, 147, 216, 210),
              ],
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
            onPressed: _loadBerita,
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _berita.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.newspaper, size: 80, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada berita',
                          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Data berita akan segera ditambahkan',
                          style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // BARIS 1: HEADER
                        Container(
                          padding: const EdgeInsets.all(16),
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
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                //decoration: BoxDecoration(
                                //  color: const Color.fromARGB(94, 146, 241, 226).withOpacity(0.1),
                                //  borderRadius: BorderRadius.circular(12),
                                //),
                                child: const Icon(
                                  Icons.newspaper,
                                  size: 35,
                                  color: Color.fromARGB(255, 1, 155, 129),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Halaman Berita Sekolah',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(255, 1, 155, 129),
                                      ),
                                    ),
                                    const SizedBox(height: 1),
                                    Text(
                                      _formatTanggal(DateTime.now().toIso8601String()),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 12),

                        // BARIS 2: HEADLINE NEWS
                        if (_berita.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(16),
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
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: _berita[0]['foto'] != null && _berita[0]['foto'].toString().isNotEmpty
                                        ? Image.network(
                                            _berita[0]['foto'],
                                            height: 120,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Container(
                                              height: 120,
                                              color: Colors.grey.shade200,
                                              child: const Icon(
                                                Icons.image_not_supported,
                                                size: 40,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          )
                                        : Container(
                                            height: 120,
                                            color: const Color.fromARGB(255, 1, 155, 129).withOpacity(0.1),
                                            child: const Icon(
                                              Icons.newspaper,
                                              size: 40,
                                              color: Color.fromARGB(255, 1, 155, 129),
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _berita[0]['judul'] ?? 'Berita Terkini',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromARGB(255, 1, 155, 129),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _formatTanggal(_berita[0]['tanggal']),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        _berita[0]['deskripsi'] ?? '',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[700],
                                        ),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      TextButton(
                                        onPressed: () {
                                          _showDetailBerita(context, _berita[0]);
                                        },
                                        style: TextButton.styleFrom(
                                          foregroundColor: const Color.fromARGB(255, 1, 155, 129),
                                          padding: EdgeInsets.zero,
                                        ),
                                        child: const Text(
                                          'Baca Selengkapnya →',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 16),

                        // BARIS 3: LIST BERITA LAINNYA
                        const Text(
                          'Berita Lainnya',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 1, 155, 129),
                          ),
                        ),
                        const SizedBox(height: 8),

                        ...(_berita.length > 1 ? _berita.skip(1).toList() : []).map((item) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
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
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: item['foto'] != null && item['foto'].toString().isNotEmpty
                                      ? Image.network(
                                          item['foto'],
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(
                                            width: 80,
                                            height: 80,
                                            color: Colors.grey.shade200,
                                            child: const Icon(
                                              Icons.image_not_supported,
                                              size: 30,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        )
                                      : Container(
                                          width: 80,
                                          height: 80,
                                          color: const Color.fromARGB(255, 1, 155, 129).withOpacity(0.1),
                                          child: const Icon(
                                            Icons.newspaper,
                                            size: 30,
                                            color: Color.fromARGB(255, 1, 155, 129),
                                          ),
                                        ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['judul'] ?? 'Berita',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromARGB(255, 1, 155, 129),
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _formatTanggal(item['tanggal']),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item['deskripsi'] ?? '',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[700],
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      TextButton(
                                        onPressed: () {
                                          _showDetailBerita(context, item);
                                        },
                                        style: TextButton.styleFrom(
                                          foregroundColor: const Color.fromARGB(255, 1, 155, 129),
                                          padding: EdgeInsets.zero,
                                          minimumSize: Size.zero,
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: const Text(
                                          'Baca →',
                                          style: TextStyle(fontSize: 11),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
      ),
    );
  }

  // DIALOG DETAIL BERITA
  void _showDetailBerita(BuildContext context, Map<String, dynamic> berita) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxHeight: 500),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: berita['foto'] != null && berita['foto'].toString().isNotEmpty
                    ? Image.network(
                        berita['foto'],
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 200,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.image_not_supported, size: 50),
                        ),
                      )
                    : Container(
                        height: 200,
                        color: const Color.fromARGB(255, 1, 155, 129).withOpacity(0.1),
                        child: const Icon(
                          Icons.newspaper,
                          size: 50,
                          color: Color.fromARGB(255, 1, 155, 129),
                        ),
                      ),
              ),
              const SizedBox(height: 16),
              Text(
                berita['judul'] ?? 'Berita',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 1, 155, 129),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatTanggal(berita['tanggal']),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    berita['deskripsi'] ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                      height: 1.6,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 1, 155, 129),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
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
}