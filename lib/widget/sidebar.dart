import 'package:flutter/material.dart';
import 'package:klinik_app/app/constants/app_color.dart';

import '../helpers/user_info.dart';
import '../ui/akun/akun_page.dart';
import '../ui/beranda.dart';
import '../ui/jadwal/jadwal_page.dart';
import '../ui/kunjungan/kunjungan_page.dart';
import '../ui/login.dart';
import '../ui/pasien/pasien_page.dart';
import '../ui/pegawai/pegawai_page.dart';
import '../ui/poli_page.dart';
import '../ui/resep/resep_page.dart';

class Sidebar extends StatefulWidget {
  const Sidebar({super.key});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
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

  @override
  Widget build(BuildContext context) {
    final isAdmin = _role.toLowerCase() == 'admin';
    final isPetugas = _role.toLowerCase() == 'petugas';
    final isDokter = _role.toLowerCase() == 'dokter';
    final isApoteker = _role.toLowerCase() == 'apoteker';
    return Drawer(
      backgroundColor: AppColor.whiteBlue,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: AppColor.backgroundBlue),
            accountName: Text(_nama.isEmpty ? 'Pengguna' : _nama),
            accountEmail: Text(
              _role.isEmpty ? 'Role belum diketahui' : _role.toUpperCase(),
            ),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: AppColor.whiteBlue,
              child: Icon(Icons.person, color: AppColor.blue),
            ),
          ),

          // ------------------------------
          // MENU UMUM: BERANDA
          // ------------------------------
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Beranda'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const Beranda()),
              );
            },
          ),

          // ------------------------------
          // ADMIN ONLY: MANAJEMEN AKUN
          // ------------------------------
          if (isAdmin)
            ListTile(
              leading: const Icon(Icons.manage_accounts),
              title: const Text('Manajemen Akun'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const AkunPage()),
                );
              },
            ),

          // ------------------------------
          // ADMIN & PETUGAS: MASTER DATA
          // ------------------------------
          if (isAdmin || isPetugas) ...[
            ListTile(
              leading: const Icon(Icons.local_hospital),
              title: const Text('Data Poli'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const PoliPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Data Pegawai'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const PegawaiPage()),
                );
              },
            ),
          ],

          // ------------------------------
          // SEMUA ROLE: DATA PASIEN
          // ------------------------------
          ListTile(
            leading: const Icon(Icons.person_search),
            title: const Text('Data Pasien'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const PasienPage()),
              );
            },
          ),
          // --- Menu khusus Apoteker: Resep Elektronik ---
          if (isApoteker)
            ListTile(
              leading: const Icon(Icons.medication),
              title: const Text('Resep Elektronik'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ResepPage(), // 👈 nanti kita buat
                  ),
                );
              },
            ),
          const Divider(),

          // ------------------------------
          // DOKTER ONLY: REKAM MEDIS
          // ------------------------------
          if (isDokter)
            ListTile(
              leading: const Icon(Icons.assignment),
              title: const Text('Kunjungan / Rekam Medis'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const KunjunganPage()),
                );
              },
            ),

          // ------------------------------
          // SEMUA ROLE: JADWAL DOKTER
          // ------------------------------
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text('Jadwal Dokter'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const JadwalPage()),
              );
            },
          ),

          const Divider(),

          // ------------------------------
          // LOGOUT
          // ------------------------------
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              await UserInfo().logout();
              if (!mounted) return;

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const Login()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
