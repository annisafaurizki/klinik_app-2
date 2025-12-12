import 'package:flutter/material.dart';
import '../../model/pegawai.dart';
import '../../service/pegawai_service.dart';
import '../../widget/sidebar.dart';
import 'pegawai_form.dart';
import 'pegawai_detail.dart';

class PegawaiPage extends StatefulWidget {
  const PegawaiPage({super.key});

  @override
  State<PegawaiPage> createState() => _PegawaiPageState();
}

class _PegawaiPageState extends State<PegawaiPage> {
  // ambil list pegawai dari API
  Stream<List<Pegawai>> getList() async* {
    final data = await PegawaiService().listData();
    yield data;
  }

  // buka form tambah / edit
  Future<void> _bukaForm({Pegawai? pegawai}) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => PegawaiForm(pegawai: pegawai)),
    );
    if (changed == true && mounted) {
      setState(() {}); // reload list
    }
  }

  // buka detail
  Future<void> _bukaDetail(Pegawai pegawai) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => PegawaiDetail(pegawai: pegawai)),
    );
    if (changed == true && mounted) {
      setState(() {}); // reload kalau ada ubah/hapus di detail
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Sidebar(),
      appBar: AppBar(
        title: const Text("Data Pegawai"),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () => _bukaForm()),
        ],
      ),
      body: StreamBuilder<List<Pegawai>>(
        stream: getList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.connectionState == ConnectionState.active) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text("Data pegawai kosong"));
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (ctx, i) {
              final p = items[i];
              return Card(
                child: ListTile(
                  title: Text(p.nama),
                  subtitle: Text("NIP: ${p.nip} • Telp: ${p.nomorTelepon}"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _bukaDetail(p),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
