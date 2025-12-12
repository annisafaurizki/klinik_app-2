import 'package:flutter/material.dart';
import '../../model/pegawai.dart';
import '../../service/pegawai_service.dart';
import 'pegawai_update_form.dart';
import 'pegawai_page.dart';

class PegawaiDetail extends StatelessWidget {
  final Pegawai pegawai;

  const PegawaiDetail({super.key, required this.pegawai});

  Future<bool?> _confirm(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Konfirmasi"),
        content: const Text("Hapus data pegawai ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = [
      "NIP         : ${pegawai.nip}",
      "Nama        : ${pegawai.nama}",
      "Tgl Lahir   : ${pegawai.tanggalLahir}",
      "Telepon     : ${pegawai.nomorTelepon}",
      "Email       : ${pegawai.email}",
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Detail Pegawai")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final s in item)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(s, style: const TextStyle(fontSize: 16)),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Tombol UBAH
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: () async {
                    final updated = await Navigator.push<Pegawai>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PegawaiUpdateForm(pegawai: pegawai),
                      ),
                    );
                    if (updated != null && context.mounted) {
                      // Sederhana: balik ke list + info
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const PegawaiPage()),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Data pegawai diperbarui"),
                        ),
                      );
                    }
                  },
                  child: const Text("Ubah"),
                ),

                // Tombol HAPUS
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () async {
                    final ok = await _confirm(context);
                    if (ok == true && context.mounted) {
                      // panggil API hapus
                      await PegawaiService().hapus(pegawai);

                      // balik ke list
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const PegawaiPage()),
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Pegawai dihapus")),
                      );
                    }
                  },
                  child: const Text("Hapus"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
