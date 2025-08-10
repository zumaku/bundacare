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
        ),
      ),
    );
  }
}