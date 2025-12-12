import 'package:flutter/material.dart';
import '../../model/pegawai.dart';
import '../../service/pegawai_service.dart';

class PegawaiForm extends StatefulWidget {
  final Pegawai? pegawai; // null = tambah, ada = edit

  const PegawaiForm({super.key, this.pegawai});

  @override
  State<PegawaiForm> createState() => _PegawaiFormState();
}

class _PegawaiFormState extends State<PegawaiForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nip;
  late final TextEditingController _nama;
  late final TextEditingController _tgl;
  late final TextEditingController _telp;
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    super.initState();

    _nip = TextEditingController(text: widget.pegawai?.nip ?? '');
    _nama = TextEditingController(text: widget.pegawai?.nama ?? '');
    _tgl = TextEditingController(text: widget.pegawai?.tanggalLahir ?? '');
    _telp = TextEditingController(text: widget.pegawai?.nomorTelepon ?? '');
    _email = TextEditingController(text: widget.pegawai?.email ?? '');
    _password = TextEditingController(text: widget.pegawai?.password ?? '');
  }

  @override
  void dispose() {
    _nip.dispose();
    _nama.dispose();
    _tgl.dispose();
    _telp.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  String? _req(String? v) =>
      (v == null || v.trim().isEmpty) ? "Wajib diisi" : null;

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;

    final pegawai = Pegawai(
      id: widget.pegawai?.id,
      nip: _nip.text.trim(),
      nama: _nama.text.trim(),
      tanggalLahir: _tgl.text.trim(),
      nomorTelepon: _telp.text.trim(),
      email: _email.text.trim(),
      password: _password.text.trim(),
    );

    try {
      if (widget.pegawai == null) {
        // TAMBAH BARU
        await PegawaiService().simpan(pegawai);
      } else {
        // EDIT → butuh id
        final id = widget.pegawai!.id.toString();
        await PegawaiService().ubah(pegawai, id);
      }

      if (!mounted) return;
      // balik ke PegawaiPage dengan status "berubah"
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal menyimpan: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.pegawai != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? "Ubah Pegawai" : "Tambah Pegawai")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _field(_nip, "NIP"),
              _field(_nama, "Nama"),
              _field(_tgl, "Tanggal Lahir (YYYY-MM-DD)"),
              _field(_telp, "Nomor Telepon"),
              _field(_email, "Email"),
              _field(_password, "Password", obscure: true),
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

  Widget _field(TextEditingController c, String label, {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        obscureText: obscure,
        validator: _req,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
