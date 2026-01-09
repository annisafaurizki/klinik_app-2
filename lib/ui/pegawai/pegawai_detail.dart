import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:klinik_app/app/constants/app_color.dart';

import '../../model/pegawai.dart';
import '../../service/pegawai_service.dart';
import 'pegawai_page.dart';
import 'pegawai_update_form.dart';

class PegawaiDetail extends StatefulWidget {
  final Pegawai pegawai;

  const PegawaiDetail({super.key, required this.pegawai});

  @override
  State<PegawaiDetail> createState() => _PegawaiDetailState();
}

class _PegawaiDetailState extends State<PegawaiDetail> {
  final ImagePicker _picker = ImagePicker();
  Uint8List? _profileBytes;

  Future<bool?> _confirm(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text("Konfirmasi"),
          ],
        ),
        content: const Text(
          "Apakah kamu yakin ingin menghapus data pegawai ini?\n"
          "Tindakan ini tidak dapat dibatalkan.",
          style: TextStyle(fontSize: 14),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  AppColor.redStatus, // konsisten dengan dialog lain
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.delete, size: 18),
            label: const Text("Hapus"),
          ),
        ],
      ),
    );
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

  String _formatDate(String raw) {
    if (raw.isEmpty) return '-';
    try {
      final dt = DateTime.parse(raw);
      final d = dt.day.toString().padLeft(2, '0');
      final m = dt.month.toString().padLeft(2, '0');
      final y = dt.year.toString();
      return '$d-$m-$y';
    } catch (_) {
      return raw;
    }
  }

  // ==== FIELD STYLE MIRIP MANAJEMEN AKUN ====
  static const _fieldFillColor = Color.fromARGB(255, 222, 235, 247);

  Widget _infoField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColor.gray200,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColor.background, // sama seperti Manajemen Akun
                width: 1,
              ),
            ),
            child: Text(
              (value.isEmpty) ? '-' : value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pegawai = widget.pegawai;
    final inisial = (pegawai.nama.isNotEmpty ? pegawai.nama[0] : '?')
        .toUpperCase();

    return Scaffold(
      backgroundColor: AppColor.backgroundBlue, // sama dengan Manajemen Akun
      appBar: AppBar(
        backgroundColor: AppColor.backgroundBlue,
        elevation: 0,
        foregroundColor: AppColor.black,
        centerTitle: true,
        title: const Text(
          "Detail Pegawai",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          child: Column(
            children: [
              // ===== AVATAR + NAMA =====
              Center(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 44,
                          backgroundColor: AppColor.blue.withOpacity(0.15),
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
                    const SizedBox(height: 8),
                    Text(
                      pegawai.nama,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    // kalau nanti mau badge role bisa taruh di sini
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ===== CARD DATA PEGAWAI =====
              Card(
                color: AppColor.whiteBlue,
                elevation: 1.5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 18,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoField('NIP', pegawai.nip),
                      _infoField('Nama', pegawai.nama),
                      _infoField(
                        'Tgl Lahir',
                        _formatDate(pegawai.tanggalLahir),
                      ),
                      _infoField('Telepon', pegawai.nomorTelepon),
                      _infoField('Email', pegawai.email),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // ===== TOMBOL UBAH & HAPUS =====
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.mediumBlue,
                          foregroundColor: AppColor.background,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () async {
                          final updated = await Navigator.push<Pegawai>(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  PegawaiUpdateForm(pegawai: pegawai),
                            ),
                          );
                          if (updated != null && context.mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PegawaiPage(),
                              ),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Data pegawai diperbarui"),
                              ),
                            );
                          }
                        },
                        child: const Text('Ubah'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.redColor,
                          foregroundColor: AppColor.background,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () async {
                          final ok = await _confirm(context);
                          if (ok == true && context.mounted) {
                            await PegawaiService().hapus(pegawai);
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PegawaiPage(),
                              ),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Pegawai dihapus")),
                            );
                          }
                        },
                        child: const Text('Hapus'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
