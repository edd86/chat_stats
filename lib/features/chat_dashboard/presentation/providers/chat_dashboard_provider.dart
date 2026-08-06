import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/local/database_helper.dart';
import '../../../chat_import/domain/models/chat_model.dart';
import '../../../chat_import/domain/models/chat_message_model.dart';
import '../../../chat_import/domain/models/participant_model.dart';
import '../../domain/models/conversation_dynamics.dart';

final chatDetailProvider = FutureProvider.family.autoDispose<ChatModel?, int>((
  ref,
  chatId,
) async {
  return await DatabaseHelper.instance.getChatById(chatId);
});

final chatParticipantsProvider = FutureProvider.family
    .autoDispose<List<ParticipantModel>, int>((ref, chatId) async {
      return await DatabaseHelper.instance.getParticipantsByChatId(chatId);
    });

final chatDailyActivityProvider = FutureProvider.family
    .autoDispose<List<Map<String, dynamic>>, int>((ref, chatId) async {
      return await DatabaseHelper.instance.getDailyActivity(chatId);
    });

final chatHourlyDistributionProvider = FutureProvider.family
    .autoDispose<List<Map<String, dynamic>>, int>((ref, chatId) async {
      return await DatabaseHelper.instance.getHourlyDistribution(chatId);
    });

final chatHeatmapProvider = FutureProvider.family
    .autoDispose<List<Map<String, dynamic>>, int>((ref, chatId) async {
      return await DatabaseHelper.instance.getActivityHeatmap(chatId);
    });

final chatSearchProvider = FutureProvider.family
    .autoDispose<List<ChatMessageModel>, ({int chatId, String query})>((
      ref,
      arg,
    ) async {
      if (arg.query.trim().isEmpty) return [];
      return await DatabaseHelper.instance.searchMessages(
        arg.chatId,
        arg.query.trim(),
      );
    });

final chatDynamicsProvider = FutureProvider.family
    .autoDispose<ConversationDynamics, int>((ref, chatId) async {
      final stream = await DatabaseHelper.instance.getConversationStream(chatId);
      return ConversationDynamics.process(stream);
    });

enum ActivityChartTimeframe { all, last30Days }

class ActivityChartFilterNotifier extends Notifier<ActivityChartTimeframe> {
  @override
  ActivityChartTimeframe build() => ActivityChartTimeframe.all;

  void setTimeframe(ActivityChartTimeframe timeframe) {
    state = timeframe;
  }
}

final activityChartFilterProvider =
    NotifierProvider<ActivityChartFilterNotifier, ActivityChartTimeframe>(
      ActivityChartFilterNotifier.new,
    );
