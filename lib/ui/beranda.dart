import 'package:flutter/material.dart';

import '../app/constants/app_color.dart'; // pastikan sudah ada AppColor
import '../helpers/user_info.dart';
import '../model/kunjungan.dart';
import '../service/jadwal_service.dart';
import '../service/kunjungan_service.dart';
import '../service/pasien_service.dart';
import '../service/pegawai_service.dart';
import '../service/poli_service.dart';
import '../widget/sidebar.dart';

/// ---- MODEL DATA DASHBOARD (TOP LEVEL, DI LUAR STATE) ----
class _DashboardData {
  final int totalPoli;
  final int totalPegawai;
  final int totalPasien;
  final int totalJadwal;
  final int totalKunjungan;
  final int kunjunganHariIni;

  _DashboardData({
    required this.totalPoli,
    required this.totalPegawai,
    required this.totalPasien,
    required this.totalJadwal,
    required this.totalKunjungan,
    required this.kunjunganHariIni,
  });
}

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
      _role = role;
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
      totalPoli: poli.length,
      totalPegawai: pegawai.length,
      totalPasien: pasien.length,
      totalJadwal: jadwal.length,
      totalKunjungan: kunjungan.length,
      kunjunganHariIni: hariIni,
    );
  }

  @override
  Widget build(BuildContext context) {
    final roleLower = _role.toLowerCase();

    return Scaffold(
      drawer: const Sidebar(),

      // body ditarik sampai belakang AppBar
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),

      body: _role.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : (roleLower == 'admin'
                ? _buildAdminDashboard()
                : _buildNonAdminHome()),
    );
  }

  // =======================
  //      ADMIN DASHBOARD
  // =======================

  Widget _buildAdminDashboard() {
    return SizedBox.expand(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight, // biru dari kanan atas
            end: Alignment.bottomLeft, // lightBlue ke kiri bawah
            colors: [AppColor.backgroundBlue, AppColor.whiteBlue],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: FutureBuilder<_DashboardData>(
              future: _loadDashboard(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Gagal memuat dashboard:\n${snapshot.error}",
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                final data = snapshot.data!;

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Selamat datang, ${_nama.isEmpty ? 'Admin' : _nama}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Ringkasan aktivitas klinik hari ini",
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 16),

                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _statCard(
                            title: "Total Pasien",
                            value: data.totalPasien,
                            icon: Icons.person,
                            color: Colors.blue,
                          ),
                          _statCard(
                            title: "Total Pegawai",
                            value: data.totalPegawai,
                            icon: Icons.badge,
                            color: Colors.orange,
                          ),
                          _statCard(
                            title: "Total Poli",
                            value: data.totalPoli,
                            icon: Icons.local_hospital,
                            color: Colors.green,
                          ),
                          _statCard(
                            title: "Jadwal Dokter",
                            value: data.totalJadwal,
                            icon: Icons.schedule,
                            color: Colors.purple,
                          ),
                          _statCard(
                            title: "Kunjungan Hari Ini",
                            value: data.kunjunganHariIni,
                            icon: Icons.today,
                            color: Colors.red,
                          ),
                          _statCard(
                            title: "Total Kunjungan",
                            value: data.totalKunjungan,
                            icon: Icons.assignment,
                            color: Colors.teal,
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 8),

                      const Text(
                        "Statistik Kunjungan",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      _simpleBar(
                        label: "Hari ini",
                        value: data.kunjunganHariIni,
                        max: (data.totalKunjungan == 0)
                            ? 1
                            : data.totalKunjungan,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 8),

                      _simpleBar(
                        label: "Total",
                        value: data.totalKunjungan,
                        max: (data.totalKunjungan == 0)
                            ? 1
                            : data.totalKunjungan,
                        color: Colors.teal,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _statCard({
    required String title,
    required int value,
    required IconData icon,
    required Color color,
  }) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 16 * 2 - 12) / 2,
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                foregroundColor: color,
                child: Icon(icon),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value.toString(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // BAR SEDERHANA
  Widget _simpleBar({
    required String label,
    required int value,
    required int max,
    required Color color,
  }) {
    final width = MediaQuery.of(context).size.width - 32;
    final ratio = (max == 0) ? 0.0 : (value / max);
    final barWidth = width * ratio.clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label: $value"),
        const SizedBox(height: 4),
        Stack(
          children: [
            Container(
              height: 12,
              width: width,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 12,
              width: barWidth,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // =========================
  //  HOME UNTUK NON ADMIN
  // =========================

  Widget _buildNonAdminHome() {
    final isDokter = _role.toLowerCase() == 'dokter';
    final isPetugas = _role.toLowerCase() == 'petugas';
    final isApoteker = _role.toLowerCase() == 'apoteker';

    String desc;
    if (isDokter) {
      desc =
          "Anda login sebagai Dokter.\nSilakan gunakan menu Kunjungan dan Jadwal untuk mengelola pasien.";
    } else if (isPetugas) {
      desc =
          "Anda login sebagai Petugas.\nGunakan menu Pasien, Kunjungan, dan Jadwal untuk pelayanan front office.";
    } else if (isApoteker) {
      desc =
          "Anda login sebagai Apoteker.\nGunakan menu Resep Elektronik untuk memproses resep dokter.";
    } else {
      desc = "Selamat datang di sistem klinik.";
    }

    // beda background per role non-admin (simple)
    Color bg;
    if (isDokter) {
      bg = AppColor.whiteBlue;
    } else if (isPetugas) {
      bg = AppColor.grayField;
    } else if (isApoteker) {
      bg = AppColor.greenStatus.withOpacity(0.08);
    } else {
      bg = Colors.white;
    }

    return Container(
      color: bg,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.local_hospital,
                  size: 72,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  "Halo, ${_nama.isEmpty ? 'Pengguna' : _nama}",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  desc,
                  style: const TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
