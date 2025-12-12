import 'package:flutter/material.dart';
import '../../model/pasien.dart';
import '../../service/pasien_service.dart';
import 'pasien_detail.dart';

class PasienUpdateForm extends StatefulWidget {
  final Pasien pasien;

  const PasienUpdateForm({super.key, required this.pasien});

  @override
  State<PasienUpdateForm> createState() => _PasienUpdateFormState();
}

class _PasienUpdateFormState extends State<PasienUpdateForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _rm;
  late TextEditingController _nama;
  late TextEditingController _tgl;
  late TextEditingController _telp;
  late TextEditingController _alamat;

  @override
  void initState() {
    super.initState();
    _rm = TextEditingController(text: widget.pasien.nomorRm);
    _nama = TextEditingController(text: widget.pasien.nama);
    _tgl = TextEditingController(text: widget.pasien.tanggalLahir);
    _telp = TextEditingController(text: widget.pasien.nomorTelepon);
    _alamat = TextEditingController(text: widget.pasien.alamat);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ubah Pasien")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _field(_rm, "Nomor RM"),
              _field(_nama, "Nama"),
              _field(_tgl, "Tanggal Lahir"),
              _field(_telp, "Nomor Telepon"),
              _field(_alamat, "Alamat", maxLines: 2),

              const SizedBox(height: 20),
              ElevatedButton(
                child: const Text("Simpan Perubahan"),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    Pasien pasien = Pasien(
                      id: widget.pasien.id,
                      nomorRm: _rm.text,
                      nama: _nama.text,
                      tanggalLahir: _tgl.text,
                      nomorTelepon: _telp.text,
                      alamat: _alamat.text,
                    );

                    final value = await PasienService().ubah(
                      pasien,
                      widget.pasien.id!,
                    );

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PasienDetail(pasien: value),
                      ),
                    );
                  }
                },
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
        validator: (v) => v == null || v.isEmpty ? "Wajib diisi" : null,
      ),
    );
  }
}
