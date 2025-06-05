import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voicecontrolsmarthome/shared/cubits/voicecontrol/voice_control_cubit.dart';
import 'package:voicecontrolsmarthome/utils/constants/constants.dart';

class VoiceControlScreen extends StatelessWidget {
  const VoiceControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VoiceControlCubit(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Voice Control",
            style: Constants.twentyfoursmbold,
          ),
          centerTitle: true,
        ),
        body: BlocConsumer<VoiceControlCubit, VoiceControlState>(
          listener: (context, state) {
            if (state is VoiceControlError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            var cubit = context.read<VoiceControlCubit>();

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Display Status Message
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      state is SuccessState
                          ? state.message
                          : "Press mic to speak",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // بعد Text "Press mic to speak"
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Radio<VoiceLang>(
                              value: VoiceLang.english,
                              groupValue: cubit.selectedLang,
                              onChanged: (val) => cubit.changeLang(val!),
                            ),
                            const Text('English'),
                          ],
                        ),
                        const SizedBox(width: 20),
                        Row(
                          children: [
                            Radio<VoiceLang>(
                              value: VoiceLang.arabic,
                              groupValue: cubit.selectedLang,
                              onChanged: (val) => cubit.changeLang(val!),
                            ),
                            const Text('عربي'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Recording Button
                  IconButton(
                    icon: Icon(
                      state is RecordingState ? Icons.stop : Icons.mic,
                      size: 80,
                      color: state is RecordingState ? Colors.red : Colors.blue,
                    ),
                    onPressed: () => cubit.toggleRecording(),
                  ),
                  const SizedBox(height: 20),

                  // Display Processing Indicator
                  if (state is ProcessingState)
                    const CircularProgressIndicator(),

                  const SizedBox(height: 20),

                  // Manual Fetch Status Button
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
