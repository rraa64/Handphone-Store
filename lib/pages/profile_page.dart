import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Konstanta Warna
  static const Color primaryGreen = Color(0xFF4CAF50);

  final user = Supabase.instance.client.auth.currentUser;

  Map<String, dynamic>? profile;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    // Pastikan user tidak null sebelum query
    if (user == null) {
      if (mounted) setState(() => loading = false);
      return;
    }

    // Mengambil data profile dari Supabase.
    // Asumsi: Nama lengkap ada di kolom 'nama_lengkap' di table 'users_profile'
    final data = await Supabase.instance.client
        .from("users_profile")
        .select()
        .eq("id", user!.id)
        .maybeSingle();

    if (!mounted) return;

    setState(() {
      profile = data;
      loading = false;
    });
  }

  Future<void> _handleLogout() async {
    await Supabase.instance.client.auth.signOut();
    if (!mounted) return;

    // Navigasi ke halaman login/beranda setelah logout
    // Ganti '/login' jika rute login Anda berbeda
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  // Widget untuk setiap detail profil dalam Card
  Widget _buildProfileDetail(
      {required IconData icon, required String title, required String value}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: primaryGreen),
        title: Text(title,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        subtitle: Text(
          value,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: primaryGreen)),
      );
    }

    // Ambil data
    // Pastikan ini mengambil data yang benar dari Supabase
    final String fullName = profile?["nama_lengkap"] ?? "Nama Pengguna";
    final String userEmail = user?.email ?? "Email Tidak Ditemukan";
    final String userAddress = profile?["alamat"] ?? "Belum diatur";
    final String userPhone = profile?["no_hp"] ?? "Belum diatur";

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Profil Saya"),
        centerTitle: true,
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // --- BAGIAN HEADER PROFIL (Avatar & Nama) ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  )
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: primaryGreen.withOpacity(0.1),
                    child:
                        const Icon(Icons.person, size: 50, color: primaryGreen),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    // *** INI YANG DIUBAH ***
                    fullName, // Menggunakan variabel fullName yang berisi data dari Supabase
                    // ************************
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    userEmail, // Menampilkan Email
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // --- BAGIAN DETAIL PROFIL ---
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Detail Akun",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700)),
            ),
            const SizedBox(height: 10),

            _buildProfileDetail(
              icon: Icons.person_outline,
              title: "Nama Lengkap",
              value: fullName,
            ),
            _buildProfileDetail(
              icon: Icons.email_outlined,
              title: "Email Akun",
              value: userEmail,
            ),
            _buildProfileDetail(
              icon: Icons.phone_android_outlined,
              title: "Nomor Telepon",
              value: userPhone,
            ),
            _buildProfileDetail(
              icon: Icons.location_on_outlined,
              title: "Alamat Lengkap",
              value: userAddress,
            ),

            const SizedBox(height: 30),

            // --- TOMBOL LOGOUT ---
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _handleLogout,
                icon: const Icon(Icons.logout),
                label: const Text("Logout", style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
