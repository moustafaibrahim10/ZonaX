import 'package:equatable/equatable.dart';

abstract class VoiceState extends Equatable {
  const VoiceState();

  @override
  List<Object?> get props => [];
}

class VoiceInitial extends VoiceState {}

class VoiceListening extends VoiceState {
  const VoiceListening();
}

class VoiceThinking extends VoiceState {}

class VoiceSpeaking extends VoiceState {
  final String text;
  final String transcription;
  const VoiceSpeaking(this.text, {this.transcription = ''});

  @override
  List<Object?> get props => [text, transcription];
}

class VoiceActionTriggered extends VoiceState {
  final String action;
  final String? intent;
  const VoiceActionTriggered({required this.action, this.intent});

  @override
  List<Object?> get props => [action, intent];
}

class VoiceError extends VoiceState {
  final String message;
  const VoiceError(this.message);

  @override
  List<Object?> get props => [message];
}
