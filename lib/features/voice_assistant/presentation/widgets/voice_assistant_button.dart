import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../bloc/voice_cubit.dart';
import '../bloc/voice_state.dart';

class TopVoiceAssistantBar extends StatelessWidget {
  const TopVoiceAssistantBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VoiceCubit, VoiceState>(
      listener: (context, state) {
        if (state is VoiceError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message, style: const TextStyle(color: Colors.white)),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        String mainText = "Tap to speak...";
        String subText = "Assistant is ready";
        Color iconColor = const Color(0xFF4FC3F7);
        IconData icon = Icons.mic;
        bool isAnimating = false;

        if (state is VoiceListening) {
          mainText = "Recording...";
          subText = "Tap again to stop and send";
          iconColor = const Color(0xFFFF5252);
          icon = Icons.graphic_eq;
          isAnimating = true;
        } else if (state is VoiceThinking) {
          mainText = "Processing...";
          subText = "Understanding command...";
          iconColor = const Color(0xFFFFB74D);
          icon = Icons.more_horiz;
          isAnimating = true;
        } else if (state is VoiceSpeaking) {
          mainText = state.transcription;
          subText = state.text;
          iconColor = const Color(0xFF69F0AE);
          icon = Icons.volume_up;
          isAnimating = true;
        } else if (state is VoiceActionTriggered) {
          mainText = "Done!";
          subText = "Action executed.";
          iconColor = const Color(0xFF69F0AE);
        }

        return GestureDetector(
          onTap: () {
            if (state is VoiceListening) {
              context.read<VoiceCubit>().stopListening();
            } else {
              context.read<VoiceCubit>().startListening();
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2A).withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(15.r),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                if (isAnimating && state is VoiceThinking)
                  SizedBox(
                    width: 24.sp,
                    height: 24.sp,
                    child: const CircularProgressIndicator(color: Colors.orange, strokeWidth: 2),
                  )
                else
                  Icon(icon, color: iconColor, size: 28.sp),
                SizedBox(width: 15.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        mainText,
                        style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                      ),
                      Text(
                        subText,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
