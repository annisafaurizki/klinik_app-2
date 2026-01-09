import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutter/material.dart';
import 'package:klinik_app/app/constants/app_color.dart';
import 'package:klinik_app/ui/beranda.dart';
import 'package:klinik_app/widget/aktivitas.dart';
import 'package:klinik_app/widget/akun.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 1;

  final List<Widget> _tabs = const [
    AktivitasPage(), // 🏠 Statistik + sambutan
    Beranda(), // 📦 Menu (pengganti sidebar)
    ProfilePage(), // 👤 Akun + logout
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _tabs),
      bottomNavigationBar: FlashyTabBar(
        selectedIndex: _selectedIndex,
        showElevation: true,
        backgroundColor: AppColor.white,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 300),
        onItemSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          FlashyTabBarItem(
            icon: Icon(Icons.apps, color: AppColor.blue),
            title: Text('Aktivitas'),
          ),
          FlashyTabBarItem(
            icon: Icon(Icons.home, color: AppColor.blue),
            title: Text('Beranda'),
          ),
          FlashyTabBarItem(
            icon: Icon(Icons.person, color: AppColor.blue),
            title: Text('Akun'),
          ),
        ],
      ),
    );
  }
}
