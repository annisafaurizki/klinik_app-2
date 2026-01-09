import 'package:flutter/material.dart';
import 'package:klinik_app/app/constants/app_color.dart';

import '../../model/kunjungan.dart';
import '../../service/kunjungan_service.dart';
import 'kunjungan_detail.dart';
import 'kunjungan_form.dart';

class KunjunganPage extends StatefulWidget {
  const KunjunganPage({super.key});

  @override
  State<KunjunganPage> createState() => _KunjunganPageState();
}

class _KunjunganPageState extends State<KunjunganPage> {
  final TextEditingController _searchController = TextEditingController();
  String _keyword = '';

  Stream<List<Kunjungan>> getList() async* {
    final data = await KunjunganService().listData();
    yield data;
  }

  Future<void> _bukaFormTambah() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const KunjunganForm()),
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
        foregroundColor: AppColor.black,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Data Kunjungan",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _bukaFormTambah,
            color: AppColor.black,
          ),
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
          child: StreamBuilder<List<Kunjungan>>(
            stream: getList(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text(snapshot.error.toString()));
              }

              if (snapshot.connectionState == ConnectionState.waiting ||
                  snapshot.connectionState == ConnectionState.active) {
                return const Center(child: CircularProgressIndicator());
              }

              final all = snapshot.data ?? [];
              if (all.isEmpty) {
                return const Center(child: Text("Belum ada data kunjungan"));
              }

              final kw = _keyword.toLowerCase();
              final items = kw.isEmpty
                  ? all
                  : all.where((k) {
                      return k.namaPasien.toLowerCase().contains(kw) ||
                          k.poli.toLowerCase().contains(kw) ||
                          k.dokter.toLowerCase().contains(kw) ||
                          k.tanggal.toLowerCase().contains(kw);
                    }).toList();

              return Column(
                children: [
                  /// SEARCH BAR
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() => _keyword = val.trim());
                      },
                      decoration: InputDecoration(
                        hintText: "Cari pasien, poli, dokter, atau tanggal...",
                        prefixIcon: const Icon(Icons.search),
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
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide(
                            color: AppColor.background,
                            width: 1.4,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 4),

                  /// LISTVIEW
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      itemCount: items.length,
                      itemBuilder: (ctx, i) {
                        final k = items[i];
                        final inisial =
                            (k.namaPasien.isNotEmpty ? k.namaPasien[0] : '?')
                                .toUpperCase();

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () async {
                              final changed = await Navigator.push<bool>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => KunjunganDetail(kunjungan: k),
                                ),
                              );
                              if (changed == true && mounted) {
                                setState(() {});
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 222, 235, 247),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                border: Border.all(
                                  color: AppColor.background,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  /// INFO
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          k.namaPasien,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          "${k.poli} - ${k.dokter}",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          "Tanggal: ${k.tanggal}",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(width: 10),

                                  /// INISIAL
                                  Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: AppColor.gray100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      inisial,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color: AppColor.grayText,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 6),

                                  const Icon(
                                    Icons.chevron_right,
                                    size: 22,
                                    color: AppColor.grayText,
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
        ),
      ),
    );
  }
}
