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
// halaman tujuan
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

  _DashboardData({
    required this.poli,
    required this.pegawai,
    required this.pasien,
    required this.jadwal,
    required this.kunjungan,
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
  final TextEditingController _searchController = TextEditingController();

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

    return _DashboardData(
      poli: poli.length,
      pegawai: pegawai.length,
      pasien: pasien.length,
      jadwal: jadwal.length,
      kunjungan: kunjungan.length,
    );
  }

  /// =====================
  /// WARNA WELCOME CARD
  /// =====================
  Color _welcomeColor() {
    switch (_role) {
      case 'dokter':
        return const Color(0xFFFFE4EC);
      case 'apoteker':
        return const Color(0xFFE6F6EA);
      case 'petugas':
        return const Color(0xFFFFF5CC);
      default:
        return Colors.white;
    }
  }

  /// =====================
  /// LOTTIE PER ROLE
  /// =====================
  Widget _roleLottie() {
    String asset;
    switch (_role) {
      case 'dokter':
        asset = 'assets/lottie/dokter.json';
        break;
      case 'apoteker':
        asset = 'assets/lottie/apoteker.json';
        break;
      case 'petugas':
        asset = 'assets/lottie/petugas.json';
        break;
      default:
        asset = 'assets/lottie/admin.json';
    }

    return SizedBox(
      height: 120,
      width: 120,
      child: Lottie.asset(asset, fit: BoxFit.contain),
    );
  }

  /// =====================
  /// SEARCH ACTION
  /// =====================
  void _handleSearch(String keyword) {
    final text = keyword.toLowerCase();

    if (text.contains("pegawai")) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PegawaiPage()),
      );
    } else if (text.contains("poli")) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PoliPage()),
      );
    } else if (text.contains("akun")) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AkunPage()),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Menu tidak ditemukan")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity, // 🔥 background full
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
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// HEADER
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
                            const Icon(
                              Icons.help_outline_sharp,
                              color: AppColor.blue,
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        /// SEARCH
                        Container(
                          height: 44,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (_) => setState(() {}),
                            onSubmitted: _handleSearch,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              icon: Icon(Icons.search, color: Colors.grey),
                              hintText: "Cari pasien, poli, dokter, tanggal...",
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        /// WELCOME CARD
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _welcomeColor(),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Selamat Datang",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      "Cek tugas sebelum bekerja",
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                              _roleLottie(),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        /// =============================
                        /// KUNJUNGAN DOKTER (SAMA DENGAN KUNJUNGAN PAGE)
                        /// =============================
                        if (_role == 'dokter')
                          FutureBuilder<List<Kunjungan>>(
                            future: KunjunganService().listData(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              final all = snapshot.data!;
                              final kw = _searchController.text.toLowerCase();

                              final items = kw.isEmpty
                                  ? all
                                  : all.where((k) {
                                      return k.namaPasien
                                              .toLowerCase()
                                              .contains(kw) ||
                                          k.poli.toLowerCase().contains(kw) ||
                                          k.dokter.toLowerCase().contains(kw) ||
                                          k.tanggal.toLowerCase().contains(kw);
                                    }).toList();

                              if (items.isEmpty) {
                                return Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Text("Belum ada data kunjungan"),
                                );
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Kunjungan Pasien",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ...items.map((k) {
                                    final inisial =
                                        (k.namaPasien.isNotEmpty
                                                ? k.namaPasien[0]
                                                : '?')
                                            .toUpperCase();

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 6,
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(
                                            255,
                                            222,
                                            235,
                                            247,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          border: Border.all(
                                            color: AppColor.background,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    k.namaPasien,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    "${k.poli} - ${k.dokter}",
                                                  ),
                                                  Text("Tanggal: ${k.tanggal}"),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              width: 52,
                                              height: 52,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                color: AppColor.gray100,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                inisial,
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            const Icon(Icons.chevron_right),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              );
                            },
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
