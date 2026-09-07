import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../chat_import/domain/models/chat_model.dart';
import '../../domain/models/conversation_dynamics.dart';
import '../../domain/models/message_analysis.dart';

class ChatWrappedDialog extends StatefulWidget {
  final ChatModel chat;
  final ConversationDynamics dynamics;
  final MessageAnalysis analysis;
  final Map<String, dynamic>? recordDay;

  const ChatWrappedDialog({
    super.key,
    required this.chat,
    required this.dynamics,
    required this.analysis,
    required this.recordDay,
  });

  static void show(
    BuildContext context, {
    required ChatModel chat,
    required ConversationDynamics dynamics,
    required MessageAnalysis analysis,
    required Map<String, dynamic>? recordDay,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Chat Wrapped',
      barrierColor: Colors.black.withValues(alpha: 0.85),
      pageBuilder: (context, anim1, anim2) {
        return ChatWrappedDialog(
          chat: chat,
          dynamics: dynamics,
          analysis: analysis,
          recordDay: recordDay,
        );
      },
    );
  }

  @override
  State<ChatWrappedDialog> createState() => _ChatWrappedDialogState();
}

class _ChatWrappedDialogState extends State<ChatWrappedDialog>
    with SingleTickerProviderStateMixin {
  final int _totalStories = 5;
  int _currentIndex = 0;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );

    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (_currentIndex < _totalStories - 1) {
          setState(() {
            _currentIndex++;
          });
          _animController.forward(from: 0.0);
        } else {
          _animController.stop();
        }
      }
    });

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _nextStory() {
    if (_currentIndex < _totalStories - 1) {
      setState(() {
        _currentIndex++;
      });
      _animController.forward(from: 0.0);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _prevStory() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      _animController.forward(from: 0.0);
    } else {
      _animController.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.6),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  // Story Pages Content
                  Positioned.fill(child: _buildStoryContent(_currentIndex)),

                  // Tap detection areas for Story Navigation
                  Positioned.fill(
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: _prevStory,
                            onLongPressStart: (_) => _animController.stop(),
                            onLongPressEnd: (_) => _animController.forward(),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: _nextStory,
                            onLongPressStart: (_) => _animController.stop(),
                            onLongPressEnd: (_) => _animController.forward(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Top Progress Bars
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Row(
                      children: List.generate(_totalStories, (index) {
                        return Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2.5),
                            height: 3.5,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: AnimatedBuilder(
                              animation: _animController,
                              builder: (context, _) {
                                double progress = 0.0;
                                if (index < _currentIndex) {
                                  progress = 1.0;
                                } else if (index == _currentIndex) {
                                  progress = _animController.value;
                                }
                                return FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: progress,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  // Close Button
                  Positioned(
                    top: 28,
                    right: 16,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStoryContent(int index) {
    switch (index) {
      case 0:
        return _buildStory1();
      case 1:
        return _buildStory2();
      case 2:
        return _buildStory3();
      case 3:
        return _buildStory4();
      case 4:
      default:
        return _buildStory5();
    }
  }

  // Story 1: Overview
  Widget _buildStory1() {
    final totalDays = widget.dynamics.totalDays > 0
        ? widget.dynamics.totalDays
        : 1;
    final msgsPerDay = (widget.chat.totalMessages / totalDays).toStringAsFixed(
      1,
    );

    return _StoryBackground(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0F382C), Color(0xFF071F18), Color(0xFF000000)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.primary,
              size: 48,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'CHAT WRAPPED',
            style: TextStyle(
              fontSize: 14,
              letterSpacing: 2.5,
              fontWeight: FontWeight.bold,
              color: AppColors.primary.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              widget.chat.name,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 40),
          _WrappedMetricHighlight(
            number: '${widget.chat.totalMessages}',
            label: 'Mensajes intercambiados',
          ),
          const SizedBox(height: 24),
          _WrappedMetricHighlight(
            number: '$totalDays',
            label: 'Días de historia compartida',
          ),
          const SizedBox(height: 24),
          _WrappedMetricHighlight(
            number: msgsPerDay,
            label: 'Mensajes diarios en promedio',
          ),
        ],
      ),
    );
  }

  // Story 2: Records
  Widget _buildStory2() {
    final recordCount = (widget.recordDay?['count'] as int?) ?? 0;
    final recordDate = (widget.recordDay?['date_str'] as String?) ?? 'N/A';
    final silence = widget.dynamics.longestSilence;

    return _StoryBackground(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF382305), Color(0xFF1F1202), Color(0xFF000000)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.tertiary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_fire_department_rounded,
              color: AppColors.tertiary,
              size: 48,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'EL DÍA HISTÓRICO',
            style: TextStyle(
              fontSize: 14,
              letterSpacing: 2.0,
              fontWeight: FontWeight.bold,
              color: AppColors.tertiary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '$recordCount',
            style: const TextStyle(
              fontSize: 54,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const Text(
            'mensajes en un solo día',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.tertiary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              recordDate,
              style: const TextStyle(
                color: AppColors.tertiary,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(height: 48),
          if (silence != null) ...[
            const Icon(
              Icons.nightlight_round,
              color: AppColors.secondary,
              size: 32,
            ),
            const SizedBox(height: 8),
            const Text(
              'EL SILENCIO MÁS LARGO',
              style: TextStyle(
                color: AppColors.secondary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${silence.duration.inDays} días sin escribir',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Rompió el silencio: ${silence.firstSenderAfter}',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }

  // Story 3: Top Participant
  Widget _buildStory3() {
    final topPerson = widget.analysis.participants.isNotEmpty
        ? widget.analysis.participants.first
        : null;

    final pct = topPerson != null && widget.chat.totalMessages > 0
        ? (topPerson.textCount + topPerson.mediaCount) /
              widget.chat.totalMessages *
              100
        : 0;

    return _StoryBackground(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF092942), Color(0xFF031422), Color(0xFF000000)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.military_tech_rounded,
              color: AppColors.secondary,
              size: 48,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'LA VOZ NÚMERO 1 DEL CHAT',
            style: TextStyle(
              fontSize: 14,
              letterSpacing: 2.0,
              fontWeight: FontWeight.bold,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              topPerson?.name ?? 'Anónimo',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Envió el ${pct.toStringAsFixed(1)}% de toda la conversación',
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 32),
          if (topPerson != null && topPerson.topEmojis.isNotEmpty) ...[
            const Text(
              'Sus emojis preferidos:',
              style: TextStyle(color: Colors.white60, fontSize: 13),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: topPerson.topEmojis.take(4).map((e) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(e.emoji, style: const TextStyle(fontSize: 28)),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  // Story 4: Awards
  Widget _buildStory4() {
    ParticipantAnalysis? topWriter;
    ParticipantAnalysis? topQuestion;
    MapEntry<String, int>? topMentioned;

    if (widget.analysis.participants.isNotEmpty) {
      final byWords = List<ParticipantAnalysis>.from(
        widget.analysis.participants,
      )..sort((a, b) => b.wordsCount.compareTo(a.wordsCount));
      topWriter = byWords.first;

      final byQuestion = List<ParticipantAnalysis>.from(
        widget.analysis.participants,
      )..sort((a, b) => b.questionCount.compareTo(a.questionCount));
      if (byQuestion.first.questionCount > 0) topQuestion = byQuestion.first;
    }

    final mentionsMap = widget.analysis.mentionsReceived;
    if (mentionsMap.isNotEmpty) {
      final sortedMentions = mentionsMap.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      topMentioned = sortedMentions.first;
    }

    final fastest = widget.dynamics.responseTimes.isNotEmpty
        ? widget.dynamics.responseTimes.first
        : null;

    return _StoryBackground(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF2C103D), Color(0xFF160621), Color(0xFF000000)],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '🏆 CUADRO DE HONOR',
              style: TextStyle(
                fontSize: 16,
                letterSpacing: 2.0,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD68BF9),
              ),
            ),
            const SizedBox(height: 28),
            _AwardCard(
              emoji: '🏷️',
              title: 'El Más Popular',
              name: topMentioned?.key ?? 'N/A',
              detail: '${topMentioned?.value ?? 0} menciones',
            ),
            const SizedBox(height: 14),
            _AwardCard(
              emoji: '✍️',
              title: 'El Gran Escritor',
              name: topWriter?.name ?? 'N/A',
              detail: '${topWriter?.wordsCount ?? 0} palabras escritas',
            ),
            const SizedBox(height: 14),
            _AwardCard(
              emoji: '⚡',
              title: 'El Más Veloz',
              name: fastest?.name ?? 'N/A',
              detail: fastest != null
                  ? 'Responde en ${fastest.avgResponseTime.inMinutes}m'
                  : 'N/A',
            ),
            const SizedBox(height: 14),
            _AwardCard(
              emoji: '❓',
              title: 'El Más Curioso',
              name: topQuestion?.name ?? 'N/A',
              detail: '${topQuestion?.questionCount ?? 0} preguntas hechas',
            ),
          ],
        ),
      ),
    );
  }

  // Story 5: Final Recap
  Widget _buildStory5() {
    return _StoryBackground(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0F382C), Color(0xFF071F18), Color(0xFF000000)],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline_rounded,
              color: AppColors.primary,
              size: 56,
            ),
            const SizedBox(height: 20),
            const Text(
              '¡ESTO ES TODO!',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tu resumen interactivo de WhatsApp',
              style: TextStyle(color: Colors.white70, fontSize: 15),
            ),
            const SizedBox(height: 36),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    widget.chat.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white24, height: 1),
                  const SizedBox(height: 16),
                  _FinalStatRow(
                    label: 'Total mensajes',
                    val: '${widget.chat.totalMessages}',
                  ),
                  const SizedBox(height: 8),
                  _FinalStatRow(
                    label: 'Multimedia compartida',
                    val: '${widget.chat.totalMedia}',
                  ),
                  const SizedBox(height: 8),
                  _FinalStatRow(
                    label: 'Enlaces web',
                    val: '${widget.analysis.totalLinks}',
                  ),
                  const SizedBox(height: 8),
                  _FinalStatRow(
                    label: 'Participantes',
                    val: '${widget.chat.participantCount}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: const Color(0xFF003915),
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.done_all_rounded),
              label: const Text(
                'Cerrar Wrapped',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoryBackground extends StatelessWidget {
  final Gradient gradient;
  final Widget child;

  const _StoryBackground({required this.gradient, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: gradient),
      padding: const EdgeInsets.all(24),
      child: Center(child: child),
    );
  }
}

class _WrappedMetricHighlight extends StatelessWidget {
  final String number;
  final String label;

  const _WrappedMetricHighlight({required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          number,
          style: const TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            color: Colors.white.withValues(alpha: 0.75),
          ),
        ),
      ],
    );
  }
}

class _AwardCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String name;
  final String detail;

  const _AwardCard({
    required this.emoji,
    required this.title,
    required this.name,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 26)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFFD68BF9),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            detail,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.65),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _FinalStatRow extends StatelessWidget {
  final String label;
  final String val;

  const _FinalStatRow({required this.label, required this.val});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        Text(
          val,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
