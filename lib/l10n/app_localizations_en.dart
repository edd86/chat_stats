// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'WhatsApp Statistics';

  @override
  String get chatsImported => 'IMPORTED CHATS';

  @override
  String get noChatsYet =>
      'You haven\'t saved any chat rooms yet.\nImport a .zip or .txt file above to get started.';

  @override
  String get importChatSuccess => 'Chat imported successfully!';

  @override
  String chatLoadError(String error) {
    return 'Error loading chats: $error';
  }

  @override
  String get uploadTitle => 'Tap here to import a chat';

  @override
  String get uploadSubtitle => 'Upload an exported .zip or .txt WhatsApp file';

  @override
  String get processingMessages => 'Processing messages...';

  @override
  String get howToExport => 'How to export from WhatsApp?';

  @override
  String get howToExportButton => 'How to export a chat?';

  @override
  String get exportStep1 =>
      '1. Open the WhatsApp chat or group you wish to analyze.';

  @override
  String get exportStep2Android =>
      '2. Tap the three dots (⋮) in the top right corner.';

  @override
  String get exportStep2Ios => '2. Tap the contact or group name at the top.';

  @override
  String get exportStep3Android => '3. Select \"More\" ➔ \"Export chat\".';

  @override
  String get exportStep3Ios => '3. Scroll down and select \"Export chat\".';

  @override
  String get exportStep4 =>
      '4. IMPORTANT! Choose the \"Without Media\" option.';

  @override
  String get exportStep5Android =>
      '5. Share directly with \"Chat Stats\" or save the .zip/.txt file and select it here.';

  @override
  String get exportStep5Ios =>
      '5. Share directly to this app or save to \"Files\" and select it from here.';

  @override
  String importedOn(String date) {
    return 'Imported on $date';
  }

  @override
  String get deleteChat => 'Delete from SQLite';

  @override
  String get deleteConfirmTitle => 'Delete chat?';

  @override
  String get deleteConfirmMessage =>
      'Are you sure you want to delete this chat from the database?';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String messagesCount(int count) {
    return '$count msgs';
  }

  @override
  String usersCount(int count) {
    return '$count users';
  }

  @override
  String mediaCount(int count) {
    return '$count media';
  }

  @override
  String get securityAndPrivacy => 'Security and Privacy';

  @override
  String get privacyExplanation =>
      'Your chats are processed 100% on your device and are never sent to any external server.';

  @override
  String get biometricLockTitle => 'Biometric / PIN Lock';

  @override
  String get biometricLockSubtitle =>
      'Require authentication when opening the app';

  @override
  String get securityLockActivated => 'Security Lock Activated';

  @override
  String get securityLockPrompt =>
      'Confirm your identity to access your chats and statistics.';

  @override
  String get unlock => 'Unlock';

  @override
  String get authReason =>
      'Confirm your identity to access your chats and statistics.';

  @override
  String get language => 'Language';

  @override
  String get languageSubtitle => 'Select application language';

  @override
  String get systemDefaultLanguage => 'System default';

  @override
  String get spanishLanguage => 'Español (Latinoamérica)';

  @override
  String get englishLanguage => 'English';

  @override
  String get portugueseLanguage => 'Português';

  @override
  String get chatDetails => 'Chat Details';

  @override
  String localData(String fileName) {
    return 'Local data: $fileName';
  }

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get chatNotFound => 'Chat not found locally.';

  @override
  String get versusDuel => 'Head-to-Head Duel ⚔️';

  @override
  String get searchInChat => 'Local Search';

  @override
  String get wrapped => 'Wrapped';

  @override
  String get filterAllTime => 'All time';

  @override
  String get filterLast30Days => 'Last 30 days';

  @override
  String get filterThisYear => 'This year';

  @override
  String get filterCustom => 'Custom';

  @override
  String get kpiMessages => 'Messages';

  @override
  String get kpiInPeriod => 'In period';

  @override
  String get kpiTotalExchanged => 'Total exchanged';

  @override
  String get kpiMedia => 'Files';

  @override
  String get kpiAudiosPhotos => 'Audios, photos, stickers';

  @override
  String get kpiWords => 'Words';

  @override
  String get kpiWrittenContent => 'Written content';

  @override
  String get kpiParticipants => 'Participants';

  @override
  String get kpiActiveMembers => 'Active members';

  @override
  String get kpiDailyAverage => 'Daily Average';

  @override
  String get kpiDailyPace => 'Activity pace';

  @override
  String get kpiMsgsPerDay => 'msgs/day';

  @override
  String get kpiChatDuration => 'Chat Duration';

  @override
  String get kpiHistorySpan => 'History recorded';

  @override
  String get kpiEmojis => 'Emojis Used';

  @override
  String get kpiExpressions => 'Expressions and faces';

  @override
  String get kpiTotalLinks => 'Links Sent';

  @override
  String get kpiWebReferences => 'Web references';

  @override
  String get activityOverTime => 'ACTIVITY OVER TIME';

  @override
  String get activityHeatmap => 'ACTIVITY MAP (DAY × HOUR)';

  @override
  String get lessActivity => 'Less';

  @override
  String get moreActivity => 'More';

  @override
  String get hourlyDistribution => 'HOURLY DISTRIBUTION';

  @override
  String peakHourLabel(String hour, String count) {
    return 'Peak: $hour:00h ($count msgs)';
  }

  @override
  String get timeSlotDawn => 'Night/Dawn';

  @override
  String get timeSlotMorning => 'Morning';

  @override
  String get timeSlotAfternoon => 'Afternoon';

  @override
  String get timeSlotNight => 'Evening';

  @override
  String slotShareBadge(String pct) {
    return '$pct% of messages';
  }

  @override
  String get viewByPeriods => 'By Periods';

  @override
  String get viewBy24Hours => '24 Hours';

  @override
  String get conversationDynamics => 'CONVERSATION DYNAMICS';

  @override
  String get longestSilenceTitle => 'LONGEST SILENCE';

  @override
  String get uninterruptedChat => 'Uninterrupted conversation';

  @override
  String silenceBrokeBy(String name) {
    return 'Broke silence: $name';
  }

  @override
  String get mostActiveDayTitle => 'MOST ACTIVE DAY IN HISTORY';

  @override
  String pctOfTotal(String pct) {
    return '$pct% of total';
  }

  @override
  String daysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String hoursCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours',
      one: '1 hour',
    );
    return '$_temp0';
  }

  @override
  String minutesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes',
      one: '1 minute',
    );
    return '$_temp0';
  }

  @override
  String secondsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seconds',
      one: '1 second',
    );
    return '$_temp0';
  }

  @override
  String get searchHint => 'Search words (e.g. Disney, promo)...';

  @override
  String get searchPrompt => 'Type a word to perform optimized search.';

  @override
  String noMatchesFound(String query) {
    return 'No matches found for \"$query\"';
  }

  @override
  String get versusNeedMinParticipants =>
      'At least 2 participants are required in the chat for a head-to-head comparison.';

  @override
  String get versusSelectParticipant => 'Select participant';

  @override
  String versusWinner(String name) {
    return 'Overall winner: $name';
  }

  @override
  String get versusTie => 'It\'s a tie!';
}
