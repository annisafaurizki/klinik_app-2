import 'package:flutter/material.dart';
import 'package:klinik_app/app/constants/app_color.dart';
import 'package:klinik_app/ui/login.dart';

import '../../helpers/user_info.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _nama = '';
  String _role = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final info = UserInfo();
    final nama = await info.getNama() ?? '';
    final role = await info.getRole() ?? '';
    if (!mounted) return;
    setState(() {
      _nama = nama;
      _role = role;
    });
  }

  Future<void> _logout() async {
    await UserInfo().logout();
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const Login()),
      (route) => false,
    );
  }

  // =====================
  // ALERT DIALOG (STYLE PEGAWAI)
  // =====================
  void _showDialog({required String title, required String content}) {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 222, 235, 247),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColor.background),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(content, style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Tutup',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Akun',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColor.black,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [AppColor.backgroundBlue, AppColor.whiteBlue],
          ),
        ),
        child: SafeArea(
          child: _nama.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // =====================
                    // CARD ADMINISTRASI KLINIK
                    // =====================
                    _pegawaiStyleCard(
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: AppColor.backgroundBlue,
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _nama,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _role.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            color: AppColor.blue,
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // =====================
                    // SECTION: AKUN
                    // =====================
                    _sectionTitle('Akun'),
                    _pegawaiTile(
                      icon: Icons.person_outline,
                      title: 'Profil Saya',
                      subtitle: 'Lihat informasi akun',
                    ),
                    _pegawaiTile(
                      icon: Icons.lock_outline,
                      title: 'Ubah Password',
                    ),

                    const SizedBox(height: 20),

                    // =====================
                    // SECTION: APLIKASI
                    // =====================
                    _sectionTitle('Aplikasi'),
                    _pegawaiTile(
                      icon: Icons.info_outline,
                      title: 'Tentang Aplikasi',
                      onTap: () {
                        _showDialog(
                          title: 'Tentang Aplikasi',
                          content:
                              'Aplikasi Manajemen Klinik adalah sistem '
                              'yang digunakan untuk membantu pengelolaan '
                              'data dan aktivitas klinik secara digital '
                              'agar lebih rapi, cepat, dan efisien.',
                        );
                      },
                    ),
                    _pegawaiTile(
                      icon: Icons.help_outline,
                      title: 'Bantuan',
                      onTap: () {
                        _showDialog(
                          title: 'Bantuan',
                          content:
                              'Jika ada kendala silakan hubungi:\n\n081297635363',
                        );
                      },
                    ),

                    const SizedBox(height: 28),

                    // =====================
                    // LOGOUT
                    // =====================
                    _pegawaiStyleCard(
                      child: ListTile(
                        leading: const Icon(Icons.logout, color: Colors.red),
                        title: const Text(
                          'Logout',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onTap: _logout,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // =====================
  // WIDGET BANTU
  // =====================

  Widget _pegawaiStyleCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 222, 235, 247),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.background),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _pegawaiTile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: _pegawaiStyleCard(
        child: ListTile(
          leading: Icon(icon, color: AppColor.blue),
          title: Text(title),
          subtitle: subtitle != null ? Text(subtitle) : null,
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
      ),
    );
  }
}
