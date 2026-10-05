import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/local/database_helper.dart';
import '../../../chat_import/domain/models/chat_model.dart';
import '../../../chat_import/domain/models/chat_message_model.dart';
import '../../../chat_import/domain/models/participant_model.dart';
import '../../domain/models/conversation_dynamics.dart';
import '../../domain/models/message_analysis.dart';

enum DashboardDateFilterType { all, last30Days, last90Days, thisYear, custom }

class DashboardDateFilter {
  final DashboardDateFilterType type;
  final DateTime? customStart;
  final DateTime? customEnd;

  const DashboardDateFilter({
    this.type = DashboardDateFilterType.all,
    this.customStart,
    this.customEnd,
  });

  ({int? startTs, int? endTs}) toTimestamps() {
    final now = DateTime.now();
    switch (type) {
      case DashboardDateFilterType.all:
        return (startTs: null, endTs: null);
      case DashboardDateFilterType.last30Days:
        final start = now.subtract(const Duration(days: 30));
        return (
          startTs: DateTime(start.year, start.month, start.day).millisecondsSinceEpoch,
          endTs: now.millisecondsSinceEpoch,
        );
      case DashboardDateFilterType.last90Days:
        final start = now.subtract(const Duration(days: 90));
        return (
          startTs: DateTime(start.year, start.month, start.day).millisecondsSinceEpoch,
          endTs: now.millisecondsSinceEpoch,
        );
      case DashboardDateFilterType.thisYear:
        final start = DateTime(now.year, 1, 1);
        return (
          startTs: start.millisecondsSinceEpoch,
          endTs: now.millisecondsSinceEpoch,
        );
      case DashboardDateFilterType.custom:
        if (customStart == null || customEnd == null) {
          return (startTs: null, endTs: null);
        }
        return (
          startTs: customStart!.millisecondsSinceEpoch,
          endTs: DateTime(
            customEnd!.year,
            customEnd!.month,
            customEnd!.day,
            23,
            59,
            59,
          ).millisecondsSinceEpoch,
        );
    }
  }

  String get label {
    switch (type) {
      case DashboardDateFilterType.all:
        return 'Todo';
      case DashboardDateFilterType.last30Days:
        return 'Últimos 30d';
      case DashboardDateFilterType.last90Days:
        return 'Últimos 90d';
      case DashboardDateFilterType.thisYear:
        return 'Este año';
      case DashboardDateFilterType.custom:
        return 'Personalizado';
    }
  }
}

class DashboardDateFilterNotifier extends Notifier<DashboardDateFilter> {
  @override
  DashboardDateFilter build() => const DashboardDateFilter();

  void setFilter(
    DashboardDateFilterType type, {
    DateTime? customStart,
    DateTime? customEnd,
  }) {
    state = DashboardDateFilter(
      type: type,
      customStart: customStart,
      customEnd: customEnd,
    );
  }
}

final dashboardDateFilterProvider =
    NotifierProvider<DashboardDateFilterNotifier, DashboardDateFilter>(
      DashboardDateFilterNotifier.new,
    );

final chatDetailProvider = FutureProvider.family.autoDispose<ChatModel?, int>((
  ref,
  chatId,
) async {
  return await DatabaseHelper.instance.getChatById(chatId);
});

final chatFilteredSummaryProvider =
    FutureProvider.family.autoDispose<Map<String, dynamic>, int>((
      ref,
      chatId,
    ) async {
      final filter = ref.watch(dashboardDateFilterProvider);
      final range = filter.toTimestamps();
      return await DatabaseHelper.instance.getChatStatsSummary(
        chatId,
        startTimestamp: range.startTs,
        endTimestamp: range.endTs,
      );
    });

final chatParticipantsProvider = FutureProvider.family
    .autoDispose<List<ParticipantModel>, int>((ref, chatId) async {
      final filter = ref.watch(dashboardDateFilterProvider);
      final range = filter.toTimestamps();
      return await DatabaseHelper.instance.getParticipantsByChatId(
        chatId,
        startTimestamp: range.startTs,
        endTimestamp: range.endTs,
      );
    });

final chatDailyActivityProvider = FutureProvider.family
    .autoDispose<List<Map<String, dynamic>>, int>((ref, chatId) async {
      final filter = ref.watch(dashboardDateFilterProvider);
      final range = filter.toTimestamps();
      return await DatabaseHelper.instance.getDailyActivity(
        chatId,
        startTimestamp: range.startTs,
        endTimestamp: range.endTs,
      );
    });

final chatHourlyDistributionProvider = FutureProvider.family
    .autoDispose<List<Map<String, dynamic>>, int>((ref, chatId) async {
      final filter = ref.watch(dashboardDateFilterProvider);
      final range = filter.toTimestamps();
      return await DatabaseHelper.instance.getHourlyDistribution(
        chatId,
        startTimestamp: range.startTs,
        endTimestamp: range.endTs,
      );
    });

final chatHeatmapProvider = FutureProvider.family
    .autoDispose<List<Map<String, dynamic>>, int>((ref, chatId) async {
      final filter = ref.watch(dashboardDateFilterProvider);
      final range = filter.toTimestamps();
      return await DatabaseHelper.instance.getActivityHeatmap(
        chatId,
        startTimestamp: range.startTs,
        endTimestamp: range.endTs,
      );
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

ConversationDynamics _processDynamicsInBackground(
  List<Map<String, dynamic>> stream,
) {
  return ConversationDynamics.process(stream);
}

final chatDynamicsProvider = FutureProvider.family
    .autoDispose<ConversationDynamics, int>((ref, chatId) async {
      final filter = ref.watch(dashboardDateFilterProvider);
      final range = filter.toTimestamps();
      final stream = await DatabaseHelper.instance.getConversationStream(
        chatId,
        startTimestamp: range.startTs,
        endTimestamp: range.endTs,
      );
      return compute(_processDynamicsInBackground, stream);
    });

MessageAnalysis _processAnalysisInBackground(Map<String, dynamic> data) {
  final messages = data['messages'] as List<Map<String, dynamic>>;
  final edited = data['edited'] as List<Map<String, dynamic>>;
  final content = data['content'] as List<Map<String, dynamic>>;
  return MessageAnalysis.process(messages, edited, content);
}

final chatAnalysisProvider = FutureProvider.family
    .autoDispose<MessageAnalysis, int>((ref, chatId) async {
      final filter = ref.watch(dashboardDateFilterProvider);
      final range = filter.toTimestamps();
      final messages = await DatabaseHelper.instance.getMessagesForAnalysis(
        chatId,
        startTimestamp: range.startTs,
        endTimestamp: range.endTs,
      );
      final edited = await DatabaseHelper.instance.getEditedStats(
        chatId,
        startTimestamp: range.startTs,
        endTimestamp: range.endTs,
      );
      final content = await DatabaseHelper.instance.getContentStats(
        chatId,
        startTimestamp: range.startTs,
        endTimestamp: range.endTs,
      );
      return compute(_processAnalysisInBackground, {
        'messages': messages,
        'edited': edited,
        'content': content,
      });
    });

final chatRecordDayProvider = FutureProvider.family
    .autoDispose<Map<String, dynamic>?, int>((ref, chatId) async {
      final filter = ref.watch(dashboardDateFilterProvider);
      final range = filter.toTimestamps();
      return await DatabaseHelper.instance.getActiveDayRecord(
        chatId,
        startTimestamp: range.startTs,
        endTimestamp: range.endTs,
      );
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
