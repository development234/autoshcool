import 'dart:convert';
import 'package:autoschool/models/user_model.dart';
import 'package:autoschool/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';


class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // LOGIN - SEDERHANA
  Future<UserModel?> signIn(String email, String password) async {
    try {
      print('🔐 Login: $email');
      
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        final userId = response.user!.id;
        final metadata = response.user!.userMetadata ?? {};
        
        print('✅ Login success! ID: $userId');
        
        final userModel = UserModel(
          id: userId,
          email: response.user!.email!,
          nama: metadata['nama'] ?? 'User',
          role: metadata['role'] ?? 'siswa',
          kelas: metadata['kelas'] ?? '-',
          nis: metadata['nis'] ?? '-',
          nip: metadata['nip'],
          foto: metadata['foto'],
          createdAt: DateTime.now(),
        );
        
        // Simpan ke tabel users
        try {
          await _supabase.from('users').upsert({
            'id': userId,
            'email': response.user!.email,
            'nama': metadata['nama'] ?? 'User',
            'role': metadata['role'] ?? 'siswa',
            'kelas': metadata['kelas'] ?? '-',
            'nis': metadata['nis'] ?? '-',
            'nip': metadata['nip'],
            'foto': metadata['foto'],
            'created_at': DateTime.now().toIso8601String(),
          });
          print('✅ User saved to database');
        } catch (e) {
          print('⚠️ Error saving: $e');
        }
        
        return userModel;
      } else {
        print('❌ Login failed: No user');
        return null;
      }
    } catch (e) {
      print('❌ Error: $e');
      throw Exception('Login gagal: $e');
    }
  }

  // 🔥 GET CURRENT USER
  User? getCurrentUser() {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        print('✅ Current user found: ${user.email}');
        return user;
      }
    } catch (e) {
      print('⚠️ Error getting user: $e');
    }
    print('❌ No current user');
    return null;
  }

  // 🔥 GET USER DATA BY ID
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      print('🔍 Get user data: $userId');
      
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();
      
      if (response != null) {
        print('✅ Data from table: ${response['nama']}');
        return response;
      }
      
      // Jika tidak ada, ambil dari auth
      final user = _supabase.auth.currentUser;
      if (user != null && user.id == userId) {
        final metadata = user.userMetadata ?? {};
        final data = {
          'id': user.id,
          'email': user.email,
          'nama': metadata['nama'] ?? 'User',
          'role': metadata['role'] ?? 'siswa',
          'kelas': metadata['kelas'] ?? '-',
          'nis': metadata['nis'] ?? '-',
          'nip': metadata['nip'],
          'foto': metadata['foto'],
        };
        
        try {
          await _supabase.from('users').upsert(data);
          print('✅ User data saved');
        } catch (e) {
          print('⚠️ Error saving: $e');
        }
        
        return data;
      }
      
      return null;
    } catch (e) {
      print('❌ Error: $e');
      return null;
    }
  }


  // 🔥 GET USER DATA DARI AUTH (PASTI BERHASIL)
  Map<String, dynamic>? getUserDataFromAuth() {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        print('❌ No user in auth');
        return null;
      }
      final metadata = user.userMetadata ?? {};
      
      return {
        'id': user.id,
        'email': user.email,
        'nama': metadata['nama'] ?? 'User',
        'role': metadata['role'] ?? 'siswa',
        'kelas': metadata['kelas'] ?? '-',
        'nis': metadata['nis'] ?? '-',
        'nip': metadata['nip'],
        'foto': metadata['foto'],
      };
    } catch (e) {
      print('❌ Error: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
    print('✅ Signed out');
  }

  //Future<dynamic> getDataWithFilter(String s, {required Map<String, String?> filters, required String orderBy, required bool ascending}) async {}

  Future<void> updateUserProfile(param0, Map<String, String> updates) async {}

  Future<dynamic> signUp(String text, String text2, UserModel user) async {}

  Future<List<Map<String, dynamic>>> getData(
    String table, {
      String? orderBy,
      bool ascending = false,
      Map<String, dynamic>? filters,
    }
  ) async {
    try {
      print('🔍 getData - Table: $table');
      
      var query = _supabase.from(table).select('*');
      
      // Tambahkan filter jika ada
      if (filters != null && filters.isNotEmpty) {
        for (var entry in filters.entries) {
          if (entry.value != null) {
            query = query.eq(entry.key, entry.value);
          }
        }
      }
      
      // Eksekusi query
      var results = await query;
      
      // Sorting manual di client (untuk menghindari error)
      if (orderBy != null && orderBy.isNotEmpty && results.isNotEmpty) {
        results.sort((a, b) {
          final aValue = a[orderBy];
          final bValue = b[orderBy];
          
          if (aValue == null && bValue == null) return 0;
          if (aValue == null) return 1;
          if (bValue == null) return -1;
          
          if (aValue is String && bValue is String) {
            return ascending 
                ? aValue.compareTo(bValue) 
                : bValue.compareTo(aValue);
          }
          if (aValue is num && bValue is num) {
            return ascending 
                ? aValue.compareTo(bValue) 
                : bValue.compareTo(aValue);
          }
          if (aValue is DateTime && bValue is DateTime) {
            return ascending 
                ? aValue.compareTo(bValue) 
                : bValue.compareTo(aValue);
          }
          return 0;
        });
      }
      
      print('✅ getData success: ${results.length} items');
      return results;
      
    } catch (e) {
      print('❌ Error in getData: $e');
      throw Exception('Gagal mengambil data dari $table: $e');
    }
  }

  // 🔥 GET ALL USERS (UNTUK ADMIN)
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final response = await _supabase
          .from('users')
          .select('*')
          .order('created_at', ascending: false);
      return response;
    } catch (e) {
      print('❌ Error getting all users: $e');
      return [];
    }
  }

  // 🔥 GET USER BY ID
  Future<Map<String, dynamic>?> getUserById(String id) async {
    try {
      final response = await _supabase
          .from('users')
          .select('*')
          .eq('id', id)
          .maybeSingle();
      return response;
    } catch (e) {
      print('❌ Error getting user: $e');
      return null;
    }
  }

  // 🔥 INSERT DATA
  Future<void> insertData(String table, Map<String, dynamic> data) async {
    try {
      await _supabase.from(table).insert(data);
      print('✅ Data inserted to $table');
    } catch (e) {
      print('❌ Error inserting: $e');
      throw Exception('Gagal menambah data: $e');
    }
  }

  // 🔥 UPDATE DATA
  Future<void> updateData(String table, Map<String, dynamic> data, String id) async {
    try {
      if (id.isEmpty) {
        throw Exception('ID tidak valid');
      }
      
      await _supabase.from(table).update(data).eq('id', id);
      print('✅ Data updated in $table');
    } catch (e) {
      print('❌ Error updating: $e');
      throw Exception('Gagal mengupdate data: $e');
    }
  }

  // 🔥 DELETE DATA
  Future<void> deleteData(String table, String id) async {
    try {
      print('🗑️ Deleting from $table where id = $id');
      
      if (id.isEmpty || id == 'null') {
        throw Exception('ID tidak valid');
      }
      
      await _supabase
          .from(table)
          .delete()
          .eq('id', id);
      
      print('✅ Data deleted from $table');
      
    } catch (e) {
      print('❌ Error deleting data: $e');
      throw Exception('Gagal menghapus data: $e');
    }
  }

  // 🔥 DELETE USER (KHUSUS)
  Future<void> deleteUser(String userId) async {
    try {
      print('🗑️ Deleting user: $userId');
      
      if (userId.isEmpty || userId == 'null') {
        throw Exception('User ID tidak valid');
      }
      
      // 🔥 CEK APAKAH USER ADA
      final user = await getUserById(userId);
      if (user == null) {
        throw Exception('User tidak ditemukan');
      }
      
      // 🔥 HAPUS DARI TABEL users
      await _supabase
          .from('users')
          .delete()
          .eq('id', userId);
      
      print('✅ User deleted successfully');
      
    } catch (e) {
      print('❌ Error deleting user: $e');
      throw Exception('Gagal menghapus user: $e');
    }
  }


  // 🔥 GET ALL BERITA - METHOD KHUSUS
  Future<List<Map<String, dynamic>>> getAllBerita() async {
    try {
      print('📰 Fetching all berita...');
      
      final response = await _supabase
          .from('berita_sekolah')
          .select('*');
      
      // Sorting manual by tanggal DESC
      response.sort((a, b) {
        final dateA = a['tanggal'] ?? '';
        final dateB = b['tanggal'] ?? '';
        return dateB.compareTo(dateA); // Descending
      });
      
      print('✅ Found ${response.length} berita');
      return response;
      
    } catch (e) {
      print('❌ Error getting berita: $e');
      throw Exception('Gagal mengambil berita: $e');
    }
  }

  // 🔥 GET BERITA BY ID
  Future<Map<String, dynamic>?> getBeritaById(String id) async {
    try {
      final response = await _supabase
          .from('berita_sekolah')
          .select('*')
          .eq('id', id)
          .maybeSingle();
      return response;
    } catch (e) {
      print('❌ Error getting berita by id: $e');
      return null;
    }
  }

  // 🔥 INSERT BERITA (UNTUK ADMIN)
  Future<void> insertBerita(Map<String, dynamic> data) async {
    try {
      await _supabase.from('berita_sekolah').insert(data);
      print('✅ Berita inserted');
    } catch (e) {
      throw Exception('Gagal menambah berita: $e');
    }
  }

  // 🔥 UPDATE BERITA (UNTUK ADMIN)
  Future<void> updateBerita(String id, Map<String, dynamic> data) async {
    try {
      await _supabase.from('berita_sekolah').update(data).eq('id', id);
      print('✅ Berita updated');
    } catch (e) {
      throw Exception('Gagal update berita: $e');
    }
  }

  // 🔥 DELETE BERITA (UNTUK ADMIN)
  Future<void> deleteBerita(String id) async {
    try {
      await _supabase.from('berita_sekolah').delete().eq('id', id);
      print('✅ Berita deleted');
    } catch (e) {
      throw Exception('Gagal hapus berita: $e');
    }
  }

  // 🔥 GET MATERI BY KELAS
  Future<List<Map<String, dynamic>>> getMateriByKelas(String kelas) async {
    try {
      print('📚 Getting materi for kelas: $kelas');
      
      final response = await _supabase
          .from('materi')
          .select('*, guru:users!guru_id(nama)')
          .eq('kelas', kelas)
          .order('created_at', ascending: false);
      
      print('✅ Found ${response.length} materi');
      return response;
    } catch (e) {
      print('❌ Error getting materi: $e');
      throw Exception('Gagal mengambil materi: $e');
    }
  }

  // 🔥 GET TUGAS BY KELAS
  Future<List<Map<String, dynamic>>> getTugasByKelas(String kelas) async {
    try {
      print('📋 Getting tugas for kelas: $kelas');
      
      final response = await _supabase
          .from('tugas')
          .select('*, guru:users!guru_id(nama)')
          .eq('kelas', kelas)
          .order('created_at', ascending: false);
      
      print('✅ Found ${response.length} tugas');
      return response;
    } catch (e) {
      print('❌ Error getting tugas: $e');
      throw Exception('Gagal mengambil tugas: $e');
    }
  }

  // 🔥 GET ABSENSI BY SISWA
  Future<List<Map<String, dynamic>>> getAbsensiBySiswa(String siswaId) async {
    try {
      print('📋 Getting absensi for siswa: $siswaId');
      
      final response = await _supabase
          .from('absensi')
          .select('*')
          .eq('siswa_id', siswaId)
          .order('tanggal', ascending: false);
      
      print('✅ Found ${response.length} absensi');
      return response;
    } catch (e) {
      print('❌ Error getting absensi: $e');
      throw Exception('Gagal mengambil absensi: $e');
    }
  }

  // 🔥 GET JADWAL BY KELAS
  Future<List<Map<String, dynamic>>> getJadwalByKelas(String kelas) async {
    try {
      print('📅 Getting jadwal for kelas: $kelas');
      
      final response = await _supabase
          .from('jadwal')
          .select('*, guru:users!guru_id(nama)')
          .eq('kelas', kelas)
          .order('hari', ascending: true);
      
      print('✅ Found ${response.length} jadwal');
      return response;
    } catch (e) {
      print('❌ Error getting jadwal: $e');
      throw Exception('Gagal mengambil jadwal: $e');
    }
  }

  // 🔥 GET DATA WITH FILTER - PERBAIKI
  Future<List<Map<String, dynamic>>> getDataWithFilter(
    String table, {
    String? orderBy,
    bool ascending = false,
    Map<String, dynamic>? filters,
  }) async {
    try {
      print('🔍 getDataWithFilter - Table: $table');
      
      var query = _supabase.from(table).select('*');
      
      // Tambahkan filter
      if (filters != null && filters.isNotEmpty) {
        for (var entry in filters.entries) {
          if (entry.value != null) {
            print('   Filter: ${entry.key} = ${entry.value}');
            query = query.eq(entry.key, entry.value);
          }
        }
      }
      
      // Eksekusi query
      var results = await query;
      
      // Sorting manual di client
      if (orderBy != null && orderBy.isNotEmpty && results.isNotEmpty) {
        results.sort((a, b) {
          final aValue = a[orderBy];
          final bValue = b[orderBy];
          
          if (aValue == null && bValue == null) return 0;
          if (aValue == null) return 1;
          if (bValue == null) return -1;
          
          if (aValue is String && bValue is String) {
            return ascending 
                ? aValue.compareTo(bValue) 
                : bValue.compareTo(aValue);
          }
          if (aValue is num && bValue is num) {
            return ascending 
                ? aValue.compareTo(bValue) 
                : bValue.compareTo(aValue);
          }
          return 0;
        });
      }
      
      print('✅ getDataWithFilter success: ${results.length} items');
      return results;
      
    } catch (e) {
      print('❌ Error in getDataWithFilter: $e');
      throw Exception('Gagal mengambil data dari $table: $e');
    }
  }


}