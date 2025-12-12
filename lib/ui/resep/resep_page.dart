import 'package:flutter/material.dart';

import '../../widget/sidebar.dart';
import '../../model/kunjungan.dart';
import '../../service/kunjungan_service.dart';
import '../../utils/pdf_helper.dart';
import '../kunjungan/kunjungan_detail.dart';

class ResepPage extends StatefulWidget {
  const ResepPage({super.key});

  @override
  State<ResepPage> createState() => _ResepPageState();
}

class _ResepPageState extends State<ResepPage> {
  Future<List<Kunjungan>> _loadResep() async {
    final all = await KunjunganService().listData();
    // ambil hanya yang punya resep (nggak kosong)
    return all.where((k) => k.resep.trim().isNotEmpty).toList();
  }

  Future<void> _refresh() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Sidebar(),
      appBar: AppBar(title: const Text("Resep Elektronik")),
      body: FutureBuilder<List<Kunjungan>>(
        future: _loadResep(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final list = snapshot.data ?? [];
          if (list.isEmpty) {
            return const Center(child: Text("Belum ada resep dari dokter"));
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: list.length,
              itemBuilder: (ctx, i) {
                final k = list[i];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    title: Text(k.namaPasien),
                    subtitle: Text(
                      "Tgl: ${k.tanggal} • Poli: ${k.poli} • Dokter: ${k.dokter}",
                    ),
                    onTap: () {
                      // Lihat detail kunjungan (read only buat apoteker)
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              KunjunganDetail(kunjungan: k, readOnly: true),
                        ),
                      );
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.print),
                      tooltip: "Cetak Resep",
                      onPressed: () async {
                        try {
                          await PdfHelper.cetakResep(k);
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Gagal mencetak resep: $e")),
                          );
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
