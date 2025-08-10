import 'dart:io';
import 'package:bundacare/core/injection_container.dart' as di;
import 'package:bundacare/presentation/bloc/detection/detection_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DetectionResultScreen extends StatelessWidget {
  final File imageFile;
  const DetectionResultScreen({super.key, required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<DetectionBloc>()..add(DetectFoodStarted(imageFile)),
      child: Scaffold(
        appBar: AppBar(title: const Text("Hasil Deteksi")),
        body: BlocBuilder<DetectionBloc, DetectionState>(
          builder: (context, state) {
            if (state is DetectionLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is DetectionSuccess) {
              final result = state.result;
              return Center(
                child: Text(
                  'Nama: ${result.foodName}\nKalori: ${result.calories} kcal',
                  style: const TextStyle(fontSize: 20),
                ),
              );
            }
            if (state is DetectionFailure) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return const Center(child: Text("Memulai deteksi..."));
          },
        ),
      ),
    );
  }
}