import 'package:flutter/material.dart';
import '../../model/pasien.dart';
import '../../service/pasien_service.dart';
import '../pasien/pasien_update_form.dart';
import '../pasien/pasien_page.dart';
import '../../utils/pdf_helper.dart';

// Riwayat kunjungan
import '../../model/kunjungan.dart';
import '../../service/kunjungan_service.dart';
import '../kunjungan/kunjungan_detail.dart';

class PasienDetail extends StatefulWidget {
  final Pasien pasien;

  const PasienDetail({super.key, required this.pasien});

  @override
  State<PasienDetail> createState() => _PasienDetailState();
}

class _PasienDetailState extends State<PasienDetail> {
  // ambil data pasien terbaru
  Stream<Pasien> getData() async* {
    final data = await PasienService().getById(widget.pasien.id.toString());
    yield data;
  }

  // ambil riwayat kunjungan berdasarkan nomor RM pasien ini
  Future<List<Kunjungan>> _riwayatKunjungan(String nomorRm) {
    return KunjunganService().listByNomorRm(nomorRm);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detail Pasien")),
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

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==== DATA PASIEN ====
                Text(
                  "No. RM   : ${p.nomorRm}",
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  "Nama     : ${p.nama}",
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  "Tgl Lahir: ${p.tanggalLahir}",
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  "Telepon  : ${p.nomorTelepon}",
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  "Alamat   : ${p.alamat}",
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 24),

                // ==== TOMBOL UBAH / HAPUS PASIEN + CETAK KARTU ====
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text("Ubah"),
                      onPressed: () async {
                        final updated = await Navigator.push<Pasien>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PasienUpdateForm(pasien: p),
                          ),
                        );
                        if (updated != null && mounted) {
                          setState(() {}); // refresh detail
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Data pasien diperbarui"),
                            ),
                          );
                        }
                      },
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text("Hapus"),
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
                                onPressed: () => Navigator.pop(context, false),
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
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey,
                      ),
                      child: const Text("Cetak Kartu"),
                      onPressed: () async {
                        await PdfHelper.cetakKartuPasien(p);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 8),

                // ==== RIWAYAT KUNJUNGAN (READ ONLY) ====
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
                        return const Center(
                          child: Text("Belum ada riwayat kunjungan"),
                        );
                      }

                      return ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (context, i) {
                          final k = list[i];
                          return Card(
                            child: ListTile(
                              title: Text(
                                "${k.tanggal} - ${k.poli} (${k.dokter})",
                              ),
                              subtitle: Text("Keluhan: ${k.keluhan}"),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                // DETAIL KUNJUNGAN HANYA LIHAT (tanpa edit/hapus)
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
