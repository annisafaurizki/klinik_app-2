import 'package:flutter/material.dart';
import 'package:klinik_app/app/constants/app_color.dart';
import 'package:lottie/lottie.dart';

import '../helpers/user_info.dart';
import '../model/kunjungan.dart';
import '../service/jadwal_service.dart';
import '../service/kunjungan_service.dart';
import '../service/pasien_service.dart';
import '../service/pegawai_service.dart';
import '../service/poli_service.dart';
// halaman tujuan (aksi cepat)
import 'akun/akun_page.dart';
import 'pegawai/pegawai_page.dart';
import 'poli_page.dart';

/// =====================
/// MODEL DASHBOARD
/// =====================
class _DashboardData {
  final int poli;
  final int pegawai;
  final int pasien;
  final int jadwal;
  final int kunjungan;
  final int hariIni;

  _DashboardData({
    required this.poli,
    required this.pegawai,
    required this.pasien,
    required this.jadwal,
    required this.kunjungan,
    required this.hariIni,
  });
}

/// =====================
/// BERANDA
/// =====================
class Beranda extends StatefulWidget {
  const Beranda({super.key});

  @override
  State<Beranda> createState() => _BerandaState();
}

class _BerandaState extends State<Beranda> {
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
      _role = role.toLowerCase();
    });
  }

  Future<_DashboardData> _loadDashboard() async {
    final poli = await PoliService().listData();
    final pegawai = await PegawaiService().listData();
    final pasien = await PasienService().listData();
    final jadwal = await JadwalService().listData();
    final kunjungan = await KunjunganService().listData();

    final now = DateTime.now();
    int hariIni = 0;

    for (final Kunjungan k in kunjungan) {
      final t = DateTime.tryParse(k.tanggal);
      if (t != null &&
          t.year == now.year &&
          t.month == now.month &&
          t.day == now.day) {
        hariIni++;
      }
    }

    return _DashboardData(
      poli: poli.length,
      pegawai: pegawai.length,
      pasien: pasien.length,
      jadwal: jadwal.length,
      kunjungan: kunjungan.length,
      hariIni: hariIni,
    );
  }

  /// =====================
  /// DUMMY LOTTIE PER ROLE
  /// =====================
  Widget _roleLottie() {
    return SizedBox(
      height: 120,
      width: 120,
      child: Lottie.asset(
        'assets/lottie/doctor.json',
        fit: BoxFit.contain,
        repeat: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [AppColor.backgroundBlue, AppColor.whiteBlue],
          ),
        ),
        child: SafeArea(
          child: _role.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ================= HEADER =================
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Hi 👋",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black54,
                                  ),
                                ),
                                Text(
                                  _nama,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text("Bantuan"),
                                  content: const Text(
                                    "Jika bermasalah silahkan hubungi\n081297635363",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text("Tutup"),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.transparent,
                              child: Icon(
                                Icons.help_outline_sharp,
                                color: AppColor.blue,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // ================= SEARCH BAR (DUMMY) =================
                      Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.search, color: Colors.grey),
                            SizedBox(width: 8),
                            Text(
                              "Cari menu...",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ================= WELCOME CARD =================
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Selamat Datang",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "Cek tugas sebelum bekerja",
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            _roleLottie(),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ================= STATISTIK =================
                      FutureBuilder<_DashboardData>(
                        future: _loadDashboard(),
                        builder: (context, snap) {
                          if (!snap.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          final d = snap.data!;
                          return Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              _stat("Pasien", d.pasien, Icons.people),
                              _stat("Pegawai", d.pegawai, Icons.badge),
                              _stat("Poli", d.poli, Icons.local_hospital),
                              _stat("Jadwal", d.jadwal, Icons.schedule),
                              _stat("Hari Ini", d.hariIni, Icons.today),
                              _stat("Kunjungan", d.kunjungan, Icons.assignment),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 28),

                      // ================= AKSI CEPAT =================
                      const Text(
                        "Aksi Cepat",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          _quickAction(
                            "Pegawai",
                            Icons.people,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PegawaiPage(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          _quickAction(
                            "Poli",
                            Icons.local_hospital,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PoliPage(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          _quickAction(
                            "Akun",
                            Icons.manage_accounts,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AkunPage(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  // ================= STAT CARD =================
  Widget _stat(String title, int value, IconData icon) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 44) / 2,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColor.blue),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12)),
                Text(
                  value.toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ================= QUICK ACTION =================
  Widget _quickAction(String label, IconData icon, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColor.blue),
              const SizedBox(height: 6),
              Text(label, style: const TextStyle(fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}
