// lib/models/user_model.dart
class UserModel {
  final String id;
  final String email;
  final String nama;
  final String role;
  final String? kelas;
  final String? nis;
  final String? nip;
  final String? foto;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.nama,
    required this.role,
    this.kelas,
    this.nis,
    this.nip,
    this.foto,
    required this.createdAt,
    this.updatedAt,
  });

  // 🔥 FROM JSON - Sesuai dengan response dari Supabase
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      nama: json['nama'] ?? 'User',
      role: json['role'] ?? 'siswa',
      kelas: json['kelas'],
      nis: json['nis'],
      nip: json['nip'],
      foto: json['foto'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  // 🔥 TO JSON - Untuk insert/update ke Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nama': nama,
      'role': role,
      'kelas': kelas,
      'nis': nis,
      'nip': nip,
      'foto': foto,
      'created_at': createdAt.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  // 🔥 TO MAP - Untuk insert/update (tanpa id untuk update)
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'nama': nama,
      'role': role,
      'kelas': kelas,
      'nis': nis,
      'nip': nip,
      'foto': foto,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  // 🔥 COPY WITH - Untuk update data
  UserModel copyWith({
    String? id,
    String? email,
    String? nama,
    String? role,
    String? kelas,
    String? nis,
    String? nip,
    String? foto,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      nama: nama ?? this.nama,
      role: role ?? this.role,
      kelas: kelas ?? this.kelas,
      nis: nis ?? this.nis,
      nip: nip ?? this.nip,
      foto: foto ?? this.foto,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // 🔥 GET HOME ROUTE BASED ON ROLE
  String getHomeRoute() {
    switch (role) {
      case 'admin':
        return '/admin/homepage';
      case 'siswa':
        return '/siswa/homepage';
      case 'guru':
        return '/guru/homepage';
      case 'walimurid':
        return '/walimurid/homepage';
      default:
        return '/siswa/homepage';
    }
  }

  // 🔥 GET DISPLAY NAME WITH ROLE
  String getDisplayName() {
    return '$nama ($role)';
  }

  // 🔥 CHECK IF USER IS ADMIN
  bool get isAdmin => role == 'admin';
  
  // 🔥 CHECK IF USER IS SISWA
  bool get isSiswa => role == 'siswa';
  
  // 🔥 CHECK IF USER IS GURU
  bool get isGuru => role == 'guru';
  
  // 🔥 CHECK IF USER IS WALIMURID
  bool get isWalimurid => role == 'walimurid';

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, nama: $nama, role: $role, kelas: $kelas, nis: $nis)';
  }
}

// 🔥 ENUM ROLE - Untuk validasi
enum UserRole {
  siswa,
  guru,
  walimurid,
  admin,
}

extension UserRoleExtension on UserRole {
  String get value {
    switch (this) {
      case UserRole.siswa:
        return 'siswa';
      case UserRole.guru:
        return 'guru';
      case UserRole.walimurid:
        return 'walimurid';
      case UserRole.admin:
        return 'admin';
    }
  }

  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'siswa':
        return UserRole.siswa;
      case 'guru':
        return UserRole.guru;
      case 'walimurid':
        return UserRole.walimurid;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.siswa;
    }
  }
}