import 'package:flutter/material.dart';
import 'package:klinik_app/app/constants/app_color.dart';

import '../../helpers/user_info.dart';
import '../../model/kunjungan.dart';
import '../../service/kunjungan_service.dart';
import '../../utils/pdf_helper.dart';

class KunjunganDetail extends StatefulWidget {
  final Kunjungan kunjungan;

  /// kalau true, tombol Ubah & Hapus disembunyikan (read-only, misal dari detail pasien)
  final bool readOnly;

  const KunjunganDetail({
    super.key,
    required this.kunjungan,
    this.readOnly = false,
  });

  @override
  State<KunjunganDetail> createState() => _KunjunganDetailState();
}

class _KunjunganDetailState extends State<KunjunganDetail> {
  late Kunjungan _data;
  String _role = '';

  @override
  void initState() {
    super.initState();
    _data = widget.kunjungan;
    _loadRole();
  }

  Future<void> _loadRole() async {
    final info = UserInfo();
    final r = await info.getRole() ?? '';
    if (!mounted) return;
    setState(() {
      _role = r.toLowerCase();
    });
  }

  bool get _bolehEditHapus {
    if (widget.readOnly) return false;
    return _role == 'dokter';
  }

  Future<void> _cetakResep() async {
    try {
      await PdfHelper.cetakResep(_data);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Resep berhasil dibuat")));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal mencetak resep: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final k = _data;
    const cardFill = Color.fromARGB(255, 222, 235, 247);

    return Scaffold(
      backgroundColor: AppColor.backgroundBlue,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColor.backgroundBlue,
        foregroundColor: AppColor.black,
        elevation: 0,
        title: const Text(
          "Detail Kunjungan",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // ===== CARD 1: DATA KUNJUNGAN =====
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cardFill,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColor.background, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Data Kunjungan",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  _row("Tanggal", k.tanggal),
                  _row("No. RM", k.nomorRm),
                  _row("Nama Pasien", k.namaPasien),
                  _row("Poli", k.poli),
                  _row("Dokter", k.dokter),
                  _row("Keluhan", k.keluhan),
                  _row("Diagnosa", k.diagnosa),
                  _row("Resep", k.resep),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ===== CARD 2: REKAM MEDIS =====
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cardFill,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColor.background, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Rekam Medis Detail",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  _row(
                    "Tekanan Darah",
                    k.tekananDarah.isEmpty ? '-' : k.tekananDarah,
                  ),
                  _row("Suhu", k.suhu.isEmpty ? '-' : "${k.suhu} °C"),
                  _row("Berat", k.berat.isEmpty ? '-' : "${k.berat} kg"),
                  _row("Tinggi", k.tinggi.isEmpty ? '-' : "${k.tinggi} cm"),
                  _row("Alergi", k.alergi.isEmpty ? '-' : k.alergi),
                  _row("Catatan", k.catatan.isEmpty ? '-' : k.catatan),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ===== ACTIONS (LOGIC TETEP) =====
            if (_bolehEditHapus)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cardFill,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColor.background, width: 1),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.picture_as_pdf),
                        label: const Text("Cetak Resep"),
                        onPressed: _cetakResep,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEAF2FF),
                          foregroundColor: const Color(0xFF1D4ED8),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(
                              color: AppColor.background,
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE6F4EA),
                              foregroundColor: const Color(0xFF1E6F3D),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 11),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(
                                  color: AppColor.background,
                                  width: 1,
                                ),
                              ),
                            ),
                            onPressed: () async {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Form ubah kunjungan belum dihubungkan",
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              "Ubah",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFDECEC),
                              foregroundColor: const Color(0xFFB42318),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 11),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(
                                  color: AppColor.background,
                                  width: 1,
                                ),
                              ),
                            ),
                            onPressed: () async {
                              final ok = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text("Konfirmasi"),
                                  content: const Text(
                                    "Yakin ingin menghapus kunjungan ini?",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text("Batal"),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text("Hapus"),
                                    ),
                                  ],
                                ),
                              );

                              if (ok == true) {
                                await KunjunganService().hapus(_data);
                                if (!mounted) return;
                                Navigator.pop(context, true);
                              }
                            },
                            child: const Text(
                              "Hapus",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 118,
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
          const Text(
            ':',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
