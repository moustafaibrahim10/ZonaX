import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/voice/gemini_service.dart';
import '../../../../core/services/voice/speech_service.dart';
import '../../../../core/services/voice/tts_service.dart';
import 'voice_state.dart';

class VoiceCubit extends Cubit<VoiceState> {
  final GeminiService geminiService;
  final SpeechService speechService;
  final TtsService ttsService;

  VoiceCubit({
    required this.geminiService,
    required this.speechService,
    required this.ttsService,
  }) : super(VoiceInitial());

  Future<void> startListening() async {
    try {
      await ttsService.stop();
      emit(const VoiceListening());
      await speechService.startListening();
    } catch (e) {
      emit(VoiceError('Error listening: $e'));
    }
  }

  Future<void> _processVoiceCommand(String audioPath) async {

    emit(VoiceThinking());

    final response = await geminiService.processVoiceCommand(audioPath);

    if (response == null) {
      emit(const VoiceError('Failed to process command.'));
      return;
    }

    final isSupported = response['is_supported'] ?? false;
    final messageAr = response['message_ar'] ?? 'عفواً، لم أفهم طلبك.';
    final action = response['action'] ?? 'none';
    final intent = response['intent'] ?? 'unknown';

    final transcription = response['transcription'] ?? 'لم أفهم الصوت';

    emit(VoiceSpeaking(messageAr, transcription: transcription));
    await ttsService.speak(messageAr);

    if (isSupported && action != 'none') {
      print('VoiceCubit: Triggering action: $action, intent: $intent');
      emit(VoiceActionTriggered(action: action, intent: intent));
      // Give the listener time to react before resetting
      await Future.delayed(const Duration(seconds: 2));
    }
    
    emit(VoiceInitial());
  }

  Future<void> stopListening() async {
    try {
      final path = await speechService.stopListening();
      if (path != null && path.isNotEmpty) {
        await _processVoiceCommand(path);
      } else {
        emit(VoiceInitial());
      }
    } catch (e) {
      emit(VoiceError('Error stopping: $e'));
    }
  }
}
