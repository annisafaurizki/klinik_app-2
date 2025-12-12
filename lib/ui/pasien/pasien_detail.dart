import 'package:flutter/material.dart';
import 'package:klinik_app/app/constants/app_color.dart';

// Riwayat kunjungan
import '../../model/kunjungan.dart';
import '../../model/pasien.dart';
import '../../service/kunjungan_service.dart';
import '../../service/pasien_service.dart';
import '../../utils/pdf_helper.dart';
import '../kunjungan/kunjungan_detail.dart';
import '../pasien/pasien_page.dart';
import '../pasien/pasien_update_form.dart';

class PasienDetail extends StatefulWidget {
  final Pasien pasien;

  const PasienDetail({super.key, required this.pasien});

  @override
  State<PasienDetail> createState() => _PasienDetailState();
}

class _PasienDetailState extends State<PasienDetail> {
  Stream<Pasien> getData() async* {
    final data = await PasienService().getById(widget.pasien.id.toString());
    yield data;
  }

  Future<List<Kunjungan>> _riwayatKunjungan(String nomorRm) {
    return KunjunganService().listByNomorRm(nomorRm);
  }

  String _formatDate(String raw) {
    if (raw.trim().isEmpty) return '-';
    try {
      final dt = DateTime.parse(raw);
      final d = dt.day.toString().padLeft(2, '0');
      final m = dt.month.toString().padLeft(2, '0');
      final y = dt.year.toString();
      return '$d-$m-$y';
    } catch (_) {
      return raw;
    }
  }

  Widget _rowField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
          const Text(
            ':',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const cardFill = Color.fromARGB(255, 222, 235, 247);

    return Scaffold(
      backgroundColor: AppColor.backgroundBlue,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColor.backgroundBlue,
        foregroundColor: AppColor.black,
        elevation: 0,
        title: const Text(
          "Detail Pasien",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: StreamBuilder<Pasien>(
        stream: getData(),
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

          final p = snapshot.data!;
          final inisial = (p.nama.isNotEmpty ? p.nama[0] : '?').toUpperCase();

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==== DATA PASIEN (CARD + KOTAK FOTO KANAN) ====
                Container(
                  width: double.infinity,
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
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // field
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _rowField('No. RM', p.nomorRm),
                            _rowField('Nama', p.nama),
                            _rowField('Tgl Lahir', _formatDate(p.tanggalLahir)),
                            _rowField('Telepon', p.nomorTelepon),
                            _rowField('Alamat', p.alamat),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),

                      // kotak foto kanan
                      Container(
                        width: 100,
                        height: 130,
                        decoration: BoxDecoration(
                          color: AppColor.gray100,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColor.background,
                            width: 1,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          inisial,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColor.grayText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ==== TOMBOL (layout sama, warna lebih soft) ====
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                            0xFFE6F4EA,
                          ), // soft green
                          foregroundColor: const Color(0xFF1E6F3D),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(
                              color: AppColor.background,
                              width: 1,
                            ),
                          ),
                        ),
                        child: const Text(
                          "Ubah",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        onPressed: () async {
                          final updated = await Navigator.push<Pasien>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PasienUpdateForm(pasien: p),
                            ),
                          );

                          if (updated != null && context.mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PasienDetail(pasien: updated),
                              ),
                            );

                            Future.microtask(() {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Data pasien diperbarui"),
                                ),
                              );
                            });
                          }
                        },
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFDECEC), // soft red
                          foregroundColor: const Color(0xFFB42318),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(
                              color: AppColor.background,
                              width: 1,
                            ),
                          ),
                        ),
                        child: const Text(
                          "Hapus",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        onPressed: () async {
                          final ok = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text("Konfirmasi"),
                              content: const Text(
                                "Yakin ingin menghapus data pasien ini?",
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
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text("Hapus"),
                                ),
                              ],
                            ),
                          );

                          if (ok == true) {
                            await PasienService().hapus(p);
                            if (!mounted) return;
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PasienPage(),
                              ),
                              (route) => false,
                            );
                          }
                        },
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEAF2FF), // soft blue
                          foregroundColor: const Color(0xFF1D4ED8),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(
                              color: AppColor.background,
                              width: 1,
                            ),
                          ),
                        ),
                        child: const Text(
                          "Cetak Kartu",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        onPressed: () async {
                          await PdfHelper.cetakKartuPasien(p);
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                const Divider(color: AppColor.black),
                const SizedBox(height: 8),

                // ==== RIWAYAT KUNJUNGAN (CARD LIST) ====
                const Text(
                  "Riwayat Kunjungan",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                Expanded(
                  child: FutureBuilder<List<Kunjungan>>(
                    future: _riwayatKunjungan(p.nomorRm),
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snap.hasError) {
                        return Center(child: Text(snap.error.toString()));
                      }
                      final list = snap.data ?? [];
                      if (list.isEmpty) {
                        return Center(
                          child: Text('Belum ada riwayat kunjungan'),
                        );
                      }

                      return ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (context, i) {
                          final k = list[i];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => KunjunganDetail(
                                      kunjungan: k,
                                      readOnly: true,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: cardFill,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppColor.background,
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: AppColor.gray100,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.assignment_outlined,
                                        color: AppColor.grayText,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${k.tanggal} - ${k.poli} (${k.dokter})",
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            "Keluhan: ${k.keluhan}",
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.chevron_right,
                                      color: AppColor.grayText,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
