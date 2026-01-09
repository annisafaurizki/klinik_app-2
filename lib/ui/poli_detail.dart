import 'package:flutter/material.dart';
import 'package:klinik_app/app/constants/app_color.dart';

import '../model/poli.dart';
import '../service/poli_service.dart';
import 'poli_page.dart';
import 'poli_update_form.dart';

class PoliDetail extends StatefulWidget {
  final Poli poli;

  const PoliDetail({super.key, required this.poli});

  @override
  State<PoliDetail> createState() => _PoliDetailState();
}

class _PoliDetailState extends State<PoliDetail> {
  Stream<Poli> getData() async* {
    final Poli data = await PoliService().getById(widget.poli.id.toString());
    yield data;
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
          "Detail Poli",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
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
          child: StreamBuilder<Poli>(
            stream: getData(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text(snapshot.error.toString()));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData) {
                return const Center(child: Text('Data Tidak Ditemukan'));
              }

              final poli = snapshot.data!;

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // ===== CARD DETAIL =====
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 222, 235, 247),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColor.background),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Nama Poli",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            poli.namaPoli,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ===== BUTTON ACTION =====
                    Row(
                      children: [
                        Expanded(child: _tombolUbah(poli)),
                        const SizedBox(width: 12),
                        Expanded(child: _tombolHapus(poli)),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _tombolUbah(Poli poli) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PoliUpdateForm(poli: poli)),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      icon: const Icon(Icons.edit, size: 18),
      label: const Text("Ubah", style: TextStyle(color: AppColor.white)),
    );
  }

  Widget _tombolHapus(Poli poli) {
    return ElevatedButton.icon(
      onPressed: () {
        final alertDialog = AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 8),
              Text("Konfirmasi"),
            ],
          ),
          content: const Text(
            "Apakah kamu yakin ingin menghapus data ini?\n"
            "Tindakan ini tidak dapat dibatalkan.",
            style: TextStyle(fontSize: 14),
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.redStatus,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                await PoliService().hapus(poli).then((value) {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const PoliPage()),
                  );
                });
              },
              icon: const Icon(Icons.delete, size: 18),
              label: const Text("Hapus"),
            ),
          ],
        );

        showDialog(context: context, builder: (_) => alertDialog);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      icon: const Icon(Icons.delete, size: 18),
      label: const Text("Hapus", style: TextStyle(color: AppColor.white)),
    );
  }
}
