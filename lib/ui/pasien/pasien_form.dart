import 'package:flutter/material.dart';
import '../../model/pasien.dart';
import '../../service/pasien_service.dart';

class PasienForm extends StatefulWidget {
  final Pasien? pasien; // null = tambah, ada = edit

  const PasienForm({super.key, this.pasien});

  @override
  State<PasienForm> createState() => _PasienFormState();
}

class _PasienFormState extends State<PasienForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _rm;
  late final TextEditingController _nama;
  late final TextEditingController _tgl;
  late final TextEditingController _telp;
  late final TextEditingController _alamat;

  @override
  void initState() {
    super.initState();
    _rm = TextEditingController(text: widget.pasien?.nomorRm ?? '');
    _nama = TextEditingController(text: widget.pasien?.nama ?? '');
    _tgl = TextEditingController(text: widget.pasien?.tanggalLahir ?? '');
    _telp = TextEditingController(text: widget.pasien?.nomorTelepon ?? '');
    _alamat = TextEditingController(text: widget.pasien?.alamat ?? '');
  }

  @override
  void dispose() {
    _rm.dispose();
    _nama.dispose();
    _tgl.dispose();
    _telp.dispose();
    _alamat.dispose();
    super.dispose();
  }

  String? _req(String? v) =>
      (v == null || v.trim().isEmpty) ? "Wajib diisi" : null;

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;

    final pasien = Pasien(
      id: widget.pasien?.id,
      nomorRm: _rm.text.trim(),
      nama: _nama.text.trim(),
      tanggalLahir: _tgl.text.trim(),
      nomorTelepon: _telp.text.trim(),
      alamat: _alamat.text.trim(),
    );

    try {
      if (widget.pasien == null) {
        // tambah baru
        await PasienService().simpan(pasien);
      } else {
        // update
        final id = widget.pasien!.id.toString();
        await PasienService().ubah(pasien, id);
      }

      if (!mounted) return;
      Navigator.pop(context, true); // true = ada perubahan
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal menyimpan pasien: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.pasien != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? "Ubah Pasien" : "Tambah Pasien")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _field(_rm, "Nomor RM"),
              _field(_nama, "Nama"),
              _field(_tgl, "Tanggal Lahir (YYYY-MM-DD)"),
              _field(_telp, "Nomor Telepon"),
              _field(_alamat, "Alamat", maxLines: 2),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _simpan,
                child: Text(isEdit ? "Simpan Perubahan" : "Simpan"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: _req,
      ),
    );
  }
}
