import 'package:flutter/material.dart';

import '../routes.dart';
import '../services/service_locator.dart';
import '../theme.dart';

/// Layar pendaftaran akun baru (route '/register'). Akun baru selalu dibuat
/// dengan peran maba oleh AuthService.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  /// Pola dasar alamat email (nama@domain.tld).
  static final RegExp _emailRegExp = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _konfirmasiController = TextEditingController();

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _konfirmasiController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final error = ServiceLocator.auth.register(
      nama: _namaController.text,
      email: _emailController.text,
      password: _passwordController.text,
    );
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Akun berhasil dibuat, silakan masuk')),
    );
    Navigator.of(context).pushReplacementNamed(Routes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- Logo & judul bermerek ---
                  Container(
                    width: 72,
                    height: 72,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.primary, AppColors.accent],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.person_add_alt_outlined,
                        color: Colors.white, size: 36),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Buat Akun Baru',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Isi data diri untuk mulai registrasi Microcredential',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppColors.muted, height: 1.4),
                  ),
                  const SizedBox(height: 28),
                  // --- Kartu formulir pendaftaran ---
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller: _namaController,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Nama Lengkap',
                                prefixIcon: Icon(Icons.badge_outlined),
                              ),
                              validator: (value) {
                                final text = value?.trim() ?? '';
                                if (text.isEmpty) {
                                  return 'Nama tidak boleh kosong.';
                                }
                                if (text.length < 3) {
                                  return 'Nama minimal 3 karakter.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                              validator: (value) {
                                final text = value?.trim() ?? '';
                                if (text.isEmpty) {
                                  return 'Email tidak boleh kosong.';
                                }
                                if (!_emailRegExp.hasMatch(text)) {
                                  return 'Format email tidak valid.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Kata Sandi',
                                prefixIcon: Icon(Icons.lock_outline),
                              ),
                              validator: (value) {
                                final text = value ?? '';
                                if (text.isEmpty) {
                                  return 'Kata sandi tidak boleh kosong.';
                                }
                                if (text.length < 6) {
                                  return 'Kata sandi minimal 6 karakter.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _konfirmasiController,
                              obscureText: true,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _submit(),
                              decoration: const InputDecoration(
                                labelText: 'Konfirmasi Kata Sandi',
                                prefixIcon: Icon(Icons.lock_reset_outlined),
                              ),
                              validator: (value) {
                                final text = value ?? '';
                                if (text.isEmpty) {
                                  return 'Konfirmasi kata sandi tidak boleh kosong.';
                                }
                                if (text != _passwordController.text) {
                                  return 'Konfirmasi kata sandi tidak cocok.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            FilledButton(
                              onPressed: _submit,
                              child: const Text('Daftar'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Sudah punya akun? Masuk'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
