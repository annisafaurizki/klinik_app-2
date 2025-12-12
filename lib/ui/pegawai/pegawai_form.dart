import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:klinik_app/app/constants/app_color.dart';

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

  // state foto
  final ImagePicker _picker = ImagePicker();
  Uint8List? _profileBytes;

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
        await PegawaiService().simpan(pegawai);
      } else {
        final id = widget.pegawai!.id.toString();
        await PegawaiService().ubah(pegawai, id);
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal menyimpan: $e")));
    }
  }

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    if (!mounted) return;
    setState(() {
      _profileBytes = bytes;
    });
  }

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide(color: color, width: 1),
  );

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.pegawai != null;
    final inisial = (_nama.text.isNotEmpty ? _nama.text[0] : '?').toUpperCase();

    // warna field pastel kayak manajemen akun
    const fieldFillColor = Color.fromARGB(255, 222, 235, 247);

    return Scaffold(
      // biar background bisa full sampai belakang appbar
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColor.black,
        title: Text(
          isEdit ? "Ubah Pegawai" : "Tambah Pegawai",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Container(
        // background sama kayak manajemen akun page
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
                  // Avatar + edit foto
                  Center(
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 42,
                              backgroundColor: AppColor.blue.withOpacity(0.20),
                              foregroundImage: _profileBytes != null
                                  ? MemoryImage(_profileBytes!)
                                  : null,
                              child: _profileBytes == null
                                  ? Text(
                                      inisial,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    )
                                  : null,
                            ),
                            Positioned(
                              bottom: 2,
                              right: 2,
                              child: InkWell(
                                onTap: _pickImage,
                                borderRadius: BorderRadius.circular(16),
                                child: CircleAvatar(
                                  radius: 14,
                                  backgroundColor: AppColor.blue,
                                  child: const Icon(
                                    Icons.edit,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          isEdit ? "Ubah Data Pegawai" : "Data Pegawai Baru",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ===== FIELD-FIELD =====
                  _field(_nip, "NIP", fieldFillColor),
                  _field(_nama, "Nama", fieldFillColor),
                  _field(_tgl, "Tanggal Lahir (YYYY-MM-DD)", fieldFillColor),
                  _field(_telp, "Nomor Telepon", fieldFillColor),
                  _field(_email, "Email", fieldFillColor),
                  _field(_password, "Password", fieldFillColor, obscure: true),

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
                      child: Text(
                        isEdit ? "Simpan Perubahan" : "Simpan",
                        style: const TextStyle(
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

  Widget _field(
    TextEditingController c,
    String label,
    Color fieldFillColor, {
    bool obscure = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        obscureText: obscure,
        validator: _req,
        decoration: InputDecoration(
          labelText: label,
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
    );
  }
}
