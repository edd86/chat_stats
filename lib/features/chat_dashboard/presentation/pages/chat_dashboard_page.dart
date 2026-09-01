import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/chat_dashboard_provider.dart';
import '../widgets/activity_chart.dart';
import '../widgets/hourly_chart.dart';
import '../widgets/kpi_card.dart';
import '../widgets/participants_chart.dart';
import '../widgets/activity_heatmap.dart';
import '../widgets/conversation_dynamics.dart';
import '../widgets/message_analysis_section.dart';

class ChatDashboardPage extends ConsumerWidget {
  final int chatId;

  const ChatDashboardPage({super.key, required this.chatId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatAsync = ref.watch(chatDetailProvider(chatId));
    final participantsAsync = ref.watch(chatParticipantsProvider(chatId));
    final dailyAsync = ref.watch(chatDailyActivityProvider(chatId));
    final hourlyAsync = ref.watch(chatHourlyDistributionProvider(chatId));
    final heatmapAsync = ref.watch(chatHeatmapProvider(chatId));
    final dynamicsAsync = ref.watch(chatDynamicsProvider(chatId));
    final analysisAsync = ref.watch(chatAnalysisProvider(chatId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: chatAsync.when(
          data: (chat) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                chat?.name ?? 'Detalles del Chat',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'Datos locales: ${chat?.fileName ?? ''}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          loading: () => const Text('Cargando...'),
          error: (_, _) => const Text('Error'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.primary),
            onPressed: () {
              context.push('/search/$chatId');
            },
            tooltip: 'Buscar en Local',
          ),
        ],
      ),
      body: chatAsync.when(
        data: (chat) {
          if (chat == null) {
            return const Center(child: Text('Chat no encontrado localmente.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // KPI Grid
                LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
                    return GridView.count(
                      crossAxisCount: crossAxisCount,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.35,
                      children: [
                        KpiCard(
                          title: 'Mensajes',
                          value: '${chat.totalMessages}',
                          icon: Icons.message_outlined,
                          color: AppColors.primary,
                        ),
                        KpiCard(
                          title: 'Usuarios',
                          value: '${chat.participantCount}',
                          icon: Icons.people_outline,
                          color: AppColors.secondary,
                        ),
                        KpiCard(
                          title: 'Multimedia',
                          value: '${chat.totalMedia}',
                          icon: Icons.perm_media_outlined,
                          color: AppColors.tertiary,
                        ),
                        KpiCard(
                          title: 'Palabras',
                          value: '${chat.totalWords}',
                          icon: Icons.article_outlined,
                          color: AppColors.primary,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Activity Chart
                dailyAsync.when(
                  data: (dailyData) => ActivityChart(dailyData: dailyData),
                  loading: () => const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (err, _) => Text('Error al cargar gráfica: $err'),
                ),
                const SizedBox(height: 24),

                // Participants Bar Chart
                participantsAsync.when(
                  data: (participants) =>
                      ParticipantsChart(participants: participants),
                  loading: () => const SizedBox(),
                  error: (_, _) => const SizedBox(),
                ),
                const SizedBox(height: 24),

                // Hourly Distribution Chart
                hourlyAsync.when(
                  data: (hourlyData) => HourlyChart(hourlyData: hourlyData),
                  loading: () => const SizedBox(),
                  error: (_, _) => const SizedBox(),
                ),

                // Activity Heatmap
                const SizedBox(height: 28),
                heatmapAsync.when(
                  data: (heatmapData) =>
                      ActivityHeatmap(heatmapData: heatmapData),
                  loading: () => const SizedBox(),
                  error: (_, _) => const SizedBox(),
                ),

                // Conversation Dynamics
                const SizedBox(height: 28),
                dynamicsAsync.when(
                  data: (dynamics) =>
                      ConversationDynamicsSection(dynamics: dynamics),
                  loading: () => const SizedBox(),
                  error: (_, _) => const SizedBox(),
                ),

                // Detailed Participant Breakdown List (Top 10)
                const SizedBox(height: 28),
                Text(
                  'DESGLOSE POR PARTICIPANTE (TOP 10)',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 16),
                participantsAsync.when(
                  data: (participants) {
                    final displayParticipants = participants.take(10).toList();
                    final remainingCount =
                        participants.length - displayParticipants.length;

                    return Column(
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: displayParticipants.length,
                          itemBuilder: (context, index) {
                            final p = displayParticipants[index];
                            final percentage = chat.totalMessages > 0
                                ? (p.messageCount / chat.totalMessages * 100)
                                      .toStringAsFixed(1)
                                : '0';

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainer,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.outlineVariant,
                                  width: 0.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: index == 0
                                        ? AppColors.primary.withValues(
                                            alpha: 0.2,
                                          )
                                        : AppColors.surfaceContainerHigh,
                                    child: Text(
                                      p.name.isNotEmpty
                                          ? p.name[0].toUpperCase()
                                          : '?',
                                      style: TextStyle(
                                        color: index == 0
                                            ? AppColors.primary
                                            : AppColors.onSurface,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          p.name,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        LinearProgressIndicator(
                                          value: chat.totalMessages > 0
                                              ? p.messageCount /
                                                    chat.totalMessages
                                              : 0,
                                          backgroundColor:
                                              AppColors.surfaceContainerLow,
                                          color: index == 0
                                              ? AppColors.primary
                                              : AppColors.secondary,
                                          minHeight: 4,
                                          borderRadius: BorderRadius.circular(
                                            2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${p.messageCount} msgs',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      Text(
                                        '$percentage%',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                              color: AppColors.onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        if (remainingCount > 0) ...[
                          const SizedBox(height: 8),
                          Text(
                            '+ $remainingCount participantes más en el chat',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  fontStyle: FontStyle.italic,
                                ),
                          ),
                        ],
                      ],
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, _) =>
                      Text('Error al cargar participantes: $err'),
                ),

                // Message Content Analysis
                const SizedBox(height: 28),
                analysisAsync.when(
                  data: (analysis) =>
                      MessageAnalysisSection(analysis: analysis),
                  loading: () => const SizedBox(),
                  error: (_, _) => const SizedBox(),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
