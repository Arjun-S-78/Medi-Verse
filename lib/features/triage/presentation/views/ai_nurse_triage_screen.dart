import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/models/mira_conversation_state.dart';
import '../../domain/models/mira_message.dart';
import '../../domain/models/mira_mode.dart';
import '../../domain/models/mira_tts_state.dart';
import '../../domain/models/priority_level.dart';
import '../../domain/models/structured_triage_data.dart';
import '../../domain/models/triage_result.dart';
import '../providers/mira_conversation_provider.dart';
import '../providers/mira_tts_provider.dart';

/// Interactive AI-Assisted Triage Nurse Screen (MIRA) with Voice Interaction System (TTS).
class AiNurseTriageScreen extends ConsumerStatefulWidget {
  const AiNurseTriageScreen({super.key});

  @override
  ConsumerState<AiNurseTriageScreen> createState() => _AiNurseTriageScreenState();
}

class _AiNurseTriageScreenState extends ConsumerState<AiNurseTriageScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isListeningVoice = false;
  int? _selectedPainLevel;

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage({String? customText}) {
    final text = customText ?? _textController.text.trim();
    if (text.isEmpty) return;

    ref.read(miraConversationProvider.notifier).sendPatientMessage(text);
    if (customText == null) _textController.clear();
    _scrollToBottom();
  }

  void _toggleVoiceListening() {
    setState(() => _isListeningVoice = !_isListeningVoice);
    if (_isListeningVoice) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Speech Recognition active... Speak your symptoms clearly.'),
          duration: Duration(seconds: 2),
          backgroundColor: AppColors.primary500,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showTtsSettingsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Consumer(
          builder: (context, ref, child) {
            final ttsState = ref.watch(miraTtsProvider);
            final ttsNotifier = ref.read(miraTtsProvider.notifier);

            return Container(
              padding: const EdgeInsets.all(AppTokens.spaceLg),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceCard : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTokens.radius2Xl)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Voice Assistant Settings',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.neutral900,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTokens.spaceSm),
                  SwitchListTile(
                    title: const Text('Enable Voice Assistant (Text-to-Speech)'),
                    subtitle: const Text('Clinical voice assistance'),
                    value: ttsState.settings.isEnabled,
                    onChanged: (_) => ttsNotifier.toggleMute(),
                  ),
                  SwitchListTile(
                    title: const Text('Auto-play Voice Responses'),
                    subtitle: const Text('Automatically speak new triage questions'),
                    value: ttsState.settings.autoPlay,
                    onChanged: ttsState.settings.isEnabled ? (_) => ttsNotifier.toggleAutoPlay() : null,
                  ),
                  const SizedBox(height: AppTokens.spaceSm),
                  Text(
                    'Speaking Speed: ${ttsState.settings.speechRate.toStringAsFixed(2)}x',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  Slider(
                    value: ttsState.settings.speechRate,
                    min: 0.3,
                    max: 0.8,
                    divisions: 10,
                    activeColor: AppColors.primary500,
                    onChanged: ttsState.settings.isEnabled
                        ? (val) {
                            ttsNotifier.updateSettings(ttsState.settings.copyWith(speechRate: val));
                          }
                        : null,
                  ),
                  if (ttsState.activeVoiceName != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Active Engine Voice: ${ttsState.activeVoiceName} (${ttsState.activeLanguage ?? "en-US"})',
                      style: TextStyle(fontSize: 12, color: isDark ? AppColors.neutral400 : AppColors.neutral600),
                    ),
                  ],
                  const SizedBox(height: AppTokens.spaceMd),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showStructuredDataDrawer(StructuredTriageData data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(AppTokens.spaceLg),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceCard : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTokens.radius2Xl)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Extracted Clinical Triage Data',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.neutral900,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: AppTokens.spaceMd),
              _buildDataRow('Chief Complaint', data.chiefComplaint ?? 'Not provided', isDark),
              _buildDataRow('Onset Time', data.onset ?? 'Unknown', isDark),
              _buildDataRow('Pain Level', data.painLevel != null ? '${data.painLevel}/10' : 'Unrated', isDark),
              _buildDataRow('Breathing Difficulty', data.breathingDifficulty?.toString() ?? 'Unasked', isDark),
              _buildDataRow('Chest Pain Indicator', data.chestPain?.toString() ?? 'Unasked', isDark),
              _buildDataRow('Severe Bleeding', data.severeBleeding?.toString() ?? 'Unasked', isDark),
              _buildDataRow('Major Trauma', data.majorTrauma?.toString() ?? 'Unasked', isDark),
              _buildDataRow('Seizure Activity', data.seizure?.toString() ?? 'Unasked', isDark),
              if (data.medicalConditions.isNotEmpty)
                _buildDataRow('Medical History', data.medicalConditions.join(', '), isDark),
              const SizedBox(height: AppTokens.spaceLg),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDataRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isDark ? AppColors.neutral400 : AppColors.neutral600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(miraConversationProvider);
    final ttsState = ref.watch(miraTtsProvider);
    final ttsNotifier = ref.read(miraTtsProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.darkCanvas,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            MiraAvatarWidget(
              size: 38,
              mode: MiraMode.triage,
              isSpeaking: ttsState.isSpeaking,
              isListening: _isListeningVoice,
              showStatusBadge: false,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Clinical Triage',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (ttsState.isSpeaking) ...[
                      const SizedBox(width: 8),
                      _buildAudioWaveformBadge(),
                    ],
                  ],
                ),
                Text(
                  _isListeningVoice
                      ? 'Listening to voice...'
                      : (ttsState.isSpeaking ? 'Speaking...' : 'AI Emergency Nurse'),
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: ttsState.isSpeaking
                        ? AppColors.esi4LessUrgent
                        : (isDark ? AppColors.neutral400 : AppColors.neutral600),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              ttsState.settings.isEnabled ? LucideIcons.volume2 : LucideIcons.volumeX,
              color: ttsState.settings.isEnabled ? AppColors.primary500 : AppColors.neutral400,
            ),
            tooltip: ttsState.settings.isEnabled ? 'Mute Voice' : 'Unmute Voice',
            onPressed: () => ttsNotifier.toggleMute(),
          ),
          IconButton(
            icon: Icon(LucideIcons.settings, color: isDark ? AppColors.neutral400 : AppColors.neutral600),
            tooltip: 'Voice Settings',
            onPressed: _showTtsSettingsSheet,
          ),
          IconButton(
            icon: Icon(LucideIcons.fileText, color: isDark ? AppColors.neutral400 : AppColors.neutral600),
            tooltip: 'View Triage Summary',
            onPressed: () => _showStructuredDataDrawer(state.structuredData),
          ),
          IconButton(
            icon: Icon(LucideIcons.rotateCcw, color: isDark ? AppColors.neutral400 : AppColors.neutral600),
            tooltip: 'Reset Conversation',
            onPressed: () {
              ref.read(miraConversationProvider.notifier).resetSession();
              ref.read(miraTtsProvider.notifier).stop();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Clinical Disclaimer Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: AppTokens.spaceMd, vertical: 8),
              color: AppColors.primary500.withValues(alpha: 0.08),
              child: const Text(
                'ℹ️ MediVerse Triage is an automated clinical triage coordinator — NOT a diagnostic tool.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.primary500),
              ),
            ),

            // Emergency Red Flag Alert Header
            if (state.isEmergencyEscalation || (state.triageResult?.priority == PriorityLevel.critical))
              Container(
                margin: const EdgeInsets.all(AppTokens.spaceMd),
                padding: const EdgeInsets.all(AppTokens.spaceMd),
                decoration: BoxDecoration(
                  color: AppColors.esi1Critical.withValues(alpha: 0.12),
                  borderRadius: AppTokens.borderRadiusLg,
                  border: Border.all(color: AppColors.esi1Critical, width: 2),
                ),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Icon(LucideIcons.alertTriangle, color: AppColors.esi1Critical, size: 24),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'CRITICAL EMERGENCY RED FLAG DETECTED',
                            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.esi1Critical, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    EmergencyButton(
                      isFullWidth: true,
                      label: 'DISPATCH AMBULANCE NOW',
                      onTap: () {
                        ttsNotifier.stop();
                        context.push(RouteNames.searchingAmbulance);
                      },
                    ),
                  ],
                ),
              ).animate().fade(duration: 400.ms),

            // Conversation Feed
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(AppTokens.spaceMd),
                itemCount: state.messages.length + (state.isProcessing ? 1 : 0),
                itemBuilder: (context, index) {
                  // Last item when processing = typing indicator bubble
                  if (state.isProcessing && index == state.messages.length) {
                    return const _TypingIndicatorBubble();
                  }
                  final message = state.messages[index];
                  return _buildMessageBubble(message, ttsState, ttsNotifier, isDark);
                },
              ),
            ),

            // Interactive Pain Scale (0-10) Selector when pain assessment is active
            if (!state.isCompleted) _buildInteractivePainScaleWidget(isDark),

            // Triage Result View when assessment completes
            if (state.isCompleted && state.triageResult != null)
              _buildTriageResultCard(state.triageResult!, isDark),

            // Bottom Input Control Bar
            _buildInputBar(state, isDark),
          ],
        ),
      ),
    );
  }

  // Audio Waveform Animated Badge for Voice UI
  Widget _buildAudioWaveformBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.esi4LessUrgent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...List.generate(3, (i) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              width: 2,
              height: (i % 2 == 0 ? 8.0 : 12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(1),
              ),
            );
          }).animate(onPlay: (c) => c.repeat(reverse: true)).scaleY(begin: 0.4, end: 1.2),
          const SizedBox(width: 4),
          const Text('SPEAKING', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Interactive Pain Intensity Rating Scale (0 to 10 Chips)
  Widget _buildInteractivePainScaleWidget(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTokens.spaceMd, vertical: AppTokens.spaceSm),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceCard : Colors.white,
        border: Border(top: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.neutral200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Clinical Pain Scale Rating (0-10)',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.neutral400 : AppColors.neutral600,
                ),
              ),
              if (_selectedPainLevel != null)
                Text(
                  'Selected: $_selectedPainLevel/10 (${_getPainLabel(_selectedPainLevel!)})',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _getPainColor(_selectedPainLevel!),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(11, (index) {
                final color = _getPainColor(index);
                final isSelected = _selectedPainLevel == index;
                return Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: InkWell(
                    onTap: () {
                      setState(() => _selectedPainLevel = index);
                      _sendMessage(customText: 'My pain level is $index out of 10.');
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: AnimatedContainer(
                      duration: AppTokens.durationFast,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? color : color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? color : color.withValues(alpha: 0.4),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Text(
                        '$index',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : (isDark ? Colors.white : AppColors.neutral900),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPainColor(int score) {
    if (score <= 3) return AppColors.esi4LessUrgent;
    if (score <= 6) return AppColors.esi3Urgent;
    return AppColors.esi1Critical;
  }

  String _getPainLabel(int score) {
    if (score == 0) return 'None';
    if (score <= 3) return 'Mild';
    if (score <= 6) return 'Moderate';
    if (score <= 8) return 'Severe';
    return 'Unbearable';
  }

  Widget _buildMessageBubble(
    MiraMessage message,
    MiraTtsState ttsState,
    MiraTtsNotifier ttsNotifier,
    bool isDark,
  ) {
    final isPatient = message.sender == MiraSender.patient;
    final isSystem = message.sender == MiraSender.system;
    final isThisMessageSpeaking = ttsState.isSpeaking && ttsState.currentMessageId == message.id;

    if (isSystem) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primary500.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message.text,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: isDark ? AppColors.neutral400 : AppColors.neutral600),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: isPatient ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isPatient ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isPatient) ...[
                MiraAvatarWidget(
                  size: 36,
                  mode: message.requiresEmergencyAction ? MiraMode.emergency : MiraMode.triage,
                  isSpeaking: isThisMessageSpeaking,
                  showStatusBadge: false,
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isPatient
                        ? AppColors.primary500
                        : (message.requiresEmergencyAction
                            ? AppColors.esi1Critical.withValues(alpha: 0.12)
                            : (isDark ? AppColors.darkSurfaceCard : Colors.white)),
                    borderRadius: BorderRadius.circular(18).copyWith(
                      bottomRight: isPatient ? const Radius.circular(2) : const Radius.circular(18),
                      bottomLeft: !isPatient ? const Radius.circular(2) : const Radius.circular(18),
                    ),
                    border: !isPatient
                        ? Border.all(
                            color: isThisMessageSpeaking
                                ? AppColors.esi4LessUrgent
                                : (message.requiresEmergencyAction
                                    ? AppColors.esi1Critical
                                    : (isDark ? AppColors.darkBorder : AppColors.neutral200)),
                            width: isThisMessageSpeaking ? 2 : 1,
                          )
                        : null,
                    boxShadow: AppTokens.shadowSm(isDark),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Use streaming widget for MIRA messages that are animating,
                      // or plain text for patient messages and already-streamed messages
                      if (!isPatient && message.isStreaming)
                        _StreamingTextWidget(
                          key: ValueKey('stream_${message.id}'),
                          fullText: message.text,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            height: 1.4,
                            color: isDark ? Colors.white : AppColors.neutral900,
                          ),
                          onComplete: () {
                            ref
                                .read(miraConversationProvider.notifier)
                                .markMessageStreamingComplete(message.id);
                            _scrollToBottom();
                            // Start TTS only after text fully streams in
                            if (ttsState.settings.autoPlay && ttsState.settings.isEnabled) {
                              ttsNotifier.speakMessage(message);
                            }
                          },
                        )
                      else
                        Text(
                          message.text,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            height: 1.4,
                            color: isPatient
                                ? Colors.white
                                : (isDark ? Colors.white : AppColors.neutral900),
                          ),
                        ),

                      // Replay / Stop Voice Button — only visible after streaming
                      if (!isPatient && !message.isStreaming) ...[
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () {
                            if (isThisMessageSpeaking) {
                              ttsNotifier.stop();
                            } else {
                              ttsNotifier.speakMessage(message);
                            }
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isThisMessageSpeaking
                                  ? AppColors.esi1Critical.withValues(alpha: 0.15)
                                  : AppColors.primary500.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isThisMessageSpeaking ? LucideIcons.square : LucideIcons.volume2,
                                  size: 12,
                                  color: isThisMessageSpeaking ? AppColors.esi1Critical : AppColors.primary500,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isThisMessageSpeaking ? 'Stop Voice' : 'Play Voice',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isThisMessageSpeaking ? AppColors.esi1Critical : AppColors.primary500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Quick Replies Chips — only visible after streaming finishes
          if (!isPatient && !message.isStreaming && message.quickReplies != null && message.quickReplies!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: message.quickReplies!.map((reply) {
                return ActionChip(
                  label: Text(reply, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                  backgroundColor: AppColors.primary500.withValues(alpha: 0.1),
                  side: const BorderSide(color: AppColors.primary500),
                  onPressed: () {
                    ttsNotifier.stop();
                    _sendMessage(customText: reply);
                  },
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  // Triage Result Summary Screen Card
  Widget _buildTriageResultCard(TriageResult result, bool isDark) {
    return Container(
      margin: const EdgeInsets.all(AppTokens.spaceMd),
      padding: const EdgeInsets.all(AppTokens.spaceLg),
      decoration: BoxDecoration(
        color: result.priority.surfaceColorLight.withValues(alpha: isDark ? 0.25 : 0.95),
        borderRadius: AppTokens.borderRadius2Xl,
        border: Border.all(color: result.priority.color, width: 2),
        boxShadow: AppTokens.shadowMd(isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: result.priority.color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  result.priority.label.toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              Text(
                'Clinical Priority Level',
                style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.spaceMd),
          Text(
            result.recommendedAction,
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppTokens.spaceSm),
          Text(
            'Contributing Risk Factors:',
            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : Colors.black54),
          ),
          const SizedBox(height: 4),
          ...result.reasons.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 2.0),
                child: Text('• $r', style: GoogleFonts.poppins(fontSize: 12)),
              )),
          const SizedBox(height: AppTokens.spaceMd),
          EmergencyButton(
            isFullWidth: true,
            label: 'REQUEST EMERGENCY AMBULANCE',
            onTap: () {
              ref.read(miraTtsProvider.notifier).stop();
              context.push(RouteNames.searchingAmbulance);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(MiraConversationState state, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTokens.spaceMd, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceCard : Colors.white,
        boxShadow: AppTokens.shadowSm(isDark),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              _isListeningVoice ? LucideIcons.micOff : LucideIcons.mic,
              color: _isListeningVoice ? AppColors.esi1Critical : AppColors.primary500,
            ),
            onPressed: _toggleVoiceListening,
          ),
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: _isListeningVoice ? 'Listening...' : 'Describe symptoms or answer triage questions...',
                hintStyle: TextStyle(fontSize: 13, color: isDark ? AppColors.neutral400 : AppColors.neutral600),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: isDark ? AppColors.darkCanvas : AppColors.neutral100,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(LucideIcons.send, color: AppColors.primary500),
            onPressed: () => _sendMessage(),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Typing Indicator Bubble — 3 bouncing dots (like ChatGPT / WhatsApp)
// ---------------------------------------------------------------------------
class _TypingIndicatorBubble extends StatefulWidget {
  const _TypingIndicatorBubble();

  @override
  State<_TypingIndicatorBubble> createState() => _TypingIndicatorBubbleState();
}

class _TypingIndicatorBubbleState extends State<_TypingIndicatorBubble>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      ),
    );
    _animations = _controllers.map((c) {
      return Tween<double>(begin: 0, end: -8).animate(
        CurvedAnimation(parent: c, curve: Curves.easeInOut),
      );
    }).toList();

    // Stagger each dot 150ms apart, loop forever
    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary500.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary500.withValues(alpha: 0.4)),
            ),
            child: const Icon(LucideIcons.bot, size: 16, color: AppColors.primary500),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceCard : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(2),
              ),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.neutral200,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return AnimatedBuilder(
                  animation: _animations[i],
                  builder: (context, _) {
                    return Transform.translate(
                      offset: Offset(0, _animations[i].value),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.primary500.withValues(alpha: 0.7),
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Streaming Text Widget — reveals text character by character (ChatGPT style)
// ---------------------------------------------------------------------------
class _StreamingTextWidget extends StatefulWidget {
  final String fullText;
  final TextStyle style;
  final VoidCallback onComplete;

  const _StreamingTextWidget({
    super.key,
    required this.fullText,
    required this.style,
    required this.onComplete,
  });

  @override
  State<_StreamingTextWidget> createState() => _StreamingTextWidgetState();
}

class _StreamingTextWidgetState extends State<_StreamingTextWidget> {
  String _displayedText = '';
  Timer? _timer;
  int _charIndex = 0;

  // Characters revealed per tick — higher = faster streaming
  static const int _charsPerTick = 2;
  // Delay between ticks in milliseconds — lower = faster
  static const int _tickMs = 18;

  @override
  void initState() {
    super.initState();
    _startStreaming();
  }

  void _startStreaming() {
    _timer = Timer.periodic(const Duration(milliseconds: _tickMs), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final end = (_charIndex + _charsPerTick).clamp(0, widget.fullText.length);
      setState(() {
        _displayedText = widget.fullText.substring(0, end);
        _charIndex = end;
      });
      if (_charIndex >= widget.fullText.length) {
        timer.cancel();
        // Notify provider that streaming is complete
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayedText,
      style: widget.style,
    );
  }
}
