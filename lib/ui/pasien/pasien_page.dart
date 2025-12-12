import 'package:flutter/material.dart';
import '../../model/pasien.dart';
import '../../service/pasien_service.dart';
import '../../widget/sidebar.dart';
import 'pasien_form.dart';
import 'pasien_detail.dart';

class PasienPage extends StatefulWidget {
  const PasienPage({super.key});

  @override
  State<PasienPage> createState() => _PasienPageState();
}

class _PasienPageState extends State<PasienPage> {
  // ambil list pasien dari API
  Stream<List<Pasien>> getList() async* {
    final data = await PasienService().listData();
    yield data;
  }

  Future<void> _bukaFormTambah() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const PasienForm(), // ❗ TANPA parameter `pasien:`
      ),
    );
    if (changed == true && mounted) {
      setState(() {}); // refresh list kalau ada perubahan
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Sidebar(),
      appBar: AppBar(
        title: const Text("Data Pasien"),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _bukaFormTambah),
        ],
      ),
      body: StreamBuilder<List<Pasien>>(
        stream: getList(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.connectionState == ConnectionState.active) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Data pasien kosong"));
          }

          final items = snapshot.data!;

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (ctx, i) {
              final p = items[i];
              return Card(
                child: ListTile(
                  title: Text(p.nama),
                  subtitle: Text("RM: ${p.nomorRm} • Telp: ${p.nomorTelepon}"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PasienDetail(pasien: p),
                      ),
                    );
                    if (mounted) setState(() {}); // refresh setelah ubah/hapus
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
