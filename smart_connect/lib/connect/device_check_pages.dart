import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';

class CameraCheckPage extends StatefulWidget {
  const CameraCheckPage({super.key});

  @override
  State<CameraCheckPage> createState() => _CameraCheckPageState();
}

class _CameraCheckPageState extends State<CameraCheckPage> {
  CameraController? _controller;
  List<CameraDescription> _cameras = const [];
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera({CameraDescription? camera}) async {
    final previous = _controller;
    setState(() {
      _loading = true;
      _error = null;
      _controller = null;
    });
    await previous?.dispose();

    CameraController? nextController;
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        throw CameraException(
          'NoCamera',
          'No camera is available on this device.',
        );
      }
      final selected =
          camera ??
          _cameras.firstWhere(
            (item) => item.lensDirection == CameraLensDirection.front,
            orElse: () => _cameras.first,
          );
      nextController = CameraController(
        selected,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await nextController.initialize();
      if (!mounted) {
        await nextController.dispose();
        return;
      }
      setState(() {
        _controller = nextController;
        _loading = false;
      });
    } on CameraException catch (error) {
      await nextController?.dispose();
      if (mounted) {
        setState(() {
          _controller = null;
          _error = error.description ?? _cameraErrorMessage(error.code);
          _loading = false;
        });
      }
    } catch (_) {
      await nextController?.dispose();
      if (mounted) {
        setState(() {
          _controller = null;
          _error = 'We couldn’t open a camera. Check the device permission and try again.';
          _loading = false;
        });
      }
    }
  }

  String _cameraErrorMessage(String code) {
    if (code.contains('Denied')) {
      return 'Camera access is off. Allow camera access in your device settings, then try again.';
    }
    return 'We couldn’t open a camera. Check the device permission and try again.';
  }

  Future<void> _switchCamera() async {
    final current = _controller?.description;
    if (current == null || _cameras.length < 2) return;
    final direction = current.lensDirection == CameraLensDirection.front
        ? CameraLensDirection.back
        : CameraLensDirection.front;
    CameraDescription? next;
    for (final item in _cameras) {
      if (item.lensDirection == direction) {
        next = item;
        break;
      }
    }
    if (next == null) {
      setState(() => _error = 'The other camera is not available.');
      return;
    }
    await _initializeCamera(camera: next);
  }

  @override
  void dispose() {
    unawaited(_controller?.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Camera check')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Camera preview',
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'This preview stays on your device. Close this page when you’re done.',
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: AspectRatio(
              aspectRatio: 3 / 4,
              child: ColoredBox(
                color: Colors.black,
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : controller != null && controller.value.isInitialized
                    ? CameraPreview(
                        key: ValueKey(controller.description.name),
                        controller,
                      )
                    : _DeviceError(message: _error ?? 'Camera unavailable.'),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_cameras.length > 1)
            OutlinedButton.icon(
              onPressed: _loading ? null : _switchCamera,
              icon: const Icon(Icons.cameraswitch_outlined),
              label: const Text('Switch camera'),
            ),
          if (_error != null)
            FilledButton.tonalIcon(
              onPressed: _loading ? null : _initializeCamera,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
        ],
      ),
    );
  }
}

class MicrophoneCheckPage extends StatefulWidget {
  const MicrophoneCheckPage({super.key});

  @override
  State<MicrophoneCheckPage> createState() => _MicrophoneCheckPageState();
}

