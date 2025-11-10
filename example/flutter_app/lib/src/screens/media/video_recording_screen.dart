import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class VideoRecordingScreen extends ConsumerStatefulWidget {
  const VideoRecordingScreen({super.key});

  @override
  ConsumerState<VideoRecordingScreen> createState() =>
      _VideoRecordingScreenState();
}

class _VideoRecordingScreenState extends ConsumerState<VideoRecordingScreen> {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isRecording = false;
  bool _isInitialized = false;
  int _selectedCameraIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;

      await _setupCamera(_selectedCameraIndex);
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  Future<void> _setupCamera(int cameraIndex) async {
    if (_controller != null) {
      await _controller!.dispose();
    }

    _controller = CameraController(
      _cameras[cameraIndex],
      ResolutionPreset.high,
      enableAudio: true,
    );

    try {
      await _controller!.initialize();
      setState(() => _isInitialized = true);
    } catch (e) {
      print('Error setting up camera: $e');
    }
  }

  Future<void> _startRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      await _controller!.startVideoRecording();
      setState(() => _isRecording = true);
    } catch (e) {
      print('Error starting recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    if (_controller == null || !_controller!.value.isRecordingVideo) return;

    try {
      final file = await _controller!.stopVideoRecording();
      setState(() => _isRecording = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Video saved: ${file.path}')),
        );
      }
    } catch (e) {
      print('Error stopping recording: $e');
    }
  }

  void _switchCamera() {
    if (_cameras.length < 2) return;

    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    _setupCamera(_selectedCameraIndex);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Recording'),
        actions: [
          if (_cameras.length > 1)
            IconButton(
              icon: const Icon(Icons.flip_camera_ios),
              onPressed: _switchCamera,
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (!_isInitialized || _controller == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Stack(
      children: [
        SizedBox.expand(
          child: CameraPreview(_controller!),
        ),
        Positioned(
          bottom: 32,
          left: 0,
          right: 0,
          child: Center(
            child: FloatingActionButton.large(
              onPressed: _isRecording ? _stopRecording : _startRecording,
              backgroundColor: _isRecording ? Colors.red : Colors.white,
              child: Icon(
                _isRecording ? Icons.stop : Icons.fiber_manual_record,
                color: _isRecording ? Colors.white : Colors.red,
                size: 32,
              ),
            ),
          ),
        ),
        if (_isRecording)
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: const [
                  Icon(Icons.fiber_manual_record, color: Colors.white, size: 12),
                  SizedBox(width: 4),
                  Text(
                    'REC',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
