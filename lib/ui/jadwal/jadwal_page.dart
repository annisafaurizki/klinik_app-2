import 'package:flutter/material.dart';
import 'package:klinik_app/app/constants/app_color.dart';

import '../../model/jadwal.dart';
import '../../service/jadwal_service.dart';
import 'jadwal_detail.dart';
import 'jadwal_form.dart';

class JadwalPage extends StatefulWidget {
  const JadwalPage({super.key});

  @override
  State<JadwalPage> createState() => _JadwalPageState();
}

class _JadwalPageState extends State<JadwalPage> {
  final TextEditingController _searchController = TextEditingController();
  String _keyword = '';

  Stream<List<Jadwal>> getList() async* {
    final data = await JadwalService().listData();
    yield data;
  }

  Future<void> _bukaFormTambah() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const JadwalForm()),
    );
    if (changed == true && mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: AppColor.black,
        title: const Text(
          "Jadwal Dokter",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _bukaFormTambah),
        ],
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [AppColor.backgroundBlue, AppColor.whiteBlue],
          ),
        ),
        child: SafeArea(
          child: StreamBuilder<List<Jadwal>>(
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

              final kw = _keyword.toLowerCase();
              final filtered = kw.isEmpty
                  ? list
                  : list.where((j) {
                      return j.namaDokter.toLowerCase().contains(kw) ||
                          j.poli.toLowerCase().contains(kw) ||
                          j.hari.toLowerCase().contains(kw);
                    }).toList();

              return Column(
                children: [
                  // 🔍 SEARCH BAR
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() {
                          _keyword = val.trim();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Cari dokter, poli, atau hari...",
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: const Color.fromARGB(255, 222, 235, 247),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 0,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColor.background,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColor.background,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColor.background,
                            width: 1.4,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),

                  // 📋 LIST JADWAL (PAKAI BORDER)
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                      itemCount: filtered.length,
                      itemBuilder: (ctx, i) {
                        final j = filtered[i];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 222, 235, 247),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColor
                                  .background, // 🔥 SAMA KAYAK SEARCH BAR
                              width: 1,
                            ),
                          ),
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            title: Text(
                              "${j.namaDokter} - ${j.poli}",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              "${j.hari}, ${j.jamMulai} - ${j.jamSelesai}",
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () async {
                              final changed = await Navigator.push<bool>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => JadwalDetail(jadwal: j),
                                ),
                              );
                              if (changed == true && mounted) {
                                setState(() {});
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
