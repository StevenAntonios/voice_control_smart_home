import 'dart:developer';
import 'package:voicecontrolsmarthome/index.dart';
part 'voice_control_state.dart';
enum VoiceLang { english, arabic }
class VoiceControlCubit extends Cubit<VoiceControlState> {
  final AudioRecorder _record = AudioRecorder();
  String? _currentPath;
  VoiceLang selectedLang = VoiceLang.english;
  VoiceControlCubit() : super(const InitialState());
    void changeLang(VoiceLang lang) {
    selectedLang = lang;
    emit(InitialState()); // Re-render
  }

  /// **🎙️ Toggle Recording (Start/Stop)**
  Future<void> toggleRecording() async {
    if (state is RecordingState) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    try {
      if (await _record.hasPermission()) {
        final config = RecordConfig(
          encoder: AudioEncoder.wav,
          bitRate: 128000,
          sampleRate: 44100,
        );

        _currentPath = await _getPath();
        await _record.start(config, path: _currentPath!);
        emit(const RecordingState());
      }
    } catch (e, stackTrace) {
      emit(VoiceControlError('Recording failed: ${_formatError(e, stackTrace)}'));
    }
  }

  Future<void> _stopRecording() async {
    try {
      await _record.stop();
      if (_currentPath != null) {
        emit(const ProcessingState());
        await _sendAudio(File(_currentPath!));
        _currentPath = null;
      }
    } catch (e, stackTrace) {
      emit(VoiceControlError('Stop failed: ${_formatError(e, stackTrace)}'));
    }
  }

  /// **🎤 Send Audio to Flask for Speech Processing**
  Future<void> _sendAudio(File audioFile) async {
    try {
      FormData formData = FormData.fromMap({
        "audio": await MultipartFile.fromFile(audioFile.path, filename: audioFile.path.split(Platform.pathSeparator).last),
      });
      String endPoint = selectedLang == VoiceLang.english
          ? "process-command"
          : "process-command-ar";
      Response response = await DioHelper.postFileRequest(endPoint: endPoint, formData: formData);

      if (response.statusCode == 200) {
        final responseBody = response.data;
        emit(SuccessState(responseBody['text'] ?? responseBody.toString()));
        log('✅ SuccessState: $responseBody');
      } else {
        emit(VoiceControlError('Server error: ${response.statusMessage}'));
        log('❌ Server error: ${response.statusMessage}');
      }
    } catch (e, stackTrace) {
      emit(VoiceControlError('Upload failed: ${_formatError(e, stackTrace)}'));
      log('❌ Upload failed: ${_formatError(e, stackTrace)}');
    }
  }

  String _formatError(dynamic error, StackTrace stackTrace) {
    return '$error\n${stackTrace.toString().split('\n').take(3).join('\n')}';
  }

  Future<String> _getPath() async {
    final dir = await getTemporaryDirectory();
    return '${dir.path}/command_${DateTime.now().millisecondsSinceEpoch}.wav';
  }

  @override
  Future<void> close() async {
    await _record.dispose();
    return super.close();
  }
}
