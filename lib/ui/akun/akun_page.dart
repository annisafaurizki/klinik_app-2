import 'package:flutter/material.dart';
import '../../model/akun.dart';
import '../../service/akun_service.dart';
import '../../widget/sidebar.dart';
import 'akun_form.dart';

class AkunPage extends StatefulWidget {
  const AkunPage({super.key});

  @override
  State<AkunPage> createState() => _AkunPageState();
}

class _AkunPageState extends State<AkunPage> {
  Stream<List<Akun>> getList() async* {
    final data = await AkunService().listData();
    yield data;
  }

  Future<void> _bukaForm({Akun? akun}) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AkunForm(akun: akun)),
    );
    if (changed == true && mounted) {
      setState(() {}); // rebuild -> getList() dipanggil ulang
    }
  }

  Future<void> _hapus(Akun akun) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Konfirmasi"),
        content: Text("Hapus akun '${akun.username}' ?"),
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

    if (ok == true) {
      try {
        await AkunService().hapus(akun.id!);
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Akun berhasil dihapus")));
        setState(() {});
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal menghapus akun: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Sidebar(),
      appBar: AppBar(
        title: const Text("Manajemen Akun"),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () => _bukaForm()),
        ],
      ),
      body: StreamBuilder<List<Akun>>(
        stream: getList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          final list = snapshot.data ?? [];
          if (list.isEmpty) {
            return const Center(child: Text("Belum ada akun"));
          }

          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (ctx, i) {
              final a = list[i];
              return Card(
                child: ListTile(
                  title: Text(a.nama),
                  subtitle: Text("${a.username} • ${a.role.toUpperCase()}"),
                  onTap: () => _bukaForm(akun: a), // edit
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _hapus(a),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _bukaForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
