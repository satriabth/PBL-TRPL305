import 'package:flutter/foundation.dart';

import '../models/user.dart';

/// Layanan autentikasi mock: registrasi akun, login, dan kelola sesi pengguna.
class AuthService extends ChangeNotifier {
  User? currentUser;

  final List<User> _accounts = [
    const User(
      name: 'Satria Andhika',
      email: 'maba@test.com',
      password: '123456',
      role: UserRole.maba,
    ),
    const User(
      name: 'Admin Pendaftaran',
      email: 'admin@test.com',
      password: '123456',
      role: UserRole.admin,
    ),
    const User(
      name: 'Bagian Keuangan',
      email: 'keuangan@test.com',
      password: '123456',
      role: UserRole.keuangan,
    ),
    const User(
      name: 'Super Admin',
      email: 'super@test.com',
      password: '123456',
      role: UserRole.superAdmin,
    ),
  ];

  bool get isLoggedIn => currentUser != null;

  /// Membuat akun baru. Mengembalikan pesan error, atau null bila berhasil.
  String? register({
    required String nama,
    required String email,
    required String password,
  }) {
    final cleanNama = nama.trim();
    final cleanEmail = email.trim().toLowerCase();

    if (cleanNama.isEmpty) return 'Nama tidak boleh kosong.';
    if (!cleanEmail.contains('@')) return 'Email tidak valid.';
    if (password.length < 6) return 'Kata sandi minimal 6 karakter.';
    if (_accounts.any((a) => a.email == cleanEmail)) {
      return 'Email sudah terdaftar. Gunakan email lain.';
    }

    _accounts.add(User(
      name: cleanNama,
      email: cleanEmail,
      password: password,
      role: UserRole.maba,
    ));
    notifyListeners();
    return null;
  }

  /// Login ke aplikasi. Mengembalikan pesan error, atau null bila berhasil.
  String? login({required String email, required String password}) {
    final cleanEmail = email.trim().toLowerCase();
    final user = _accounts.where((a) => a.email == cleanEmail).firstOrNull;

    if (user == null) return 'Email tidak terdaftar.';
    if (user.password != password) return 'Kata sandi salah.';

    currentUser = user;
    notifyListeners();
    return null;
  }

  void logout() {
    currentUser = null;
    notifyListeners();
  }

  List<User> get accounts => List.unmodifiable(_accounts);
}
