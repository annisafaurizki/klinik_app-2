import 'package:flutter/material.dart';
import 'package:klinik_app/app/constants/app_color.dart';
import 'package:klinik_app/app/constants/app_image.dart';
import 'package:klinik_app/ui/poli_detail.dart';

import '../model/poli.dart';
import '../service/poli_service.dart';
import 'poli_form.dart';

class PoliPage extends StatefulWidget {
  const PoliPage({super.key});

  @override
  State<PoliPage> createState() => _PoliPageState();
}

class _PoliPageState extends State<PoliPage> {
  Stream<List<Poli>> getList() async* {
    final List<Poli> data = await PoliService().listData();
    yield data;
  }

  Future<void> _bukaForm() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const PoliForm()),
    );

    if (changed == true && mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // 🔥 BIAR GRADIENT TEMBUS KE APPBAR

      appBar: AppBar(
        backgroundColor: Colors.transparent, // 🔥 transparan
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.black,
        title: const Text(
          'Data Poli',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          GestureDetector(
            onTap: _bukaForm,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Icon(Icons.add),
            ),
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
          child: StreamBuilder<List<Poli>>(
            stream: getList(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text(snapshot.error.toString()));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final data = snapshot.data ?? [];
              if (data.isEmpty) {
                return const Center(child: Text('Data Poli Kosong'));
              }

              return Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.builder(
                  itemCount: data.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    final poli = data[index];

                    return InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PoliDetail(poli: poli),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 222, 235, 247),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColor.white, width: 1),
                        ),
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Image.asset(AppImage.kHeartBeat),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              poli.namaPoli,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
