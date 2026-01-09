import 'package:flutter/material.dart';
import 'package:klinik_app/app/constants/app_color.dart';

import '../../helpers/user_info.dart';
import '../../model/jadwal.dart';
import '../../service/jadwal_service.dart';
import 'jadwal_page.dart';
import 'jadwal_update_form.dart';

class JadwalDetail extends StatefulWidget {
  final Jadwal jadwal;

  const JadwalDetail({super.key, required this.jadwal});

  @override
  State<JadwalDetail> createState() => _JadwalDetailState();
}

class _JadwalDetailState extends State<JadwalDetail> {
  String _role = '';
  late Stream<Jadwal> _stream;

  @override
  void initState() {
    super.initState();
    _loadRole();
    _stream = getData();
  }

  Future<void> _loadRole() async {
    final info = UserInfo();
    final r = await info.getRole() ?? '';
    if (!mounted) return;
    setState(() => _role = r.toLowerCase());
  }

  bool get _canManage => _role == 'admin' || _role == 'petugas';

  Stream<Jadwal> getData() async* {
    final data = await JadwalService().getById(widget.jadwal.id.toString());
    yield data;
  }

  // === FIELD STYLE SAMA KAYAK PEGAWAI DETAIL ===
  Widget _infoField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: AppColor.gray200,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColor.background, width: 1),
            ),
            child: Text(value, style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundBlue,
      appBar: AppBar(
        backgroundColor: AppColor.backgroundBlue,
        elevation: 0,
        foregroundColor: AppColor.black,
        centerTitle: true,
        title: const Text(
          "Detail Jadwal Dokter",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: StreamBuilder<Jadwal>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Data Tidak Ditemukan'));
          }

          final j = snapshot.data!;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              child: Column(
                children: [
                  // ===== CARD DETAIL JADWAL =====
                  Card(
                    color: AppColor.whiteBlue,
                    elevation: 1.5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 18,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _infoField("Nama Dokter", j.namaDokter),
                          _infoField("Poli", j.poli),
                          _infoField("Hari", j.hari),
                          _infoField(
                            "Jam Praktik",
                            "${j.jamMulai} - ${j.jamSelesai}",
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ===== TOMBOL (SAMA KAYAK PEGAWAI) =====
                  if (_canManage)
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColor.mediumBlue,
                                foregroundColor: AppColor.background,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              onPressed: () async {
                                final updated = await Navigator.push<Jadwal>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => JadwalUpdateForm(jadwal: j),
                                  ),
                                );
                                if (updated != null && mounted) {
                                  setState(() => _stream = getData());
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Data berhasil diubah"),
                                    ),
                                  );
                                }
                              },
                              child: const Text('Ubah'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColor.redColor,
                                foregroundColor: AppColor.background,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              onPressed: () async {
                                final ok = await showDialog<bool>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text("Konfirmasi"),
                                    content: const Text(
                                      "Yakin ingin menghapus jadwal ini?",
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text("Batal"),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColor.redColor,
                                        ),
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text("Hapus"),
                                      ),
                                    ],
                                  ),
                                );

                                if (ok == true) {
                                  await JadwalService().hapus(j);
                                  if (!mounted) return;
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const JadwalPage(),
                                    ),
                                    (route) => false,
                                  );
                                }
                              },
                              child: const Text('Hapus'),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
