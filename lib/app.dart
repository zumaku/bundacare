import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bundacare/core/config/app_router.dart';
import 'package:bundacare/core/injection_container.dart' as di;
import 'package:bundacare/presentation/bloc/auth/auth_bloc.dart';

class BundaCareApp extends StatelessWidget {
  const BundaCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Kita hanya menyediakan AuthBloc secara global
    return BlocProvider(
      create: (context) => di.sl<AuthBloc>(),
      child: MaterialApp.router(
        title: 'BundaCare',
        routerConfig: AppRouter.router,
        theme: ThemeData(
          brightness: Brightness.dark,
          
          // 1. Atur Poppins sebagai font default
          fontFamily: 'Poppins', 
          
          // 2. Atur skema warna utama
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFF035C5), // Warna pink Anda
            secondary: Color(0xFFF035C5),
            background: Color(0xFF121212), // Warna background gelap standar
          ),
          
          // Styling tambahan (opsional)
          scaffoldBackgroundColor: const Color(0xFF121212),
          cardTheme: CardThemeData( // Diubah dari CardTheme
            elevation: 2,
            color: const Color(0xFF2C2C2C),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }
}