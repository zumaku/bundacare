import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:bundacare/presentation/bloc/auth/auth_bloc.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand, // Membuat Stack memenuhi seluruh layar
        children: [
          // 1. Gambar Latar Belakang
          Image.asset(
            'assets/images/login_screen_image.png',
            fit: BoxFit.cover, // Memastikan gambar memenuhi layar tanpa distorsi
          ),
          
          // 2. Lapisan Gelap (untuk membuat teks lebih mudah dibaca)
          Container(
            color: Colors.black.withOpacity(0.3),
          ),

          // 3. Konten Utama
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Mendorong logo ke atas & card ke bawah
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo BundaCare di bagian atas
                  SvgPicture.asset(
                    'assets/logo/login_screen_logo.svg',
                    height: 50,
                  ),

                  // Card Konten
                  Container(
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor, // Warna latar belakang dari tema
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // Membuat Column seukuran kontennya
                      children: [
                        // Kata Sambutan
                        Text(
                          'Selamat Datang di BundaCare',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Teman setia perjalanan kehamilan Anda.',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.grey.shade400,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),

                        // Tombol Login dengan Google
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
                            return SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  backgroundColor: const Color(0xFF424242), // Warna tombol lebih gelap
                                  foregroundColor: Colors.white,
                                ),
                                icon: SvgPicture.asset(
                                  'assets/icons/google_icon.svg', // Pastikan path ini benar
                                  height: 22,
                                ),
                                label: const Text('Masuk dengan Google', style: TextStyle(fontSize: 16)),
                                onPressed: () {
                                  context.read<AuthBloc>().add(AuthSignInWithGoogleRequested());
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}