import 'package:flutter/material.dart';
import '../../model/kunjungan.dart';
import '../../service/kunjungan_service.dart';
import '../../widget/sidebar.dart';
import 'kunjungan_form.dart';
import 'kunjungan_detail.dart';

class KunjunganPage extends StatefulWidget {
  const KunjunganPage({super.key});

  @override
  State<KunjunganPage> createState() => _KunjunganPageState();
}

class _KunjunganPageState extends State<KunjunganPage> {
  // ambil list kunjungan dari API
  Stream<List<Kunjungan>> getList() async* {
    final data = await KunjunganService().listData();
    yield data;
  }

  Future<void> _bukaFormTambah() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        // ❗ di sini TIDAK pakai `kunjungan: ...` lagi
        builder: (_) => const KunjunganForm(),
      ),
    );
    if (changed == true && mounted) {
      setState(() {}); // refresh list setelah ada perubahan
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Sidebar(),
      appBar: AppBar(
        title: const Text("Data Kunjungan"),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _bukaFormTambah),
        ],
      ),
      body: StreamBuilder<List<Kunjungan>>(
        stream: getList(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.connectionState == ConnectionState.active) {
            return const Center(child: CircularProgressIndicator());
          }

          final list = snapshot.data ?? [];
          if (list.isEmpty) {
            return const Center(child: Text("Belum ada data kunjungan"));
          }

          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (ctx, i) {
              final k = list[i];
              return Card(
                child: ListTile(
                  title: Text("${k.tanggal} - ${k.namaPasien}"),
                  subtitle: Text("${k.poli} (${k.dokter})"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    // buka detail kunjungan (bisa edit / hapus dari sana)
                    final changed = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => KunjunganDetail(kunjungan: k),
                      ),
                    );
                    if (changed == true && mounted) {
                      setState(() {}); // refresh setelah ubah/hapus
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
