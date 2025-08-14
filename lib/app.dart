import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bundacare/core/config/app_router.dart';
import 'package:bundacare/core/injection_container.dart' as di;
import 'package:bundacare/presentation/bloc/auth/auth_bloc.dart';
import 'package:bundacare/presentation/bloc/food/food_bloc.dart';

class BundaCareApp extends StatelessWidget {
  const BundaCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => di.sl<AuthBloc>(),
        ),
        BlocProvider(
          create: (context) => di.sl<FoodBloc>()..add(FetchTodaysFood()),
        ),
      ],
      // Gunakan builder agar router tahu tentang MultiBlocProvider
      child: Builder(
        builder: (context) {
          return MaterialApp.router(
            title: 'BundaCare',
            // Panggil router dari AppRouter, berikan context yang benar
            routerConfig: AppRouter.createRouter(context), 
            theme: ThemeData(
              brightness: Brightness.dark,
              
              // 1. Atur Poppins sebagai font default
              fontFamily: 'Poppins', 
              
              // 2. Atur skema warna utama
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFFF035C5), // Warna pink Anda
                secondary: Color(0xFFF035C5),
              ),
              
              // Styling tambahan (opsional)
              scaffoldBackgroundColor: const Color(0xFF292929),

              cardTheme: CardThemeData( // Diubah dari CardTheme
                elevation: 0,
                color: const Color(0xFF2C2C2C),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          );
        }
      ),
    );
  }
}