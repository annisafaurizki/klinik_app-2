import 'package:flutter/material.dart';
import 'package:klinik_app/app/constants/app_color.dart';

import '../model/poli.dart';
import '../service/poli_service.dart';
import 'poli_detail.dart';

class PoliForm extends StatefulWidget {
  const PoliForm({super.key});

  @override
  _PoliFormState createState() => _PoliFormState();
}

class _PoliFormState extends State<PoliForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaPoliCtrl = TextEditingController();

  @override
  void dispose() {
    _namaPoliCtrl.dispose();
    super.dispose();
  }

  String? _req(String? v) =>
      (v == null || v.trim().isEmpty) ? "Wajib diisi" : null;

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide(color: color, width: 1),
  );

  @override
  Widget build(BuildContext context) {
    const fieldFillColor = Color.fromARGB(255, 222, 235, 247);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColor.black,
        title: const Text(
          "Tambah Poli",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColor.backgroundBlue, AppColor.backgroundBlue],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  // ===== HEADER FORM =====
                  Center(
                    child: Column(
                      children: const [
                        CircleAvatar(
                          radius: 42,
                          backgroundColor: Color.fromARGB(80, 33, 150, 243),
                          child: Icon(
                            Icons.local_hospital,
                            size: 32,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Data Poli Baru",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ===== FIELD NAMA POLI =====
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextFormField(
                      controller: _namaPoliCtrl,
                      validator: _req,
                      decoration: InputDecoration(
                        labelText: "Nama Poli",
                        filled: true,
                        fillColor: fieldFillColor,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        border: _border(AppColor.background),
                        enabledBorder: _border(AppColor.background),
                        focusedBorder: _border(AppColor.blue),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ===== TOMBOL SIMPAN =====
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final poli = Poli(
                            namaPoli: _namaPoliCtrl.text.trim(),
                          );

                          final saved = await PoliService().simpan(poli);

                          if (!mounted) return;

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PoliDetail(poli: saved),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.blue,
                        foregroundColor: AppColor.background,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Simpan",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
