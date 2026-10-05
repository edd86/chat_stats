import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../chat_import/domain/models/participant_model.dart';
import '../../domain/models/conversation_dynamics.dart';
import '../../domain/models/message_analysis.dart';
import '../providers/chat_dashboard_provider.dart';

class ParticipantVersusPage extends ConsumerStatefulWidget {
  final int chatId;

  const ParticipantVersusPage({super.key, required this.chatId});

  @override
  ConsumerState<ParticipantVersusPage> createState() =>
      _ParticipantVersusPageState();
}

class _ParticipantVersusPageState extends ConsumerState<ParticipantVersusPage> {
  String? _selectedPersonA;
  String? _selectedPersonB;

  String _formatDuration(Duration d) {
    if (d.inDays >= 1) {
      final h = d.inHours % 24;
      return h > 0 ? '${d.inDays}d ${h}h' : '${d.inDays}d';
    } else if (d.inHours >= 1) {
      final m = d.inMinutes % 60;
      return m > 0 ? '${d.inHours}h ${m}m' : '${d.inHours}h';
    } else if (d.inMinutes >= 1) {
      final s = d.inSeconds % 60;
      return s > 0 ? '${d.inMinutes}m ${s}s' : '${d.inMinutes}m';
    } else {
      return '${d.inSeconds}s';
    }
  }

  @override
  Widget build(BuildContext context) {
    final participantsAsync = ref.watch(
      chatParticipantsProvider(widget.chatId),
    );
    final analysisAsync = ref.watch(chatAnalysisProvider(widget.chatId));
    final dynamicsAsync = ref.watch(chatDynamicsProvider(widget.chatId));
    final chatAsync = ref.watch(chatDetailProvider(widget.chatId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Duelo: Cara a Cara ⚔️'),
      ),
      body: participantsAsync.when(
        data: (participants) {
          if (participants.length < 2) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  'Se necesitan al menos 2 participantes en el chat para hacer una comparativa cara a cara.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.onSurfaceVariant),
                ),
              ),
            );
          }

          // Default selection to top 2 if not set
          _selectedPersonA ??= participants[0].name;
          _selectedPersonB ??= participants[1].name;

          final analysis = analysisAsync.value ?? MessageAnalysis.empty();
          final dynamics = dynamicsAsync.value ?? ConversationDynamics.empty();
          final chat = chatAsync.value;

          ParticipantAnalysis? dataA;
          ParticipantAnalysis? dataB;

          for (final p in analysis.participants) {
            if (p.name == _selectedPersonA) dataA = p;
            if (p.name == _selectedPersonB) dataB = p;
          }

          ParticipantModel? pModelA;
          ParticipantModel? pModelB;
          for (final p in participants) {
            if (p.name == _selectedPersonA) pModelA = p;
            if (p.name == _selectedPersonB) pModelB = p;
          }

          Duration? responseTimeA;
          Duration? responseTimeB;
          for (final r in dynamics.responseTimes) {
            if (r.name == _selectedPersonA) responseTimeA = r.avgResponseTime;
            if (r.name == _selectedPersonB) responseTimeB = r.avgResponseTime;
          }

          final consecutiveA = dynamics.consecutiveMax[_selectedPersonA] ?? 0;
          final consecutiveB = dynamics.consecutiveMax[_selectedPersonB] ?? 0;

          final totalChatMsgs = chat?.totalMessages ?? 1;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Selection Row with VS badge
                _buildSelectors(participants),
                const SizedBox(height: 20),

                // Versus Comparison Cards
                _buildVersusRow(
                  title: 'Mensajes Enviados',
                  valA: '${pModelA?.messageCount ?? 0}',
                  valB: '${pModelB?.messageCount ?? 0}',
                  subA:
                      '${((pModelA?.messageCount ?? 0) / totalChatMsgs * 100).toStringAsFixed(1)}% del chat',
                  subB:
                      '${((pModelB?.messageCount ?? 0) / totalChatMsgs * 100).toStringAsFixed(1)}% del chat',
                  numA: (pModelA?.messageCount ?? 0).toDouble(),
                  numB: (pModelB?.messageCount ?? 0).toDouble(),
                  icon: Icons.chat_bubble_outline_rounded,
                ),
                const SizedBox(height: 12),

