import 'package:flutter/material.dart';
import '../../model/jadwal.dart';
import '../../service/jadwal_service.dart';

class JadwalUpdateForm extends StatefulWidget {
  final Jadwal jadwal;

  const JadwalUpdateForm({super.key, required this.jadwal});

  @override
  State<JadwalUpdateForm> createState() => _JadwalUpdateFormState();
}

class _JadwalUpdateFormState extends State<JadwalUpdateForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _namaDokterCtrl;
  late final TextEditingController _poliCtrl;
  late final TextEditingController _hariCtrl;
  late final TextEditingController _jamMulaiCtrl;
  late final TextEditingController _jamSelesaiCtrl;

  @override
  void initState() {
    super.initState();
    _namaDokterCtrl = TextEditingController(text: widget.jadwal.namaDokter);
    _poliCtrl = TextEditingController(text: widget.jadwal.poli);
    _hariCtrl = TextEditingController(text: widget.jadwal.hari);
    _jamMulaiCtrl = TextEditingController(text: widget.jadwal.jamMulai);
    _jamSelesaiCtrl = TextEditingController(text: widget.jadwal.jamSelesai);
  }

  @override
  void dispose() {
    _namaDokterCtrl.dispose();
    _poliCtrl.dispose();
    _hariCtrl.dispose();
    _jamMulaiCtrl.dispose();
    _jamSelesaiCtrl.dispose();
    super.dispose();
  }

  String? _req(String? v) =>
      (v == null || v.trim().isEmpty) ? "Wajib diisi" : null;

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;

    // buat objek jadwal baru dari input form
    final updated = Jadwal(
      id: widget.jadwal.id,
      namaDokter: _namaDokterCtrl.text.trim(),
      poli: _poliCtrl.text.trim(),
      hari: _hariCtrl.text.trim(),
      jamMulai: _jamMulaiCtrl.text.trim(),
      jamSelesai: _jamSelesaiCtrl.text.trim(),
    );

    final id = widget.jadwal.id?.toString() ?? '';
    if (id.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("ID jadwal tidak valid")));
      return;
    }

    await JadwalService().ubah(updated, id);

    if (!mounted) return;
    // kirim data yang sudah di-update balik ke halaman sebelumnya
    Navigator.pop(context, updated);
  }

  // ---------- FIELD-FIELD FORM ----------

  Widget _fieldNamaDokter() {
    return TextFormField(
      controller: _namaDokterCtrl,
      decoration: const InputDecoration(
        labelText: "Nama Dokter",
        border: OutlineInputBorder(),
      ),
      validator: _req,
    );
  }

  Widget _fieldPoli() {
    return TextFormField(
      controller: _poliCtrl,
      decoration: const InputDecoration(
        labelText: "Poli",
        border: OutlineInputBorder(),
      ),
      validator: _req,
    );
  }

  Widget _fieldHari() {
    return TextFormField(
      controller: _hariCtrl,
      decoration: const InputDecoration(
        labelText: "Hari (contoh: Senin)",
        border: OutlineInputBorder(),
      ),
      validator: _req,
    );
  }

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

  Widget _tombolSimpan() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _simpan,
        child: const Text("Simpan Perubahan"),
      ),
    );
  }

  // ---------- BUILD ----------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ubah Jadwal Dokter")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _fieldNamaDokter(),
              const SizedBox(height: 12),
              _fieldPoli(),
              const SizedBox(height: 12),
              _fieldHari(),
              const SizedBox(height: 12),
              _fieldJamMulai(),
              const SizedBox(height: 12),
              _fieldJamSelesai(),
              const SizedBox(height: 20),
              _tombolSimpan(),
            ],
          ),
        ),
      ),
    );
  }
}