class _MicrophoneCheckPageState extends State<MicrophoneCheckPage> {
  final AudioRecorder _recorder = AudioRecorder();
  Timer? _meterTimer;
  bool _isRecording = false;
  double _level = 0;
  String? _message;
  String? _recordingPath;

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopRecording();
      setState(() => _message = 'Microphone check complete.');
      return;
    }
    try {
      if (!await _recorder.hasPermission()) {
        setState(
          () => _message =
              'Allow microphone access in device settings to run this check.',
        );
        return;
      }
      _recordingPath =
          '${Directory.systemTemp.path}${Platform.pathSeparator}smart_connect_mic_check.m4a';
      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc, numChannels: 1),
        path: _recordingPath!,
      );
      if (!mounted) return;
      setState(() {
        _isRecording = true;
        _message = 'Say a few words. The meter should move.';
      });
      _meterTimer = Timer.periodic(const Duration(milliseconds: 180), (
        _,
      ) async {
        try {
          final amplitude = await _recorder.getAmplitude();
          if (!mounted) return;
          setState(() => _level = ((amplitude.current + 60) / 60).clamp(0, 1));
        } catch (_) {
          // Some platforms do not report an amplitude while the recorder starts.
        }
      });
    } catch (_) {
      if (mounted) {
        setState(
          () => _message = 'The microphone could not be started. Check its permission and try again.',
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    _meterTimer?.cancel();
    _meterTimer = null;
    try {
      if (_isRecording) await _recorder.stop();
    } catch (_) {
      // Ignore cleanup errors and keep the device check usable.
    }
    _isRecording = false;
    _level = 0;
    final path = _recordingPath;
    _recordingPath = null;
    if (path != null) {
      try {
        await File(path).delete();
      } catch (_) {
        // The plugin may already have removed the temporary recording.
      }
    }
  }

  @override
  void dispose() {
    _meterTimer?.cancel();
    unawaited(_disposeRecorder());
    super.dispose();
  }

  Future<void> _disposeRecorder() async {
    await _stopRecording();
    await _recorder.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Microphone check')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 28),
            Container(
              height: 210,
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(26),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isRecording
                        ? Icons.graphic_eq_rounded
                        : Icons.mic_none_rounded,
                    size: 58,
                    color: _isRecording
                        ? colors.primary
                        : colors.onSurfaceVariant,
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: LinearProgressIndicator(
                      value: _isRecording ? _level : 0,
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(_isRecording ? 'Listening…' : 'Ready to test'),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text(
              _message ?? 'Press start, speak normally, then stop the check.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: colors.onSurfaceVariant),
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: _toggleRecording,
              icon: Icon(_isRecording ? Icons.stop_rounded : Icons.mic_rounded),
              label: Text(
                _isRecording
                    ? 'Stop microphone check'
                    : 'Start microphone check',
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Audio is recorded temporarily on this device for the check and deleted when you stop.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: colors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class SpeakerCheckPage extends StatefulWidget {
  const SpeakerCheckPage({super.key});

  @override
  State<SpeakerCheckPage> createState() => _SpeakerCheckPageState();
}

class _SpeakerCheckPageState extends State<SpeakerCheckPage> {
  final AudioPlayer _player = AudioPlayer();
  bool _playing = false;
  String? _message;
  StreamSubscription<void>? _completeSubscription;

  @override
  void initState() {
    super.initState();
    _completeSubscription = _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _playing = false);
    });
  }

  Future<void> _playTestTone() async {
    try {
      setState(() {
        _playing = true;
        _message = 'Listen for a short clear tone.';
      });
      await _player.play(BytesSource(_createTestTone()), volume: 0.35);
    } catch (_) {
      if (mounted) {
        setState(() {
          _playing = false;
          _message = 'The test tone could not play on this device.';
        });
      }
    }
  }

  Uint8List _createTestTone() {
    const sampleRate = 44100;
    const durationSeconds = 0.65;
    final sampleCount = (sampleRate * durationSeconds).round();
    final dataLength = sampleCount * 2;
    final bytes = Uint8List(44 + dataLength);
    final data = ByteData.sublistView(bytes);
    void writeTag(int offset, String value) {
      for (var i = 0; i < value.length; i++) {
        bytes[offset + i] = value.codeUnitAt(i);
      }
    }

    writeTag(0, 'RIFF');
    data.setUint32(4, 36 + dataLength, Endian.little);
    writeTag(8, 'WAVE');
    writeTag(12, 'fmt ');
    data.setUint32(16, 16, Endian.little);
    data.setUint16(20, 1, Endian.little);
    data.setUint16(22, 1, Endian.little);
    data.setUint32(24, sampleRate, Endian.little);
    data.setUint32(28, sampleRate * 2, Endian.little);
    data.setUint16(32, 2, Endian.little);
    data.setUint16(34, 16, Endian.little);
    writeTag(36, 'data');
    data.setUint32(40, dataLength, Endian.little);
    for (var i = 0; i < sampleCount; i++) {
      final fade = math.min(1.0, math.min(i / 800, (sampleCount - i) / 800));
      final sample =
          (math.sin(2 * math.pi * 660 * i / sampleRate) * 9000 * fade).round();
      data.setInt16(44 + i * 2, sample, Endian.little);
    }
    return bytes;
  }

  @override
  void dispose() {
    unawaited(_completeSubscription?.cancel());
    unawaited(_player.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Speaker check')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 35),
            Container(
              height: 230,
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(26),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _playing
                        ? Icons.graphic_eq_rounded
                        : Icons.speaker_outlined,
                    size: 72,
                    color: colors.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(_playing ? 'Playing test tone' : 'Ready to test'),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text(
              _message ?? 'Make sure your media volume is turned up, then play the tone.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: colors.onSurfaceVariant),
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: _playing ? null : _playTestTone,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Play test tone'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeviceError extends StatelessWidget {
  const _DeviceError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.no_photography_outlined,
              color: Colors.white70,
              size: 38,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
