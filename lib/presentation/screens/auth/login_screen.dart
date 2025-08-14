import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:bundacare/presentation/bloc/auth/auth_bloc.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 1),

              // 1. Card Gambar di Atas
              ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                // Hapus widget AspectRatio dari sini
                child: Container(
                  // Beri ketinggian yang lebih proporsional, misal 50% dari tinggi layar
                  height: MediaQuery.of(context).size.height * 0.65,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Gambar Latar
                      Image.asset(
                        'assets/images/login_screen_image.png',
                        fit: BoxFit.cover,
                      ),
                      // Lapisan gelap agar logo terlihat
                      Container(
                        color: Colors.black.withOpacity(0.15),
                      ),
                      // Logo di tengah atas gambar
                      Positioned(
                        top: 20,
                        left: 0,
                        right: 0,
                        child: SvgPicture.asset(
                          'assets/logo/login_screen_logo.svg',
                          height: 50,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 2. Kata Sambutan (tidak di dalam card)
              Text(
                'Selamat Datang di BundaCare',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Teman setia perjalanan kehamilan Anda.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const Spacer(flex: 2),

              // 3. Tombol Login
              BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is Unauthenticated && state.message != null) {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(content: Text(state.message!)),
                      );
                  }
                },
                builder: (context, state) {
                  if (state is AuthLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return Padding(padding: EdgeInsets.all(2), child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: const Color(0xFF424242),
                      foregroundColor: Colors.white,
                    ),
                    icon: SvgPicture.asset(
                      'assets/icons/google_icon.svg',
                      height: 22,
                    ),
                    label: const Text('Masuk dengan Google', style: TextStyle(fontSize: 16)),
                    onPressed: () {
                      context.read<AuthBloc>().add(AuthSignInWithGoogleRequested());
                    },
                  ));
                },
              ),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}