# 🎓 Aplikasi Microcredential Polibatam — PAKET LENGKAP

**Proyek PBL Semester 3 — Modul Registrasi Mahasiswa Baru**
Politeknik Negeri Batam · Teknik Rekayasa Perangkat Lunak

Paket ini berisi SEMUA: source code Flutter, hasil build demo (langsung jalan
tanpa install Flutter), backend, dan dokumen project. Cukup 1 file untuk di-upload.

---

## 📦 Isi Paket Ini

| Folder | Isi | Untuk apa |
|---|---|---|
| `frontend_flutter/` | Source aplikasi Flutter (lengkap) | **Development / lanjut koding** |
| `demo_web/` | Hasil build aplikasi (siap jalan) | **Test cepat tanpa install Flutter** |
| `backend/` | Kerangka REST API (FastAPI) | Referensi integrasi API |
| `docs/` | Dokumen project (spesifikasi, RPP, use case) | Referensi tugas |
| `README.md` | File ini | Panduan |

> `demo_web/` berisi `JALANKAN_DEMO.bat` + `CARA_TEST.txt` — bisa jalan di
> komputer mana pun (Windows) tanpa perlu Flutter, cukup Python.

---

## 🖥️ Prasyarat di Rumah
1. **Flutter SDK** (Windows): https://docs.flutter.dev/get-started/install/windows
2. **Chrome** (untuk mode web)
3. **Editor**: VSCode + ekstensi Flutter & Dart (atau Android Studio)
4. Internet saat pertama kali `flutter pub get`

> Untuk SEKEDAR TEST (tanpa install Flutter): langsung ke folder `demo_web/`.

---

## 🚀 CARA A — Test Cepat (tanpa Flutter)

```bash
# Buka folder demo_web, lalu dobel-klik:
JALANKAN_DEMO.bat
```
Chrome terbuka otomatis. Lihat `CARA_TEST.txt` untuk akun demo & alur test.

## 🚀 CARA B — Development (install Flutter)

```bash
cd frontend_flutter
flutter pub get            # ambil dependensi
flutter run -d chrome      # jalankan mode web (adaptif mobile/website)
# atau
flutter build web          # hasil di frontend_flutter/build/web
```
Di VSCode: buka folder `frontend_flutter` lalu tekan F5.

---

## 🔑 Akun Demo (kata sandi semua: `123456`)

| Role | Email |
|---|---|
| Calon Mahasiswa | `maba@test.com` |
| Admin | `admin@test.com` |
| Keuangan | `keuangan@test.com` |
| Super Admin | `super@test.com` |

**Alur demo lengkap:** Maba isi formulir & upload → submit → Admin setujui →
Keuangan terima → Maba lihat status berubah jadi **SELESAI**.

---

## 🧭 Struktur Kode (frontend_flutter)

```
lib/
├── main.dart                 # entry + daftar rute
├── routes.dart               # konstanta nama rute
├── theme.dart                # tema & warna (AppColors)
├── models/                   # User, Registration, Track, Payment, FAQ, dll
├── services/                 # AuthService (mock), RegistrationService (mock),
│                             # MockData, AppStorage, file picker
├── screens/                  # auth, maba, admin, finance, superadmin
└── widgets/                  # TimelineWidget, AppShell (responsif)
test/
└── widget_test.dart          # smoke test boot
```

Semua data masih **mock/dummy lokal** (belum terhubung backend) — ada banner
"Mode Simulasi" di bagian atas layar.

---

## ⏭️ Rencana Lanjutan
- Sambungkan ke backend REST API (FastAPI/Laravel — lihat `backend/`)
- Build APK Android (perlu Android SDK; kode sudah siap lintas platform)
- Selaraskan UI dengan mockup Figma tim (saat file desain tersedia)
