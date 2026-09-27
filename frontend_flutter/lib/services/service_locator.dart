import 'auth_service.dart';
import 'registration_service.dart';

/// Lokator layanan sederhana (tanpa dependensi state management eksternal).
class ServiceLocator {
  ServiceLocator._();

  static final AuthService auth = AuthService();
  static final RegistrationService registration = RegistrationService();

  /// Panggil di awal aplikasi agar kedua layanan tetap hidup sampai akhir sesi.
  static void init() {
    auth.addListener(() {});
    registration.addListener(() {});
  }
}
