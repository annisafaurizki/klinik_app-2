import 'package:flutter/material.dart';
import '../../model/jadwal.dart';
import '../../service/jadwal_service.dart';
import '../../widget/sidebar.dart';
import 'jadwal_form.dart';
import 'jadwal_detail.dart';

class JadwalPage extends StatefulWidget {
  const JadwalPage({super.key});

  @override
  State<JadwalPage> createState() => _JadwalPageState();
}

class _JadwalPageState extends State<JadwalPage> {
  // ambil list jadwal dari API
  Stream<List<Jadwal>> getList() async* {
    final data = await JadwalService().listData();
    yield data;
  }

  Future<void> _bukaFormTambah() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        // ❗ DI SINI TIDAK ADA `jadwal: ...`
        builder: (_) => const JadwalForm(),
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
        title: const Text("Jadwal Dokter"),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _bukaFormTambah),
        ],
      ),
      body: StreamBuilder<List<Jadwal>>(
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
            return const Center(child: Text("Belum ada jadwal dokter"));
          }

          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (ctx, i) {
              final j = list[i];
              return Card(
                child: ListTile(
                  title: Text("${j.namaDokter} - ${j.poli}"),
                  subtitle: Text("${j.hari}, ${j.jamMulai} - ${j.jamSelesai}"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final changed = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => JadwalDetail(jadwal: j),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _bukaFormTambah,
        child: const Icon(Icons.add),
      ),
    );
  }
}
