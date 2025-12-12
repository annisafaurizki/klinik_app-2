import 'package:flutter/material.dart';
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
    );

    try {
      if (widget.akun == null) {
        // tambah baru
        await AkunService().simpan(akun);
      } else {
        // ubah
        await AkunService().ubah(akun);
      }

      if (!mounted) return;
      // balik ke halaman sebelumnya + kasih tanda perlu refresh
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal menyimpan akun: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.akun != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? "Ubah Akun" : "Tambah Akun")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _username,
                decoration: const InputDecoration(
                  labelText: "Username",
                  border: OutlineInputBorder(),
                ),
                validator: _req,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _password,
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: _req,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nama,
                decoration: const InputDecoration(
                  labelText: "Nama Lengkap",
                  border: OutlineInputBorder(),
                ),
                validator: _req,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _role,
                decoration: const InputDecoration(
                  labelText: "Role",
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  DropdownMenuItem(value: 'petugas', child: Text('Petugas')),
                  DropdownMenuItem(value: 'dokter', child: Text('Dokter')),
                  DropdownMenuItem(
                    value: 'apoteker',
                    child: Text('Apoteker'),
                  ), //     DropdownMenuItem(value: 'apoteker', child: Text('Apoteker')), // 👈 ini baru
                ],
                onChanged: (v) {
                  if (v == null) return;
                  setState(() => _role = v);
                },
              ),
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
}
