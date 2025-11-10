import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class AudioRecordingScreen extends ConsumerStatefulWidget {
  const AudioRecordingScreen({super.key});

  @override
  ConsumerState<AudioRecordingScreen> createState() =>
      _AudioRecordingScreenState();
}

class _AudioRecordingScreenState extends ConsumerState<AudioRecordingScreen> {
  final _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  String? _recordingPath;
  Duration _recordingDuration = Duration.zero;

  @override
  void dispose() {
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    if (await _audioRecorder.hasPermission()) {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: path,
      );

      setState(() {
        _isRecording = true;
        _recordingPath = path;
      });

      _startTimer();
    }
  }

  Future<void> _stopRecording() async {
    final path = await _audioRecorder.stop();

    setState(() {
      _isRecording = false;
      _recordingDuration = Duration.zero;
    });

    if (path != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Recording saved: $path')),
      );
    }
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_isRecording) {
        setState(() {
          _recordingDuration += const Duration(seconds: 1);
        });
        _startTimer();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Recording'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isRecording ? Icons.mic : Icons.mic_none,
              size: 120,
              color: _isRecording
                  ? Colors.red
                  : Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 32),
            Text(
              _formatDuration(_recordingDuration),
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 48),
            FloatingActionButton.large(
              onPressed: _isRecording ? _stopRecording : _startRecording,
              backgroundColor: _isRecording ? Colors.red : null,
              child: Icon(
                _isRecording ? Icons.stop : Icons.fiber_manual_record,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _isRecording ? 'Tap to stop recording' : 'Tap to start recording',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
