import 'dart:io';
import 'package:bundacare/presentation/bloc/food/food_bloc.dart';
import 'package:bundacare/presentation/screens/camera/detection_result_modal.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    var status = await Permission.camera.request();
    if (status.isGranted) {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        final firstCamera = cameras.first;
        _controller = CameraController(
          firstCamera,
          ResolutionPreset.high,
          enableAudio: false,
        );
        setState(() {
          _initializeControllerFuture = _controller!.initialize();
        });
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Izin kamera ditolak.')),
        );
      }
    }
  }

  Future<void> _onTakePicture() async {
    try {
      await _initializeControllerFuture;
      if (_controller == null || !_controller!.value.isInitialized) return;
      if (!mounted) return; // FIX: Cek `mounted` sebelum async gap

      final image = await _controller!.takePicture();
      
      if (!mounted) return; // FIX: Cek `mounted` lagi setelah async gap
      _processImage(File(image.path));

    } catch (e) {
      debugPrint("Error taking picture: $e");
    }
  }

  void _processImage(File imageFile) {
    final foodBloc = context.read<FoodBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return BlocProvider.value(
          value: foodBloc,
          child: DetectionResultModal(imageFile: imageFile),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (_controller != null && _controller!.value.isInitialized) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  CameraPreview(_controller!),
                  _buildControls(),
                ],
              );
            } else {
              return const Center(child: Text("Kamera tidak tersedia.", style: TextStyle(color: Colors.white)));
            }
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _buildControls() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 150,
        color: Colors.black.withOpacity(0.5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.photo_library, color: Colors.white, size: 30),
            ),
            GestureDetector(
              onTap: _onTakePicture,
              child: Container(
                width: 70, height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: Center(
                  child: Container(
                    width: 58, height: 58,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white
                    ),
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.flash_on, color: Colors.white, size: 30),
            ),
          ],
        ),
      ),
    );
  }
}