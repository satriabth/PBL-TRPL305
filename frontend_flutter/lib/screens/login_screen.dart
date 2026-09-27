import 'package:flutter/material.dart';

import '../models/user.dart';
import '../routes.dart';
import '../services/service_locator.dart';
import '../theme.dart';

/// Layar masuk (route '/login'). Memvalidasi kredensial lewat AuthService
/// dan mengarahkan ke beranda sesuai peran pengguna.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  /// Pola dasar alamat email (nama@domain.tld).
  static final RegExp _emailRegExp = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  /// Akun demo untuk autofill saat prototipe (kata sandi: 123456).
  static const List<({String label, String email})> _demoAccounts = [
    (label: 'Maba', email: 'maba@test.com'),
    (label: 'Admin', email: 'admin@test.com'),
    (label: 'Keuangan', email: 'keuangan@test.com'),
    (label: 'Super Admin', email: 'super@test.com'),
  ];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Rute beranda sesuai peran pengguna.
  String _roleRoute(UserRole role) => switch (role) {
        UserRole.maba => Routes.home,
        UserRole.admin => Routes.admin,
        UserRole.keuangan => Routes.finance,
        UserRole.superAdmin => Routes.home,
      };

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final error = ServiceLocator.auth.login(
      email: _emailController.text,
      password: _passwordController.text,
    );
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    final role = ServiceLocator.auth.currentUser!.role;
    Navigator.of(context)
        .pushNamedAndRemoveUntil(_roleRoute(role), (r) => false);
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
                    child: const Icon(Icons.school, color: Colors.white, size: 36),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Selamat Datang',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Silakan masuk ke akun Microcredential Anda',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppColors.muted, height: 1.4),
                  ),
                  const SizedBox(height: 28),
                  // --- Kartu formulir masuk ---
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
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                              validator: (value) {
                                final text = value?.trim() ?? '';
                                if (text.isEmpty) return 'Email tidak boleh kosong.';
                                if (!_emailRegExp.hasMatch(text)) {
                                  return 'Format email tidak valid.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _submit(),
                              decoration: InputDecoration(
                                labelText: 'Kata Sandi',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                  onPressed: () => setState(
                                      () => _obscurePassword = !_obscurePassword),
                                ),
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
                            const SizedBox(height: 24),
                            FilledButton(
                              onPressed: _submit,
                              child: const Text('Masuk'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // --- Akun demo (seksi kompak) ---
                  Text(
                    'Akun demo',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(color: AppColors.muted),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final account in _demoAccounts)
                        ChoiceChip(
                          label: Text(account.label),
                          selected: _emailController.text == account.email,
                          onSelected: (_) => setState(() {
                            _emailController.text = account.email;
                            _passwordController.text = '123456';
                          }),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  TextButton(
                    onPressed: () =>
                        Navigator.of(context).pushNamed(Routes.register),
                    child: const Text('Belum punya akun? Daftar'),
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
