import 'package:chat_stats/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/models/chat_model.dart';

class ChatCard extends StatelessWidget {
  final ChatModel chat;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ChatCard({
    super.key,
    required this.chat,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeTag = Localizations.localeOf(context).languageCode;
    final dateFormatted = AppDateFormatter.formatDateTime(
      DateTime.fromMillisecondsSinceEpoch(chat.createdAt),
      locale: localeTag,
    );

    return Card(
      color: AppColors.surfaceContainer,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.chat_bubble_outline,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chat.name,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n?.importedOn(dateFormatted) ??
                              'Importado el $dateFormatted',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: AppColors.error,
                    ),
                    onPressed: onDelete,
                    tooltip: l10n?.deleteChat ?? 'Eliminar de SQLite',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                alignment: WrapAlignment.spaceBetween,
                children: [
                  _MetricBadge(
                    icon: Icons.message_outlined,
                    label: l10n?.messagesCount(chat.totalMessages) ??
                        '${chat.totalMessages} msgs',
                    color: AppColors.primary,
                  ),
                  _MetricBadge(
                    icon: Icons.people_outline,
                    label: l10n?.usersCount(chat.participantCount) ??
                        '${chat.participantCount} usuarios',
                    color: AppColors.secondary,
                  ),
                  _MetricBadge(
                    icon: Icons.perm_media_outlined,
                    label: l10n?.mediaCount(chat.totalMedia) ??
                        '${chat.totalMedia} multimedia',
                    color: AppColors.tertiary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MetricBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: AppColors.onSurface),
        ),
      ],
    );
  }
}
