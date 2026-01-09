import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:klinik_app/app/constants/app_color.dart';
import 'package:klinik_app/model/bacaan.dart';
import 'package:klinik_app/ui/akun/akun_page.dart';
import 'package:klinik_app/ui/jadwal/jadwal_page.dart';
import 'package:klinik_app/ui/kunjungan/kunjungan_page.dart';
import 'package:klinik_app/ui/pasien/pasien_page.dart';
import 'package:klinik_app/ui/pegawai/pegawai_page.dart';
import 'package:klinik_app/ui/poli_page.dart';
import 'package:klinik_app/ui/resep/resep_page.dart';
import 'package:url_launcher/url_launcher.dart';

import '../helpers/user_info.dart';
import '../model/kunjungan.dart';
import '../service/jadwal_service.dart';
import '../service/kunjungan_service.dart';
import '../service/pasien_service.dart';
import '../service/pegawai_service.dart';
import '../service/poli_service.dart';

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

class AktivitasPage extends StatefulWidget {
  const AktivitasPage({super.key});

  @override
  State<AktivitasPage> createState() => _AktivitasPageState();
}

class _AktivitasPageState extends State<AktivitasPage> {
  String _nama = '';
  String _role = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {});
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
  /// MENU GRID (ROLE FIXED)
  /// =====================
  List<_MenuItem> _menus() {
    final isAdmin = _role == 'admin';
    final isPetugas = _role == 'petugas';
    final isDokter = _role == 'dokter';
    final isApoteker = _role == 'apoteker';

    final List<_MenuItem> items = [];

    // Semua role
    items.add(_MenuItem("Data Pasien", const PasienPage()));
    items.add(_MenuItem("Jadwal", const JadwalPage()));

    // Admin
    if (isAdmin) {
      items.add(_MenuItem("Akun", const AkunPage()));
      items.add(_MenuItem("Data Poli", const PoliPage()));
      items.add(_MenuItem("Pegawai", const PegawaiPage()));
    }

    // Petugas
    if (isPetugas) {
      items.add(_MenuItem("Data Poli", const PoliPage()));
      items.add(_MenuItem("Pegawai", const PegawaiPage()));
    }

    // Dokter
    if (isDokter) {
      items.add(_MenuItem("Kunjungan", const KunjunganPage()));
    }

    // Apoteker
    if (isApoteker) {
      items.add(_MenuItem("Resep", const ResepPage()));
    }

    return items;
  }

  bool get _showCarousel => _role == 'admin' || _role == 'dokter';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
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
                    children: [
                      /// SEARCH BAR
                      TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {});
                        },
                        decoration: InputDecoration(
                          hintText: "Cari menu atau informasi...",
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// STATISTIK
                      FutureBuilder<_DashboardData>(
                        future: _loadDashboard(),
                        builder: (context, snap) {
                          if (!snap.hasData) return const SizedBox();
                          final d = snap.data!;
                          return Row(
                            children: [
                              _miniStat("Pasien", d.pasien),
                              _miniStat("Jadwal", d.jadwal),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 28),

                      /// GRID MENU
                      Builder(
                        builder: (context) {
                          final keyword = _searchController.text.toLowerCase();

                          final filteredMenus = _menus().where((m) {
                            return m.title.toLowerCase().contains(keyword);
                          }).toList();

                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filteredMenus.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 0.85,
                                ),
                            itemBuilder: (context, i) {
                              final m = filteredMenus[i];
                              return InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => m.page),
                                  );
                                  setState(() {});
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.local_hospital,
                                        size: 28,
                                        color: AppColor.blue,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        m.title,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 32),

                      /// CAROUSEL (ADMIN & DOKTER)
                      if (_showCarousel) ...[
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Bacaan Kesehatan",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        CarouselSlider(
                          options: CarouselOptions(
                            height: 180,
                            autoPlay: true,
                            enlargeCenterPage: true,
                            viewportFraction: 0.85,
                          ),
                          items: bacaanList.map((b) {
                            return InkWell(
                              onTap: () async {
                                final uri = Uri.parse(b.link);
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(
                                    uri,
                                    mode: LaunchMode.externalApplication,
                                  );
                                }
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 10,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(18),
                                        bottomLeft: Radius.circular(18),
                                      ),
                                      child: Image.asset(
                                        b.gambar,
                                        width: 110,
                                        height: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(14),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              b.judul,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              b.deskripsi,
                                              maxLines: 4,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],

                      const SizedBox(height: 80),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _miniStat(String title, int value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value.toString(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem {
  final String title;
  final Widget page;
  _MenuItem(this.title, this.page);
}
