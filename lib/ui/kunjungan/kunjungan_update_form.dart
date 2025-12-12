import 'package:flutter/material.dart';
import '../../model/kunjungan.dart';
import '../../service/kunjungan_service.dart';

class KunjunganUpdateForm extends StatefulWidget {
  final Kunjungan kunjungan;

  const KunjunganUpdateForm({super.key, required this.kunjungan});

  @override
  State<KunjunganUpdateForm> createState() => _KunjunganUpdateFormState();
}

class _KunjunganUpdateFormState extends State<KunjunganUpdateForm> {
  final _formKey = GlobalKey<FormState>();

  // controller utama
  late final TextEditingController _tanggalCtrl;
  late final TextEditingController _nomorRmCtrl;
  late final TextEditingController _namaPasienCtrl;
  late final TextEditingController _poliCtrl;
  late final TextEditingController _dokterCtrl;
  late final TextEditingController _keluhanCtrl;
  late final TextEditingController _diagnosaCtrl;
  late final TextEditingController _resepCtrl;

  // rekam medis detail
  late final TextEditingController _tekananDarahCtrl;
  late final TextEditingController _suhuCtrl;
  late final TextEditingController _beratCtrl;
  late final TextEditingController _tinggiCtrl;
  late final TextEditingController _alergiCtrl;
  late final TextEditingController _catatanCtrl;

  @override
  void initState() {
    super.initState();
    final k = widget.kunjungan;

    _tanggalCtrl = TextEditingController(text: k.tanggal);
    _nomorRmCtrl = TextEditingController(text: k.nomorRm);
    _namaPasienCtrl = TextEditingController(text: k.namaPasien);
    _poliCtrl = TextEditingController(text: k.poli);
    _dokterCtrl = TextEditingController(text: k.dokter);
    _keluhanCtrl = TextEditingController(text: k.keluhan);
    _diagnosaCtrl = TextEditingController(text: k.diagnosa);
    _resepCtrl = TextEditingController(text: k.resep);

    // yang tadi error karena pakai positional -> sekarang pakai named `text:`
    _tekananDarahCtrl = TextEditingController(text: k.tekananDarah ?? '');
    _suhuCtrl = TextEditingController(text: k.suhu ?? '');
    _beratCtrl = TextEditingController(text: k.berat ?? '');
    _tinggiCtrl = TextEditingController(text: k.tinggi ?? '');
    _alergiCtrl = TextEditingController(text: k.alergi ?? '');
    _catatanCtrl = TextEditingController(text: k.catatan ?? '');
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
      initialDate: _parseTanggal(_tanggalCtrl.text) ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      _tanggalCtrl.text = picked.toIso8601String().split('T').first;
      setState(() {});
    }
  }

  DateTime? _parseTanggal(String? s) {
    if (s == null || s.isEmpty) return null;
    try {
      return DateTime.parse(s);
    } catch (_) {
      return null;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final id = widget.kunjungan.id;
    if (id == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ID kunjungan tidak valid')));
      return;
    }

    final updated = Kunjungan(
      id: id,
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
      final saved = await KunjunganService().ubah(updated, id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kunjungan berhasil diperbarui')),
      );
      Navigator.pop(context, saved);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mengubah data: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ubah Kunjungan')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // ====== DATA PASIEN (READ ONLY) ======
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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                child: const Text('Simpan Perubahan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
