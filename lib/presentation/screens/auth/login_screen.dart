import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bundacare/presentation/bloc/auth/auth_bloc.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Unauthenticated && state.message != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text(state.message!)),
              );
          }
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Selamat Datang di BundaCare', style: TextStyle(fontSize: 24)),
              const SizedBox(height: 30),
              // Gunakan BlocBuilder untuk menampilkan loading indicator
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is AuthLoading) {
                    return const CircularProgressIndicator();
                  }
                  return ElevatedButton.icon(
                    icon: const Icon(Icons.login), // Anda bisa ganti dengan logo Google
                    label: const Text('Masuk dengan Google'),
                    onPressed: () {
                      // Panggil event ke AuthBloc
                      context.read<AuthBloc>().add(AuthSignInWithGoogleRequested());
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}