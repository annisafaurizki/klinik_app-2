import 'package:flutter/material.dart';
import '../../model/jadwal.dart';
import '../../service/jadwal_service.dart';
import '../../helpers/user_info.dart';
import 'jadwal_update_form.dart';
import 'jadwal_page.dart';

class JadwalDetail extends StatefulWidget {
  final Jadwal jadwal;

  const JadwalDetail({super.key, required this.jadwal});

  @override
  State<JadwalDetail> createState() => _JadwalDetailState();
}

class _JadwalDetailState extends State<JadwalDetail> {
  String _role = '';
  late Stream<Jadwal> _stream;

  @override
  void initState() {
    super.initState();
    _loadRole();
    _stream = getData();
  }

  Future<void> _loadRole() async {
    final info = UserInfo();
    final r = await info.getRole() ?? '';
    if (!mounted) return;
    setState(() {
      _role = r.toLowerCase();
    });
  }

  bool get _canManage => _role == 'admin' || _role == 'petugas';

  Stream<Jadwal> getData() async* {
    final data = await JadwalService().getById(widget.jadwal.id.toString());
    yield data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detail Jadwal Dokter")),
      body: StreamBuilder<Jadwal>(
        stream: _stream,
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

          final j = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Nama Dokter : ${j.namaDokter}",
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  "Poli        : ${j.poli}",
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  "Hari        : ${j.hari}",
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  "Jam         : ${j.jamMulai} - ${j.jamSelesai}",
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 24),

                // tombol hanya muncul kalau admin/petugas
                if (_canManage)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: const Text("Ubah"),
                        onPressed: () async {
                          final updated = await Navigator.push<Jadwal>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => JadwalUpdateForm(jadwal: j),
                            ),
                          );
                          if (updated != null && mounted) {
                            setState(() {
                              _stream = getData(); // refresh data
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Data berhasil diubah"),
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
                                "Yakin ingin menghapus jadwal ini?",
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
                            await JadwalService().hapus(j);
                            if (!mounted) return;
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const JadwalPage(),
                              ),
                              (route) => false,
                            );
                          }
                        },
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
