import 'package:flutter/material.dart';
import '../../model/kunjungan.dart';
import '../../model/pasien.dart';
import '../../service/pasien_service.dart';
import '../../service/kunjungan_service.dart';
import 'kunjungan_detail.dart';

class KunjunganForm extends StatefulWidget {
  const KunjunganForm({super.key});

  @override
  State<KunjunganForm> createState() => _KunjunganFormState();
}

class _KunjunganFormState extends State<KunjunganForm> {
  final _formKey = GlobalKey<FormState>();

  // controller utama
  final _tanggalCtrl = TextEditingController();
  final _nomorRmCtrl = TextEditingController();
  final _namaPasienCtrl = TextEditingController();
  final _poliCtrl = TextEditingController();
  final _dokterCtrl = TextEditingController();
  final _keluhanCtrl = TextEditingController();
  final _diagnosaCtrl = TextEditingController();
  final _resepCtrl = TextEditingController();

  // rekam medis detail
  final _tekananDarahCtrl = TextEditingController();
  final _suhuCtrl = TextEditingController();
  final _beratCtrl = TextEditingController();
  final _tinggiCtrl = TextEditingController();
  final _alergiCtrl = TextEditingController();
  final _catatanCtrl = TextEditingController();

  // data pasien untuk dropdown
  List<Pasien> _pasienList = [];
  Pasien? _selectedPasien;
  bool _loadingPasien = true;

  @override
  void initState() {
    super.initState();
    _loadPasien();
  }

  Future<void> _loadPasien() async {
    try {
      final list = await PasienService().listData();
      if (!mounted) return;
      setState(() {
        _pasienList = list;
        _loadingPasien = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingPasien = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memuat data pasien: $e')));
    }
  }

  @override
  void dispose() {
    _tanggalCtrl.dispose();
    _nomorRmCtrl.dispose();
    _namaPasienCtrl.dispose();
    _poliCtrl.dispose();
    _dokterCtrl.dispose();
    _keluhanCtrl.dispose();
    _diagnosaCtrl.dispose();
    _resepCtrl.dispose();
    _tekananDarahCtrl.dispose();
    _suhuCtrl.dispose();
    _beratCtrl.dispose();
    _tinggiCtrl.dispose();
    _alergiCtrl.dispose();
    _catatanCtrl.dispose();
    super.dispose();
  }

  String? _required(String? v) {
    if (v == null || v.trim().isEmpty) return 'Wajib diisi';
    return null;
  }

  Future<void> _pickTanggal() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      _tanggalCtrl.text = picked
          .toIso8601String()
          .split('T')
          .first; // YYYY-MM-DD
      setState(() {});
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPasien == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih pasien terlebih dahulu')),
      );
      return;
    }

    final data = Kunjungan(
      tanggal: _tanggalCtrl.text.trim(),
      nomorRm: _nomorRmCtrl.text.trim(),
      namaPasien: _namaPasienCtrl.text.trim(),
      poli: _poliCtrl.text.trim(),
      dokter: _dokterCtrl.text.trim(),
      keluhan: _keluhanCtrl.text.trim(),
      diagnosa: _diagnosaCtrl.text.trim(),
      resep: _resepCtrl.text.trim(),
      tekananDarah: _tekananDarahCtrl.text.trim(),
      suhu: _suhuCtrl.text.trim(),
      berat: _beratCtrl.text.trim(),
      tinggi: _tinggiCtrl.text.trim(),
      alergi: _alergiCtrl.text.trim(),
      catatan: _catatanCtrl.text.trim(),
    );

    try {
      final saved = await KunjunganService().simpan(data);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kunjungan berhasil disimpan')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => KunjunganDetail(kunjungan: saved)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menyimpan data: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Kunjungan')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _loadingPasien
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // ====== PILIH PASIEN (WAJIB SUDAH TERDAFTAR) ======
                    DropdownButtonFormField<Pasien>(
                      decoration: const InputDecoration(
                        labelText: 'Pilih Pasien (RM - Nama)',
                        border: OutlineInputBorder(),
                      ),
                      initialValue: _selectedPasien,
                      items: _pasienList
                          .map(
                            (p) => DropdownMenuItem<Pasien>(
                              value: p,
                              child: Text('${p.nomorRm} - ${p.nama}'),
                            ),
                          )
                          .toList(),
                      onChanged: (p) {
                        if (p == null) return;
                        setState(() {
                          _selectedPasien = p;
                          _nomorRmCtrl.text = p.nomorRm;
                          _namaPasienCtrl.text = p.nama;
                        });
                      },
                      validator: (v) =>
                          v == null ? 'Pasien harus dipilih' : null,
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _nomorRmCtrl,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Nomor Rekam Medis',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _namaPasienCtrl,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Nama Pasien',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ====== TANGGAL KUNJUNGAN ======
                    TextFormField(
                      controller: _tanggalCtrl,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Tanggal Kunjungan',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: _pickTanggal,
                        ),
                      ),
                      validator: _required,
                    ),
                    const SizedBox(height: 12),

                    // ====== POLI & DOKTER ======
                    TextFormField(
                      controller: _poliCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Poli',
                        border: OutlineInputBorder(),
                      ),
                      validator: _required,
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _dokterCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Dokter',
                        border: OutlineInputBorder(),
                      ),
                      validator: _required,
                    ),
                    const SizedBox(height: 12),

                    // ====== KELUHAN / DIAGNOSA / RESEP ======
                    TextFormField(
                      controller: _keluhanCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Keluhan',
                        border: OutlineInputBorder(),
                      ),
                      validator: _required,
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _diagnosaCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Diagnosa',
                        border: OutlineInputBorder(),
                      ),
                      validator: _required,
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _resepCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Resep Obat',
                        border: OutlineInputBorder(),
                      ),
                      validator: _required,
                    ),

                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),

                    const Text(
                      'Rekam Medis Detail',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    TextFormField(
                      controller: _tekananDarahCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Tekanan Darah (mis. 120/80)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _suhuCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Suhu (°C)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _beratCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Berat Badan (kg)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _tinggiCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Tinggi Badan (cm)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _alergiCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Alergi (bila ada)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _catatanCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Catatan Dokter',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Simpan Kunjungan'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
