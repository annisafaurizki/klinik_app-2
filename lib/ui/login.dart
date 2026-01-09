import 'package:flutter/material.dart';
import 'package:klinik_app/app/constants/app_color.dart';
import 'package:klinik_app/service/login_service.dart';
import 'package:klinik_app/widget/bottom_nav.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _doLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final username = _usernameCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    final isOk = await LoginService().login(username, password);

    if (!mounted) return;

    if (isOk) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: const Text("Username atau Password tidak valid"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  String? _req(String? v) =>
      (v == null || v.trim().isEmpty) ? "Tidak boleh kosong" : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [AppColor.backgroundBlue, AppColor.whiteBlue],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  /// LOGO
                  Image.asset('assets/images/tongfang.png', height: 200),

                  const SizedBox(height: 16),

                  const Text(
                    "KLINIK TONGFANG",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColor.blue,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Silakan login untuk melanjutkan",
                    style: TextStyle(color: Colors.black54),
                  ),

                  const SizedBox(height: 32),

                  /// CARD LOGIN
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColor.whiteBlue,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColor.white),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          /// USERNAME
                          TextFormField(
                            controller: _usernameCtrl,
                            decoration: InputDecoration(
                              labelText: "Username",
                              prefixIcon: const Icon(Icons.person),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            validator: _req,
                          ),

                          const SizedBox(height: 16),

                          /// PASSWORD
                          TextFormField(
                            controller: _passwordCtrl,
                            decoration: InputDecoration(
                              labelText: "Password",
                              prefixIcon: const Icon(Icons.lock),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            obscureText: true,
                            validator: _req,
                          ),

                          const SizedBox(height: 24),

                          /// BUTTON LOGIN
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _doLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColor.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text(
                                "Login",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColor.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    "© DPR UBSI 2025",
                    style: TextStyle(fontSize: 12, color: Colors.black45),
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
