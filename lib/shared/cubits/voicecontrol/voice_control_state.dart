part of 'voice_control_cubit.dart';

@immutable
abstract class VoiceControlState {
  const VoiceControlState();
}

class InitialState extends VoiceControlState {
  const InitialState();
}

class RecordingState extends VoiceControlState {
  const RecordingState();
}

class ProcessingState extends VoiceControlState {
  const ProcessingState();
}

class SuccessState extends VoiceControlState {
  final String message;
  const SuccessState(this.message);
}

class VoiceControlError extends VoiceControlState {
  final String message;
  const VoiceControlError(this.message);
}
