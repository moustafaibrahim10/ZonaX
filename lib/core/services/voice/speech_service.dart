import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

class SpeechService {
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isInitialized = false;
  String? _currentPath;

  Future<bool> initialize() async {
    if (_isInitialized) return true;

    final hasPermission = await _audioRecorder.hasPermission();
    if (!hasPermission) return false;

    _isInitialized = true;
    return true;
  }

  Future<void> startListening() async {
    if (!_isInitialized) {
      final init = await initialize();
      if (!init) throw Exception('Microphone permission not granted');
    }

    final directory = await getTemporaryDirectory();
    _currentPath = '${directory.path}/voice_command.wav';

    await _audioRecorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
        bitRate: 128000,
        sampleRate: 44100,
      ),
      path: _currentPath!,
    );
  }

  Future<String?> stopListening() async {
    final path = await _audioRecorder.stop();
    return path;
  }

  Future<bool> get isListening async => await _audioRecorder.isRecording();
}
