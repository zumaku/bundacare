import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bundacare/presentation/bloc/auth/auth_bloc.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      // Kita gunakan BlocBuilder untuk mendapatkan state terbaru dari AuthBloc
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is Authenticated) {
            // Jika user sudah terautentikasi, tampilkan profilnya
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(
                      // Gunakan avatar_url dari metadata user
                      state.user.userMetadata?['avatar_url'] ?? '',
                    ),
                    onBackgroundImageError: (_, __) => const Icon(Icons.person, size: 50),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      // Gunakan full_name dari metadata user
                      state.user.userMetadata?['full_name'] ?? 'Nama Pengguna',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Center(
                    child: Text(
                      state.user.email ?? 'Tidak ada email',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // Beri warna merah untuk aksi destruktif
                    ),
                    onPressed: () {
                      // Panggil Auth BLoC untuk logout
                      context.read<AuthBloc>().add(AuthSignOutRequested());
                    },
                    child: const Text('Logout'),
                  ),
                ],
              ),
            );
          }
          // Tampilkan loading atau state kosong jika belum terautentikasi
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}