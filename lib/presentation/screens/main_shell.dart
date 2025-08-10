import 'dart:ui'; // <-- 1. Import ini untuk ImageFilter
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

class MainShell extends StatelessWidget {
  const MainShell({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    // 2. Kita tidak lagi menggunakan Scaffold di sini, melainkan langsung Stack
    //    agar navbar bisa menumpuk di atas konten.
    return Scaffold(
      body: Stack(
        children: [
          // 3. Lapisan paling bawah: Konten halaman (Home, Kamera, Profile)
          navigationShell,

          // 4. Lapisan atas: Navigation bar dengan efek blur
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipRRect( // Menggunakan ClipRRect agar efek blur tidak "bocor"
              child: BackdropFilter( // <-- Kunci utama untuk efek blur
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: BottomNavigationBar(
                  items: <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                      icon: Icon(navigationShell.currentIndex == 0 ? Iconsax.home_15 : Iconsax.home),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(navigationShell.currentIndex == 1 ? Iconsax.camera5 : Iconsax.camera),
                      label: 'Kamera',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(navigationShell.currentIndex == 2 ? Iconsax.profile_circle5 : Iconsax.profile_circle),
                      label: 'Profile',
                    ),
                  ],
                  currentIndex: navigationShell.currentIndex,
                  onTap: (index) => _onTap(context, index),
                  
                  // --- 5. Perubahan Warna dan Latar Belakang ---
                  selectedItemColor: const Color(0xFFF035C5), // Warna pink sesuai permintaan
                  unselectedItemColor: Colors.grey.shade400,
                  showUnselectedLabels: true,
                  backgroundColor: Colors.black.withOpacity(0.8), // Latar belakang transparan
                  elevation: 0, // Hilangkan bayangan
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}