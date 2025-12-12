import 'package:flutter/material.dart';
import 'helpers/user_info.dart';
import 'ui/login.dart';
import 'ui/beranda.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final token = await UserInfo().getToken();

  runApp(
    MaterialApp(
      title: 'Klinik APP',
      debugShowCheckedModeBanner: false,
      home: token == null ? const Login() : const Beranda(),
    ),
  );
}
