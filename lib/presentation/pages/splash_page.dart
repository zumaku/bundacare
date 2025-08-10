import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../blocs/auth/auth_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_event.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // trigger auth check then navigate
    Future.microtask(() {
      context.read<AuthBloc>().add(AuthCheckRequested());
      // small delay then check session in bloc listener in real app
      Future.delayed(const Duration(milliseconds: 400), () {
        final session = null; // placeholder
        // navigate by GoRouter redirect in router
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
