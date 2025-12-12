import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:klinik_app/app/constants/app_color.dart';

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

  // foto
  final ImagePicker _picker = ImagePicker();
  Uint8List? _profileBytes;

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

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    if (!mounted) return;

    setState(() => _profileBytes = bytes);
  }

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
        await PasienService().simpan(pasien);
      } else {
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

  // style manajemen akun
  static const fieldFillColor = Color.fromARGB(255, 222, 235, 247);

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: color, width: 1),
  );

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.pasien != null;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColor.black,
        title: Text(isEdit ? "Ubah Pasien" : "Tambah Pasien"),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColor.backgroundBlue,
              AppColor
                  .backgroundBlue, // kalau mau bawah lebih gelap, ganti di sini
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  // ==== FOTO KOTAK + EDIT NEMPEL GARIS ====
                  Center(
                    child: Column(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 92,
                              height: 92,
                              decoration: BoxDecoration(
                                color: AppColor.blue.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: AppColor.background,
                                  width: 1,
                                ),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: _profileBytes != null
                                  ? Image.memory(
                                      _profileBytes!,
                                      fit: BoxFit.cover,
                                    )
                                  : const Icon(
                                      Icons.person,
                                      size: 44,
                                      color: Colors.white,
                                    ),
                            ),

                            // tombol edit nempel garis (di luar kotak)
                            Positioned(
                              right: -6,
                              bottom: -6,
                              child: InkWell(
                                onTap: _pickImage,
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: AppColor.blue,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: AppColor.background,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.15),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
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
                          isEdit ? "Ubah Data Pasien" : "Data Pasien Baru",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  _field(_rm, "Nomor RM"),
                  _field(_nama, "Nama"),
                  _field(_tgl, "Tanggal Lahir (YYYY-MM-DD)"),
                  _field(_telp, "Nomor Telepon"),
                  _field(_alamat, "Alamat", maxLines: 2),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _simpan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.blue,
                        foregroundColor: AppColor.background,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(
                            color: AppColor.background,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Text(
                        isEdit ? "Simpan Perubahan" : "Simpan",
                        style: const TextStyle(fontWeight: FontWeight.w600),
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

  Widget _field(TextEditingController ctrl, String label, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        validator: _req,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: fieldFillColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          border: _border(const Color.fromARGB(255, 0, 0, 0).withOpacity(0.15)),
          enabledBorder: _border(AppColor.background),
          focusedBorder: _border(AppColor.background),
        ),
      ),
    );
  }
}
