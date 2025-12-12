import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:klinik_app/app/constants/app_color.dart';

import '../../model/akun.dart';
import '../../service/akun_service.dart';

class AkunForm extends StatefulWidget {
  final Akun? akun; // null = tambah, ada = edit

  const AkunForm({super.key, this.akun});

  @override
  State<AkunForm> createState() => _AkunFormState();
}

class _AkunFormState extends State<AkunForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _username;
  late final TextEditingController _password;
  late final TextEditingController _nama;
  String _role = 'admin';

  // state untuk foto profil
  final ImagePicker _picker = ImagePicker();
  Uint8List? _profileBytes;

  @override
  void initState() {
    super.initState();
    _username = TextEditingController(text: widget.akun?.username ?? '');
    _password = TextEditingController(text: widget.akun?.password ?? '');
    _nama = TextEditingController(text: widget.akun?.nama ?? '');
    _role = widget.akun?.role ?? 'admin';
  }

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    _nama.dispose();
    super.dispose();
  }

  String? _req(String? v) =>
      (v == null || v.trim().isEmpty) ? "Wajib diisi" : null;

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;

    final akun = Akun(
      id: widget.akun?.id,
      username: _username.text.trim(),
      password: _password.text.trim(),
      nama: _nama.text.trim(),
      role: _role,
      // NOTE: foto belum dikirim ke API, hanya UI dulu
    );

    try {
      if (widget.akun == null) {
        await AkunService().simpan(akun);
      } else {
        await AkunService().ubah(akun);
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal menyimpan akun: $e")));
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

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.akun != null;

    // warna field yang kamu minta
    const fieldFillColor = Color.fromARGB(255, 222, 235, 247);

    OutlineInputBorder border(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: 1),
    );

    return Scaffold(
      // biar background gradient keliatan full
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,

      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        foregroundColor: AppColor.black,
        backgroundColor: Colors.transparent,
        title: Text(
          isEdit ? "Ubah Akun" : "Tambah Akun",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      body: Container(
        // gradient background untuk seluruh halaman
        decoration: BoxDecoration(
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
                  // ===== AVATAR + ICON EDIT DI ATAS TENGAH =====
                  Center(
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 42,
                              backgroundColor: AppColor.blue.withOpacity(0.25),
                              foregroundImage: _profileBytes != null
                                  ? MemoryImage(_profileBytes!)
                                  : null,
                              child: _profileBytes == null
                                  ? const Icon(
                                      Icons.person,
                                      size: 40,
                                      color: Colors.white,
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
                          isEdit
                              ? (widget.akun?.nama ?? 'Profil Akun')
                              : 'Foto Profil',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ===== FIELD USERNAME =====
                  TextFormField(
                    controller: _username,
                    decoration: InputDecoration(
                      labelText: "Username",
                      filled: true,
                      fillColor: fieldFillColor,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: border(AppColor.background),
                      enabledBorder: border(AppColor.background),
                      focusedBorder: border(AppColor.blue),
                    ),
                    validator: _req,
                  ),
                  const SizedBox(height: 12),

                  // ===== FIELD PASSWORD =====
                  TextFormField(
                    controller: _password,
                    decoration: InputDecoration(
                      labelText: "Password",
                      filled: true,
                      fillColor: fieldFillColor,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: border(AppColor.background),
                      enabledBorder: border(AppColor.background),
                      focusedBorder: border(AppColor.blue),
                    ),
                    obscureText: true,
                    validator: _req,
                  ),
                  const SizedBox(height: 12),

                  // ===== FIELD NAMA =====
                  TextFormField(
                    controller: _nama,
                    decoration: InputDecoration(
                      labelText: "Nama Lengkap",
                      filled: true,
                      fillColor: fieldFillColor,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: border(AppColor.background),
                      enabledBorder: border(AppColor.background),
                      focusedBorder: border(AppColor.blue),
                    ),
                    validator: _req,
                  ),
                  const SizedBox(height: 12),

                  // ===== DROPDOWN ROLE =====
                  DropdownButtonFormField<String>(
                    initialValue: _role,
                    decoration: InputDecoration(
                      labelText: "Role",
                      filled: true,
                      fillColor: fieldFillColor,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      border: border(AppColor.background),
                      enabledBorder: border(AppColor.background),
                      focusedBorder: border(AppColor.blue),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'admin', child: Text('Admin')),
                      DropdownMenuItem(
                        value: 'petugas',
                        child: Text('Petugas'),
                      ),
                      DropdownMenuItem(value: 'dokter', child: Text('Dokter')),
                      DropdownMenuItem(
                        value: 'apoteker',
                        child: Text('Apoteker'),
                      ),
                    ],
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => _role = v);
                    },
                  ),
                  const SizedBox(height: 28),

                  // ===== BUTTON SIMPAN =====
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _simpan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.blue,
                        foregroundColor: Colors.white,
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
}
