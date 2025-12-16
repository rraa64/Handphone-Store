// lib/pages/register_page.dart

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'register_success_page.dart';
// import 'login_page.dart'; // Sudah tidak perlu karena menggunakan Navigator.pop

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController(); // Controller untuk Nama
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;
  String? _error;
  bool _obscureText = true;
  static const Color primaryGreen = Color(0xFF4CAF50);

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final res = await _authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (res.user != null) {
        if (!mounted) return;
        // Navigasi ke Halaman Sukses Register setelah pendaftaran
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const RegisterSuccessPage()),
        );
      } else {
        setState(() {
          _error = 'Gagal mendaftar. Silakan coba lagi.';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Terjadi kesalahan. Silakan coba lagi.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Fungsi helper untuk styling input
  OutlineInputBorder _getOutlineInputBorder({Color borderColor = Colors.grey}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: BorderSide(
        color: borderColor,
        width: borderColor == primaryGreen ? 2.0 : 1.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Daftar Akun',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: screenHeight * 0.03),

              // --- Judul Halaman ---
              const Text(
                'Buat Akun Baru',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              SizedBox(height: screenHeight * 0.04),

              // --- Input Email ---
              const Text('Email',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black)),
              const SizedBox(height: 8.0),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Masukkan email Anda',
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 15.0, horizontal: 20.0),
                  border: _getOutlineInputBorder(),
                  enabledBorder:
                      _getOutlineInputBorder(borderColor: Colors.grey.shade300),
                  focusedBorder:
                      _getOutlineInputBorder(borderColor: primaryGreen),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Email tidak boleh kosong';
                  if (!value.contains('@')) return 'Format email tidak valid';
                  return null;
                },
              ),

              const SizedBox(height: 20.0),

              // --- Input Kata Sandi ---
              const Text('Kata sandi',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black)),
              const SizedBox(height: 8.0),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscureText,
                decoration: InputDecoration(
                  hintText: 'Buat kata sandi baru',
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 15.0, horizontal: 20.0),
                  border: _getOutlineInputBorder(),
                  enabledBorder:
                      _getOutlineInputBorder(borderColor: Colors.grey.shade300),
                  focusedBorder:
                      _getOutlineInputBorder(borderColor: primaryGreen),
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Password tidak boleh kosong';
                  if (value.length < 6) return 'Minimal 6 karakter';
                  return null;
                },
              ),

              const SizedBox(height: 30.0),

              // --- Error Message ---
              if (_error != null) ...[
                Text('Error: $_error',
                    style: const TextStyle(
                        color: Colors.red, fontWeight: FontWeight.w500)),
                const SizedBox(height: 10),
              ],

              // --- Tombol Daftar ---
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _loading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    elevation: 0,
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Daftar',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                ),
              ),

              const SizedBox(height: 40.0),

              // --- Sudah punya akun? Masuk ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Sudah punya akun?',
                      style: TextStyle(fontSize: 14, color: Colors.black54)),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      if (!_loading) {
                        Navigator.pop(context); // Kembali ke halaman Login
                      }
                    },
                    child: const Text(
                      'Masuk',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: primaryGreen),
                    ),
                  ),
                ],
              ),

              SizedBox(height: screenHeight * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}
