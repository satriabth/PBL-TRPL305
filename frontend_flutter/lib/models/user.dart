/// Peran pengguna dalam sistem (sesuai spesifikasi: maba, admin, keuangan, super admin).
enum UserRole { maba, admin, keuangan, superAdmin }

/// Label tampilan untuk setiap peran.
extension UserRoleLabel on UserRole {
  String get label => switch (this) {
        UserRole.maba => 'Calon Mahasiswa',
        UserRole.admin => 'Admin',
        UserRole.keuangan => 'Keuangan',
        UserRole.superAdmin => 'Super Admin',
      };
}

/// Akun pengguna. Untuk prototipe ini, kredensial disimpan di memori layanan mock.
class User {
  final String name;
  final String email;
  final String password;
  final UserRole role;

  const User({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
  });
}
