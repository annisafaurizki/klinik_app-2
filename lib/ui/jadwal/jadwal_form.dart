import 'package:flutter/material.dart';
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

  // ------------ FIELD TIME PICKER ------------

  Widget _fieldJamMulai() {
    return TextFormField(
      controller: _jamMulaiCtrl,
      readOnly: true,
      decoration: const InputDecoration(
        labelText: "Jam Mulai",
        border: OutlineInputBorder(),
        suffixIcon: Icon(Icons.access_time),
      ),
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
      validator: _req,
    );
  }

  Widget _fieldJamSelesai() {
    return TextFormField(
      controller: _jamSelesaiCtrl,
      readOnly: true,
      decoration: const InputDecoration(
        labelText: "Jam Selesai",
        border: OutlineInputBorder(),
        suffixIcon: Icon(Icons.access_time),
      ),
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
      validator: _req,
    );
  }

  // ------------ BUILD FORM ------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Jadwal Dokter")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _namaDokterCtrl,
                decoration: const InputDecoration(
                  labelText: "Nama Dokter",
                  border: OutlineInputBorder(),
                ),
                validator: _req,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _poliCtrl,
                decoration: const InputDecoration(
                  labelText: "Poli",
                  border: OutlineInputBorder(),
                ),
                validator: _req,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _hariCtrl,
                decoration: const InputDecoration(
                  labelText: "Hari",
                  border: OutlineInputBorder(),
                ),
                validator: _req,
              ),
              const SizedBox(height: 12),

              _fieldJamMulai(),
              const SizedBox(height: 12),

              _fieldJamSelesai(),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _simpan,
                  child: const Text("Simpan"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