                _buildVersusRow(
                  title: 'Total de Palabras',
                  valA: '${dataA?.wordsCount ?? pModelA?.wordCount ?? 0}',
                  valB: '${dataB?.wordsCount ?? pModelB?.wordCount ?? 0}',
                  subA:
                      '~${(dataA?.avgChars ?? 0).toStringAsFixed(0)} car./msg',
                  subB:
                      '~${(dataB?.avgChars ?? 0).toStringAsFixed(0)} car./msg',
                  numA: (dataA?.wordsCount ?? pModelA?.wordCount ?? 0)
                      .toDouble(),
                  numB: (dataB?.wordsCount ?? pModelB?.wordCount ?? 0)
                      .toDouble(),
                  icon: Icons.article_outlined,
                ),
                const SizedBox(height: 12),

                _buildVersusRow(
                  title: 'Archivos Multimedia',
                  valA: '${pModelA?.mediaCount ?? 0}',
                  valB: '${pModelB?.mediaCount ?? 0}',
                  subA: 'Fotos, audios y stickers',
                  subB: 'Fotos, audios y stickers',
                  numA: (pModelA?.mediaCount ?? 0).toDouble(),
                  numB: (pModelB?.mediaCount ?? 0).toDouble(),
                  icon: Icons.perm_media_outlined,
                ),
                const SizedBox(height: 12),

                _buildVersusRow(
                  title: 'Velocidad de Respuesta',
                  valA: responseTimeA != null
                      ? _formatDuration(responseTimeA)
                      : 'N/A',
                  valB: responseTimeB != null
                      ? _formatDuration(responseTimeB)
                      : 'N/A',
                  subA: 'Tiempo promedio',
                  subB: 'Tiempo promedio',
                  // Lower duration is better
                  numA: responseTimeA != null
                      ? -responseTimeA.inSeconds.toDouble()
                      : -999999,
                  numB: responseTimeB != null
                      ? -responseTimeB.inSeconds.toDouble()
                      : -999999,
                  icon: Icons.speed_rounded,
                ),
                const SizedBox(height: 12),

                _buildVersusRow(
                  title: 'Preguntas Realizadas',
                  valA: '${dataA?.questionCount ?? 0}',
                  valB: '${dataB?.questionCount ?? 0}',
                  subA: 'Signos de interrogación',
                  subB: 'Signos de interrogación',
                  numA: (dataA?.questionCount ?? 0).toDouble(),
                  numB: (dataB?.questionCount ?? 0).toDouble(),
                  icon: Icons.help_outline_rounded,
                ),
                const SizedBox(height: 12),

                _buildVersusRow(
                  title: 'Mensajes de Madrugada (00-06h)',
                  valA: '${dataA?.nightMessagesCount ?? 0}',
                  valB: '${dataB?.nightMessagesCount ?? 0}',
                  subA: 'Modo noctámbulo 🦉',
                  subB: 'Modo noctámbulo 🦉',
                  numA: (dataA?.nightMessagesCount ?? 0).toDouble(),
                  numB: (dataB?.nightMessagesCount ?? 0).toDouble(),
                  icon: Icons.nightlight_round,
                ),
                const SizedBox(height: 12),

                _buildVersusRow(
                  title: 'Racha de Mensajes Consecutivos',
                  valA: '$consecutiveA msgs',
                  valB: '$consecutiveB msgs',
                  subA: 'Monólogos sin pausa',
                  subB: 'Monólogos sin pausa',
                  numA: consecutiveA.toDouble(),
                  numB: consecutiveB.toDouble(),
                  icon: Icons.record_voice_over_rounded,
                ),
                const SizedBox(height: 16),

