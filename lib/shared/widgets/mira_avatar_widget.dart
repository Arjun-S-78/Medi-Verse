import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../features/triage/domain/models/mira_mode.dart';

/// Reusable MIRA Female AI Healthcare Assistant Avatar Widget.
///
/// Displays a consistent visual identity across Home Dashboard, Conversational Triage,
/// Emergency Dispatch, and Voice UI views. Includes animated status indicators for
/// IDLE, LISTENING, PROCESSING, SPEAKING, and EMERGENCY states.
class MiraAvatarWidget extends StatelessWidget {
  final double size;
  final MiraMode mode;
  final bool isSpeaking;
  final bool isListening;
  final bool isProcessing;
  final bool showStatusBadge;
  final VoidCallback? onTap;

  const MiraAvatarWidget({
    super.key,
    this.size = 48,
    this.mode = MiraMode.normal,
    this.isSpeaking = false,
    this.isListening = false,
    this.isProcessing = false,
    this.showStatusBadge = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final avatarColor = mode.avatarColor;
    final isActiveState = isSpeaking || isListening || isProcessing || mode == MiraMode.emergency;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size + 20,
        height: size + 20,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer Listening / Processing Outer Halo Ring
            if (isListening)
              Container(
                width: size + 18,
                height: size + 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryAccent.withValues(alpha: 0.6), width: 2),
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true))
               .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.15, 1.15), duration: AppTokens.durationSlow)
               .fade(begin: 0.8, end: 0.2),

            if (isProcessing)
              Container(
                width: size + 16,
                height: size + 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.secondary500.withValues(alpha: 0.5), width: 2),
                ),
              ).animate(onPlay: (c) => c.repeat())
               .rotate(duration: const Duration(milliseconds: 2000)),

            // Outer Pulse Glow Layer (Speaking / Emergency)
            Container(
              width: size + 12,
              height: size + 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: avatarColor.withValues(alpha: isActiveState ? 0.2 : 0.08),
                border: Border.all(
                  color: avatarColor.withValues(alpha: isActiveState ? 0.5 : 0.15),
                  width: isActiveState ? 2 : 1,
                ),
              ),
            ),

            // Main Avatar Container
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    avatarColor,
                    AppColors.primary600,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: avatarColor.withValues(alpha: 0.35),
                    blurRadius: isActiveState ? 14 : 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // MIRA Image Face Asset
                    Image.asset(
                      'assets/images/MIRA.png',
                      width: size,
                      height: size,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/images/mira.png',
                          width: size,
                          height: size,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error2, stackTrace2) {
                            return Icon(
                              mode == MiraMode.emergency
                                  ? Icons.medical_services_rounded
                                  : (isListening ? Icons.mic_rounded : Icons.support_agent_rounded),
                              color: Colors.white,
                              size: size * 0.52,
                            );
                          },
                        );
                      },
                    ),

                    // Waveform pulse line when speaking
                    if (isSpeaking)
                      Positioned(
                        bottom: size * 0.18,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(4, (index) {
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 1.5),
                              width: 2.5,
                              height: (index % 2 == 0 ? 8.0 : 12.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            );
                          }),
                        ).animate(onPlay: (c) => c.repeat(reverse: true))
                         .scaleY(begin: 0.5, end: 1.3, duration: const Duration(milliseconds: 300)),
                      ),
                  ],
                ),
              ),
            ),

            // Active Mode / Status Indicator Badge
            if (showStatusBadge)
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isSpeaking
                        ? AppColors.esi4LessUrgent
                        : (isListening ? AppColors.primaryAccent : avatarColor),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: AppTokens.shadowSm(false),
                  ),
                  child: Icon(
                    isSpeaking
                        ? Icons.volume_up_rounded
                        : (isListening
                            ? Icons.graphic_eq_rounded
                            : (isProcessing ? Icons.sync_rounded : Icons.auto_awesome)),
                    color: isListening ? AppColors.neutral900 : Colors.white,
                    size: size * 0.24,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
