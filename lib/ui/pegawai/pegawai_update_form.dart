import 'package:flutter/material.dart';
import '../../model/pegawai.dart';
import '../../service/pegawai_service.dart';
import 'pegawai_detail.dart';

class PegawaiUpdateForm extends StatefulWidget {
  final Pegawai pegawai;
  const PegawaiUpdateForm({super.key, required this.pegawai});

  @override
  State<PegawaiUpdateForm> createState() => _PegawaiUpdateFormState();
}

class _PegawaiUpdateFormState extends State<PegawaiUpdateForm> {
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
    _nip = TextEditingController(text: widget.pegawai.nip);
    _nama = TextEditingController(text: widget.pegawai.nama);
    _tgl = TextEditingController(text: widget.pegawai.tanggalLahir);
    _telp = TextEditingController(text: widget.pegawai.nomorTelepon);
    _email = TextEditingController(text: widget.pegawai.email);
    _password = TextEditingController(text: widget.pegawai.password);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ubah Pegawai")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _field(_nip, "NIP"),
              _field(_nama, "Nama"),
              _field(_tgl, "Tanggal Lahir"),
              _field(_telp, "Nomor Telepon"),
              _field(_email, "Email"),
              _field(_password, "Password", obscure: true),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;

                  // bentuk objek baru dari input
                  final updated = Pegawai(
                    // id tetap pakai yang lama
                    id: widget.pegawai.id,
                    nip: _nip.text.trim(),
                    nama: _nama.text.trim(),
                    tanggalLahir: _tgl.text.trim(),
                    nomorTelepon: _telp.text.trim(),
                    email: _email.text.trim(),
                    password: _password.text.trim(),
                  );

                  // kirim ke API (pastikan id di model/string sudah sesuai dengan PegawaiService)
                  final id = widget.pegawai.id.toString();
                  final result = await PegawaiService().ubah(updated, id);

                  // setelah sukses → balik ke detail
                  if (!mounted) return;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PegawaiDetail(pegawai: result),
                    ),
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Data pegawai diperbarui")),
                  );
                },
                child: const Text("Simpan Perubahan"),
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
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: _req,
      ),
    );
  }
}