                // Favorite Emojis Side-by-Side
                _buildEmojisComparison(dataA, dataB),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildSelectors(List<ParticipantModel> participants) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant, width: 0.8),
      ),
      child: Row(
        children: [
          // Selector Person A
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PARTICIPANTE A',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: _selectedPersonA,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceContainerLow,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  dropdownColor: AppColors.surfaceContainerHigh,
                  items: participants.map((p) {
                    return DropdownMenuItem<String>(
                      value: p.name,
                      child: Text(
                        p.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedPersonA = val);
                    }
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                ),
              ),
              child: const Text(
                'VS',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          // Selector Person B
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PARTICIPANTE B',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: _selectedPersonB,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceContainerLow,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  dropdownColor: AppColors.surfaceContainerHigh,
                  items: participants.map((p) {
                    return DropdownMenuItem<String>(
                      value: p.name,
                      child: Text(
                        p.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedPersonB = val);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersusRow({
    required String title,
    required String valA,
    required String valB,
    required String subA,
    required String subB,
    required double numA,
    required double numB,
    required IconData icon,
  }) {
    final aWins = numA > numB;
    final bWins = numB > numA;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outlineVariant, width: 0.6),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: AppColors.onSurfaceVariant),
              const SizedBox(width: 6),
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Column A
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            valA,
                            style: TextStyle(
                              color: aWins
                                  ? AppColors.primary
                                  : AppColors.onSurface,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (aWins) ...[
                          const SizedBox(width: 4),
                          const Text('👑', style: TextStyle(fontSize: 13)),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subA,
                      style: const TextStyle(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Visual comparison bar
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Row(
                        children: [
                          Expanded(
                            flex: (numA > 0 ? (numA / (numA + numB) * 100).round() : 1)
                                .clamp(1, 99),
                            child: Container(
                              height: 6,
                              color: aWins
                                  ? AppColors.primary
                                  : AppColors.primary.withValues(alpha: 0.4),
                            ),
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            flex: (numB > 0 ? (numB / (numA + numB) * 100).round() : 1)
                                .clamp(1, 99),
                            child: Container(
                              height: 6,
                              color: bWins
                                  ? AppColors.secondary
                                  : AppColors.secondary.withValues(alpha: 0.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Column B
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (bWins) ...[
                          const Text('👑', style: TextStyle(fontSize: 13)),
                          const SizedBox(width: 4),
                        ],
                        Flexible(
                          child: Text(
                            valB,
                            style: TextStyle(
                              color: bWins
                                  ? AppColors.secondary
                                  : AppColors.onSurface,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subB,
                      style: const TextStyle(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmojisComparison(
    ParticipantAnalysis? dataA,
    ParticipantAnalysis? dataB,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'TOP 3 EMOJIS FAVORITOS',
              style: TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedPersonA ?? 'A',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    if ((dataA?.topEmojis ?? []).isEmpty)
                      const Text(
                        'Sin emojis',
                        style: TextStyle(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        children: dataA!.topEmojis.take(3).map((e) {
                          return Chip(
                            label: Text('${e.emoji} ${e.count}'),
                            backgroundColor: AppColors.surfaceContainerLow,
                            padding: EdgeInsets.zero,
                            labelStyle: const TextStyle(fontSize: 12),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
              Container(width: 1, height: 60, color: AppColors.outlineVariant),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _selectedPersonB ?? 'B',
                      style: const TextStyle(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    if ((dataB?.topEmojis ?? []).isEmpty)
                      const Text(
                        'Sin emojis',
                        style: TextStyle(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        alignment: WrapAlignment.end,
                        children: dataB!.topEmojis.take(3).map((e) {
                          return Chip(
                            label: Text('${e.emoji} ${e.count}'),
                            backgroundColor: AppColors.surfaceContainerLow,
                            padding: EdgeInsets.zero,
                            labelStyle: const TextStyle(fontSize: 12),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
