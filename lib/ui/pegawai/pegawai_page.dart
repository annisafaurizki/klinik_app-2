import 'package:flutter/material.dart';
import 'package:klinik_app/app/constants/app_color.dart';

import '../../model/pegawai.dart';
import '../../service/pegawai_service.dart';
import '../../widget/sidebar.dart';
import 'pegawai_detail.dart';
import 'pegawai_form.dart';

class PegawaiPage extends StatefulWidget {
  const PegawaiPage({super.key});

  @override
  State<PegawaiPage> createState() => _PegawaiPageState();
}

class _PegawaiPageState extends State<PegawaiPage> {
  final TextEditingController _searchController = TextEditingController();
  String _keyword = '';

  Stream<List<Pegawai>> getList() async* {
    final data = await PegawaiService().listData();
    yield data;
  }

  Future<void> _bukaForm({Pegawai? pegawai}) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => PegawaiForm(pegawai: pegawai)),
    );
    if (changed == true && mounted) setState(() {});
  }

  Future<void> _bukaDetail(Pegawai pegawai) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => PegawaiDetail(pegawai: pegawai)),
    );
    if (changed == true && mounted) setState(() {});
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Sidebar(),

      // 🔥 background sama seperti halaman akun
      backgroundColor: AppColor.backgroundBlue,

      appBar: AppBar(
        backgroundColor: AppColor.backgroundBlue,
        foregroundColor: AppColor.black,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Data Pegawai",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _bukaForm(),
            color: AppColor.black,
          ),
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

          final list = snapshot.data ?? [];
          if (list.isEmpty) {
            return const Center(child: Text("Data pegawai kosong"));
          }

          final kw = _keyword.toLowerCase();
          final filtered = kw.isEmpty
              ? list
              : list.where((p) {
                  return p.nama.toLowerCase().contains(kw) ||
                      p.nip.toLowerCase().contains(kw) ||
                      p.nomorTelepon.toLowerCase().contains(kw);
                }).toList();

          return Column(
            children: [
              // 🔍 Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _keyword = v),
                  decoration: InputDecoration(
                    hintText: "Cari nama, NIP, atau telepon...",
                    prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                    filled: true,
                    fillColor: const Color.fromARGB(255, 222, 235, 247),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 0,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColor.background),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColor.background),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColor.background,
                        width: 1.4,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 4),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) {
                    final p = filtered[i];
                    final inisial = (p.nama.isNotEmpty ? p.nama[0] : '?')
                        .toUpperCase();

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _bukaDetail(p),
                        child: Container(
                          padding: const EdgeInsets.all(14),

                          // 🎨 Card styling sama seperti halaman akun
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 222, 235, 247),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColor.background,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),

                          child: Row(
                            children: [
                              // Avatar kotak
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  color: AppColor.backgroundBlue,
                                  alignment: Alignment.center,
                                  child: Text(
                                    inisial,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p.nama,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.badge_outlined,
                                          size: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            p.nip,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.phone_outlined,
                                          size: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            p.nomorTelepon,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
