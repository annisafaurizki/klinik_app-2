import 'package:flutter/material.dart';
import 'package:klinik_app/app/constants/app_color.dart';

import '../../model/jadwal.dart';
import '../../service/jadwal_service.dart';
import 'jadwal_page.dart';

class JadwalForm extends StatefulWidget {
  const JadwalForm({super.key});

  @override
  State<JadwalForm> createState() => _JadwalFormState();
}

class _JadwalFormState extends State<JadwalForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _namaDokterCtrl = TextEditingController();
  final TextEditingController _poliCtrl = TextEditingController();
  final TextEditingController _hariCtrl = TextEditingController();
  final TextEditingController _jamMulaiCtrl = TextEditingController();
  final TextEditingController _jamSelesaiCtrl = TextEditingController();

  String? _req(String? v) =>
      (v == null || v.trim().isEmpty) ? "Wajib diisi" : null;

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;

    final jadwal = Jadwal(
      namaDokter: _namaDokterCtrl.text.trim(),
      poli: _poliCtrl.text.trim(),
      hari: _hariCtrl.text.trim(),
      jamMulai: _jamMulaiCtrl.text.trim(),
      jamSelesai: _jamSelesaiCtrl.text.trim(),
    );

    await JadwalService().simpan(jadwal);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const JadwalPage()),
    );
  }

  // ===== BORDER STYLE (SAMA KAYAK PEGAWAI FORM) =====
  OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide(color: color, width: 1),
  );

  // ===== FIELD STYLE =====
  Widget _field(
    TextEditingController controller,
    String label, {
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        validator: _req,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: const Color.fromARGB(255, 222, 235, 247),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          suffixIcon: suffixIcon,
          border: _border(AppColor.background),
          enabledBorder: _border(AppColor.background),
          focusedBorder: _border(AppColor.blue),
        ),
      ),
    );
  }

  Widget _fieldJamMulai() {
    return _field(
      _jamMulaiCtrl,
      "Jam Mulai",
      readOnly: true,
      suffixIcon: const Icon(Icons.access_time),
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
          helpText: "Pilih Jam Mulai",
        );
        if (picked != null) {
          final formatted =
              "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
          setState(() => _jamMulaiCtrl.text = formatted);
        }
      },
    );
  }

  Widget _fieldJamSelesai() {
    return _field(
      _jamSelesaiCtrl,
      "Jam Selesai",
      readOnly: true,
      suffixIcon: const Icon(Icons.access_time),
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
          helpText: "Pilih Jam Selesai",
        );
        if (picked != null) {
          final formatted =
              "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
          setState(() => _jamSelesaiCtrl.text = formatted);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColor.black,
        title: const Text(
          "Tambah Jadwal Dokter",
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
                  _field(_namaDokterCtrl, "Nama Dokter"),
                  _field(_poliCtrl, "Poli"),
                  _field(_hariCtrl, "Hari"),
                  _fieldJamMulai(),
                  _fieldJamSelesai(),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _simpan,
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
