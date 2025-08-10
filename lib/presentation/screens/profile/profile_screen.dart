import 'package:flutter/material.dart';
import 'package:bundacare/core/services/supabase_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Email: ${supabase.auth.currentUser?.email ?? 'Tidak ada'}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // TODO: Panggil Auth BLoC untuk logout
                // context.read<AuthBloc>().add(AuthSignOutRequested());
              },
              child: const Text('Logout'),
            )
          ],
        ),
      ),
    );
  }
}