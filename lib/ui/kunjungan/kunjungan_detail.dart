import 'package:flutter/material.dart';
import '../../model/kunjungan.dart';
import '../../service/kunjungan_service.dart';
import '../../helpers/user_info.dart';
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
    // hanya dokter yang boleh ubah/hapus, dan readOnly = false
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

    return Scaffold(
      appBar: AppBar(title: const Text("Detail Kunjungan")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              "Data Kunjungan",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _row("Tanggal", k.tanggal),
            _row("No. RM", k.nomorRm),
            _row("Nama Pasien", k.namaPasien),
            _row("Poli", k.poli),
            _row("Dokter", k.dokter),
            _row("Keluhan", k.keluhan),
            _row("Diagnosa", k.diagnosa),
            _row("Resep", k.resep),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),

            const Text(
              "Rekam Medis Detail",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _row(
              "Tekanan Darah",
              k.tekananDarah.isEmpty ? '-' : k.tekananDarah,
            ),
            _row("Suhu", k.suhu.isEmpty ? '-' : "${k.suhu} °C"),
            _row("Berat", k.berat.isEmpty ? '-' : "${k.berat} kg"),
            _row("Tinggi", k.tinggi.isEmpty ? '-' : "${k.tinggi} cm"),
            _row("Alergi", k.alergi.isEmpty ? '-' : k.alergi),
            _row("Catatan", k.catatan.isEmpty ? '-' : k.catatan),

            const SizedBox(height: 24),

            if (_bolehEditHapus)
              Column(
                children: [
                  // tombol cetak resep
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text("Cetak Resep"),
                      onPressed: _cetakResep,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        onPressed: () async {
                          // TODO: kalau nanti mau dihubungkan ke KunjunganUpdateForm,
                          // ganti isi onPressed ini dengan push ke form update.
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Form ubah kunjungan belum dihubungkan",
                              ),
                            ),
                          );
                        },
                        child: const Text("Ubah"),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
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
                                  onPressed: () => Navigator.pop(context, true),
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
                        child: const Text("Hapus"),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              "$label :",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
