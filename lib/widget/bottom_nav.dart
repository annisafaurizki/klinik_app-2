import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';

import '../app/constants/app_color.dart';
import '../helpers/user_info.dart';
import '../ui/akun/akun_page.dart';
// PAGE-PAGE KAMU
import '../ui/beranda.dart';
import '../ui/jadwal/jadwal_page.dart';
import '../ui/kunjungan/kunjungan_page.dart';
import '../ui/pasien/pasien_page.dart';
import '../ui/pegawai/pegawai_page.dart';
import '../ui/poli_page.dart';
import '../ui/resep/resep_page.dart';

class MainBottomNav extends StatefulWidget {
  const MainBottomNav({super.key});

  @override
  State<MainBottomNav> createState() => _MainBottomNavState();
}

class _MainBottomNavState extends State<MainBottomNav> {
  int _selected = 0;
  bool _heart = false;

  final PageController _controller = PageController();

  String? _role;
  List<Widget> _pages = [];
  List<BottomBarItem> _items = [];

  @override
  void initState() {
    super.initState();
    _loadRoleAndSetup();
  }

  Future<void> _loadRoleAndSetup() async {
    final info = UserInfo();
    final role = (await info.getRole() ?? '').toLowerCase();

    // default: semua punya Beranda
    final pages = <Widget>[const Beranda()];
    final items = <BottomBarItem>[
      BottomBarItem(
        icon: const Icon(Icons.home_outlined),
        selectedIcon: const Icon(Icons.home),
        selectedColor: AppColor.blue,
        unSelectedColor: Colors.grey,
        title: const Text('Beranda'),
      ),
    ];

    final isAdmin = role == 'admin';
    final isPetugas = role == 'petugas';
    final isDokter = role == 'dokter';
    final isApoteker = role == 'apoteker';

    // ---- ROLE SPESIFIK (mirror dari Sidebar) ----
    if (isAdmin) {
      pages.addAll(const [AkunPage(), PoliPage(), PegawaiPage()]);
      items.addAll([
        BottomBarItem(
          icon: const Icon(Icons.manage_accounts_outlined),
          selectedIcon: const Icon(Icons.manage_accounts),
          selectedColor: AppColor.blue,
          unSelectedColor: Colors.grey,
          title: const Text('Akun'),
        ),
        BottomBarItem(
          icon: const Icon(Icons.local_hospital_outlined),
          selectedIcon: const Icon(Icons.local_hospital),
          selectedColor: AppColor.blue,
          unSelectedColor: Colors.grey,
          title: const Text('Poli'),
        ),
        BottomBarItem(
          icon: const Icon(Icons.groups_outlined),
          selectedIcon: const Icon(Icons.groups),
          selectedColor: AppColor.blue,
          unSelectedColor: Colors.grey,
          title: const Text('Pegawai'),
        ),
      ]);
    } else if (isPetugas) {
      pages.addAll(const [PoliPage(), PegawaiPage()]);
      items.addAll([
        BottomBarItem(
          icon: const Icon(Icons.local_hospital_outlined),
          selectedIcon: const Icon(Icons.local_hospital),
          selectedColor: AppColor.blue,
          unSelectedColor: Colors.grey,
          title: const Text('Poli'),
        ),
        BottomBarItem(
          icon: const Icon(Icons.groups_outlined),
          selectedIcon: const Icon(Icons.groups),
          selectedColor: AppColor.blue,
          unSelectedColor: Colors.grey,
          title: const Text('Pegawai'),
        ),
      ]);
    } else if (isDokter) {
      pages.add(const KunjunganPage());
      items.add(
        BottomBarItem(
          icon: const Icon(Icons.assignment_outlined),
          selectedIcon: const Icon(Icons.assignment),
          selectedColor: AppColor.blue,
          unSelectedColor: Colors.grey,
          title: const Text('Kunjungan'),
        ),
      );
    } else if (isApoteker) {
      pages.add(const ResepPage());
      items.add(
        BottomBarItem(
          icon: const Icon(Icons.medication_outlined),
          selectedIcon: const Icon(Icons.medication),
          selectedColor: AppColor.blue,
          unSelectedColor: Colors.grey,
          title: const Text('Resep'),
        ),
      );
    }

    // ---- MENU YANG ADA DI SEMUA ROLE (Data Pasien + Jadwal) ----
    pages.addAll(const [PasienPage(), JadwalPage()]);
    items.addAll([
      BottomBarItem(
        icon: const Icon(Icons.person_search_outlined),
        selectedIcon: const Icon(Icons.person_search),
        selectedColor: AppColor.blue,
        unSelectedColor: Colors.grey,
        title: const Text('Pasien'),
      ),
      BottomBarItem(
        icon: const Icon(Icons.schedule_outlined),
        selectedIcon: const Icon(Icons.schedule),
        selectedColor: AppColor.blue,
        unSelectedColor: Colors.grey,
        title: const Text('Jadwal'),
      ),
    ]);

    if (!mounted) return;
    setState(() {
      _role = role;
      _pages = pages;
      _items = items;
      _selected = 0;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // masih loading role / menu
    if (_role == null || _pages.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      extendBody: true,
      body: SafeArea(
        child: PageView(
          controller: _controller,
          physics: const NeverScrollableScrollPhysics(),
          children: _pages,
          onPageChanged: (index) {
            setState(() => _selected = index);
          },
        ),
      ),
      bottomNavigationBar: StylishBottomBar(
        option: AnimatedBarOptions(iconStyle: IconStyle.animated),
        items: _items,
        currentIndex: _selected,
        hasNotch: true,
        fabLocation: StylishBarFabLocation.center,
        notchStyle: NotchStyle.square,
        onTap: (index) {
          if (index == _selected) return;
          _controller.jumpToPage(index);
          setState(() => _selected = index);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _heart = !_heart;
          });
        },
        backgroundColor: Colors.white,
        child: Icon(
          _heart ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
          color: Colors.red,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
