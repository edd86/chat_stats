import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('pt'),
  ];

  /// Título principal de la aplicación
  ///
  /// In es, this message translates to:
  /// **'Estadísticas de WhatsApp'**
  String get appTitle;

  /// No description provided for @chatsImported.
  ///
  /// In es, this message translates to:
  /// **'CHATS IMPORTADOS'**
  String get chatsImported;

  /// No description provided for @noChatsYet.
  ///
  /// In es, this message translates to:
  /// **'Aún no has guardado ninguna sala de chat.\nImporta un archivo .zip o .txt arriba para comenzar.'**
  String get noChatsYet;

  /// No description provided for @importChatSuccess.
  ///
  /// In es, this message translates to:
  /// **'¡Chat importado con éxito!'**
  String get importChatSuccess;

  /// No description provided for @chatLoadError.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar chats: {error}'**
  String chatLoadError(String error);

  /// No description provided for @uploadTitle.
  ///
  /// In es, this message translates to:
  /// **'Toca aquí para importar un chat'**
  String get uploadTitle;

  /// No description provided for @uploadSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Sube un archivo .zip o .txt exportado de WhatsApp'**
  String get uploadSubtitle;

  /// No description provided for @processingMessages.
  ///
  /// In es, this message translates to:
  /// **'Procesando mensajes...'**
  String get processingMessages;

  /// No description provided for @howToExport.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo exportar desde WhatsApp?'**
  String get howToExport;

  /// No description provided for @howToExportButton.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo exportar un chat?'**
  String get howToExportButton;

  /// No description provided for @exportStep1.
  ///
  /// In es, this message translates to:
  /// **'1. Abre el chat o grupo en WhatsApp que deseas analizar.'**
  String get exportStep1;

  /// No description provided for @exportStep2Android.
  ///
  /// In es, this message translates to:
  /// **'2. Toca los tres puntos (⋮) en la esquina superior derecha.'**
  String get exportStep2Android;

  /// No description provided for @exportStep2Ios.
  ///
  /// In es, this message translates to:
  /// **'2. Toca el nombre del contacto o grupo en la parte superior.'**
  String get exportStep2Ios;

  /// No description provided for @exportStep3Android.
  ///
  /// In es, this message translates to:
  /// **'3. Selecciona \"Más\" ➔ \"Exportar chat\".'**
  String get exportStep3Android;

  /// No description provided for @exportStep3Ios.
  ///
  /// In es, this message translates to:
  /// **'3. Desplázate hacia abajo y selecciona \"Exportar chat\".'**
  String get exportStep3Ios;

  /// No description provided for @exportStep4.
  ///
  /// In es, this message translates to:
  /// **'4. ¡IMPORTANTE! Elige la opción \"Sin archivos multimedia\".'**
  String get exportStep4;

  /// No description provided for @exportStep5Android.
  ///
  /// In es, this message translates to:
  /// **'5. Comparte directo con \"Chat Stats\" o guarda el archivo .zip/.txt y selecciónalo aquí.'**
  String get exportStep5Android;

  /// No description provided for @exportStep5Ios.
  ///
  /// In es, this message translates to:
  /// **'5. Comparte directo a esta app o guarda en \"Archivos\" y selecciónalo desde aquí.'**
  String get exportStep5Ios;

  /// No description provided for @importedOn.
  ///
  /// In es, this message translates to:
  /// **'Importado el {date}'**
  String importedOn(String date);

  /// No description provided for @deleteChat.
  ///
  /// In es, this message translates to:
  /// **'Eliminar de SQLite'**
  String get deleteChat;

  /// No description provided for @deleteConfirmTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar chat?'**
  String get deleteConfirmTitle;

  /// No description provided for @deleteConfirmMessage.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que deseas eliminar este chat de la base de datos?'**
  String get deleteConfirmMessage;

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get delete;

  /// No description provided for @messagesCount.
  ///
  /// In es, this message translates to:
  /// **'{count} msgs'**
  String messagesCount(int count);

  /// No description provided for @usersCount.
  ///
  /// In es, this message translates to:
  /// **'{count} usuarios'**
  String usersCount(int count);

  /// No description provided for @mediaCount.
  ///
  /// In es, this message translates to:
  /// **'{count} multimedia'**
  String mediaCount(int count);

  /// No description provided for @securityAndPrivacy.
  ///
  /// In es, this message translates to:
  /// **'Seguridad y Privacidad'**
  String get securityAndPrivacy;

  /// No description provided for @privacyExplanation.
  ///
  /// In es, this message translates to:
  /// **'Tus chats se procesan 100% en tu dispositivo y nunca se envían a ningún servidor externo.'**
  String get privacyExplanation;

  /// No description provided for @biometricLockTitle.
  ///
  /// In es, this message translates to:
  /// **'Bloqueo con Huella / PIN'**
  String get biometricLockTitle;

  /// No description provided for @biometricLockSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Solicitar autenticación al abrir la app'**
  String get biometricLockSubtitle;

  /// No description provided for @securityLockActivated.
  ///
  /// In es, this message translates to:
  /// **'Bloqueo de Seguridad Activado'**
  String get securityLockActivated;

  /// No description provided for @securityLockPrompt.
  ///
  /// In es, this message translates to:
  /// **'Confirma tu identidad para acceder a tus chats y estadísticas.'**
  String get securityLockPrompt;

  /// No description provided for @unlock.
  ///
  /// In es, this message translates to:
  /// **'Desbloquear'**
  String get unlock;

  /// No description provided for @authReason.
  ///
  /// In es, this message translates to:
  /// **'Confirma tu identidad para acceder a tus chats y estadísticas.'**
  String get authReason;

  /// No description provided for @language.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get language;

  /// No description provided for @languageSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Selecciona el idioma de la aplicación'**
  String get languageSubtitle;

  /// No description provided for @systemDefaultLanguage.
  ///
  /// In es, this message translates to:
  /// **'Predeterminado del sistema'**
  String get systemDefaultLanguage;

  /// No description provided for @spanishLanguage.
  ///
  /// In es, this message translates to:
  /// **'Español (Latinoamérica)'**
  String get spanishLanguage;

  /// No description provided for @englishLanguage.
  ///
  /// In es, this message translates to:
  /// **'English'**
  String get englishLanguage;

  /// No description provided for @portugueseLanguage.
  ///
  /// In es, this message translates to:
  /// **'Português'**
  String get portugueseLanguage;

  /// No description provided for @chatDetails.
  ///
  /// In es, this message translates to:
  /// **'Detalles del Chat'**
  String get chatDetails;

  /// No description provided for @localData.
  ///
  /// In es, this message translates to:
  /// **'Datos locales: {fileName}'**
  String localData(String fileName);

  /// No description provided for @loading.
  ///
  /// In es, this message translates to:
  /// **'Cargando...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In es, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @chatNotFound.
  ///
  /// In es, this message translates to:
  /// **'Chat no encontrado localmente.'**
  String get chatNotFound;

  /// No description provided for @versusDuel.
  ///
  /// In es, this message translates to:
  /// **'Duelo: Cara a Cara ⚔️'**
  String get versusDuel;

  /// No description provided for @searchInChat.
  ///
  /// In es, this message translates to:
  /// **'Buscar en Local'**
  String get searchInChat;

  /// No description provided for @wrapped.
  ///
  /// In es, this message translates to:
  /// **'Wrapped'**
  String get wrapped;

  /// No description provided for @filterAllTime.
  ///
  /// In es, this message translates to:
  /// **'Todo el tiempo'**
  String get filterAllTime;

  /// No description provided for @filterLast30Days.
  ///
  /// In es, this message translates to:
  /// **'Últimos 30 días'**
  String get filterLast30Days;

  /// No description provided for @filterThisYear.
  ///
  /// In es, this message translates to:
  /// **'Este año'**
  String get filterThisYear;

  /// No description provided for @filterCustom.
  ///
  /// In es, this message translates to:
  /// **'Personalizado'**
  String get filterCustom;

  /// No description provided for @kpiMessages.
  ///
  /// In es, this message translates to:
  /// **'Mensajes'**
  String get kpiMessages;

  /// No description provided for @kpiInPeriod.
  ///
  /// In es, this message translates to:
  /// **'En período'**
  String get kpiInPeriod;

  /// No description provided for @kpiTotalExchanged.
  ///
  /// In es, this message translates to:
  /// **'Total intercambiados'**
  String get kpiTotalExchanged;

  /// No description provided for @kpiMedia.
  ///
  /// In es, this message translates to:
  /// **'Archivos'**
  String get kpiMedia;

  /// No description provided for @kpiAudiosPhotos.
  ///
  /// In es, this message translates to:
  /// **'Audios, fotos, stickers'**
  String get kpiAudiosPhotos;

  /// No description provided for @kpiWords.
  ///
  /// In es, this message translates to:
  /// **'Palabras'**
  String get kpiWords;

  /// No description provided for @kpiWrittenContent.
  ///
  /// In es, this message translates to:
  /// **'Contenido escrito'**
  String get kpiWrittenContent;

  /// No description provided for @kpiParticipants.
  ///
  /// In es, this message translates to:
  /// **'Participantes'**
  String get kpiParticipants;

  /// No description provided for @kpiActiveMembers.
  ///
  /// In es, this message translates to:
  /// **'Miembros activos'**
  String get kpiActiveMembers;

  /// No description provided for @kpiDailyAverage.
  ///
  /// In es, this message translates to:
  /// **'Promedio Diario'**
  String get kpiDailyAverage;

  /// No description provided for @kpiDailyPace.
  ///
  /// In es, this message translates to:
  /// **'Ritmo de actividad'**
  String get kpiDailyPace;

  /// No description provided for @kpiMsgsPerDay.
  ///
  /// In es, this message translates to:
  /// **'msgs/día'**
  String get kpiMsgsPerDay;

  /// No description provided for @kpiChatDuration.
  ///
  /// In es, this message translates to:
  /// **'Duración del Chat'**
  String get kpiChatDuration;

  /// No description provided for @kpiHistorySpan.
  ///
  /// In es, this message translates to:
  /// **'Historial registrado'**
  String get kpiHistorySpan;

  /// No description provided for @kpiEmojis.
  ///
  /// In es, this message translates to:
  /// **'Emojis Usados'**
  String get kpiEmojis;

  /// No description provided for @kpiExpressions.
  ///
  /// In es, this message translates to:
  /// **'Expresiones y caras'**
  String get kpiExpressions;

  /// No description provided for @kpiTotalLinks.
  ///
  /// In es, this message translates to:
  /// **'Links Enviados'**
  String get kpiTotalLinks;

  /// No description provided for @kpiWebReferences.
  ///
  /// In es, this message translates to:
  /// **'Referencias web'**
  String get kpiWebReferences;

  /// No description provided for @activityOverTime.
  ///
  /// In es, this message translates to:
  /// **'ACTIVIDAD A LO LARGO DEL TIEMPO'**
  String get activityOverTime;

  /// No description provided for @activityHeatmap.
  ///
  /// In es, this message translates to:
  /// **'MAPA DE ACTIVIDAD (DÍA × HORA)'**
  String get activityHeatmap;

  /// No description provided for @lessActivity.
  ///
  /// In es, this message translates to:
  /// **'Menos'**
  String get lessActivity;

  /// No description provided for @moreActivity.
  ///
  /// In es, this message translates to:
  /// **'Más'**
  String get moreActivity;

  /// No description provided for @hourlyDistribution.
  ///
  /// In es, this message translates to:
  /// **'DISTRIBUCIÓN HORARIA'**
  String get hourlyDistribution;

  /// No description provided for @peakHourLabel.
  ///
  /// In es, this message translates to:
  /// **'Pico: {hour}:00h ({count} msgs)'**
  String peakHourLabel(String hour, String count);

  /// No description provided for @timeSlotDawn.
  ///
  /// In es, this message translates to:
  /// **'Madrugada'**
  String get timeSlotDawn;

  /// No description provided for @timeSlotMorning.
  ///
  /// In es, this message translates to:
  /// **'Mañana'**
  String get timeSlotMorning;

  /// No description provided for @timeSlotAfternoon.
  ///
  /// In es, this message translates to:
  /// **'Tarde'**
  String get timeSlotAfternoon;

  /// No description provided for @timeSlotNight.
  ///
  /// In es, this message translates to:
  /// **'Noche'**
  String get timeSlotNight;

  /// No description provided for @slotShareBadge.
  ///
  /// In es, this message translates to:
  /// **'{pct}% de los mensajes'**
  String slotShareBadge(String pct);

  /// No description provided for @viewByPeriods.
  ///
  /// In es, this message translates to:
  /// **'Por Períodos'**
  String get viewByPeriods;

  /// No description provided for @viewBy24Hours.
  ///
  /// In es, this message translates to:
  /// **'24 Horas'**
  String get viewBy24Hours;

  /// No description provided for @conversationDynamics.
  ///
  /// In es, this message translates to:
  /// **'DINÁMICA DE LA CONVERSACIÓN'**
  String get conversationDynamics;

  /// No description provided for @longestSilenceTitle.
  ///
  /// In es, this message translates to:
  /// **'EL SILENCIO MÁS LARGO'**
  String get longestSilenceTitle;

  /// No description provided for @uninterruptedChat.
  ///
  /// In es, this message translates to:
  /// **'Conversación ininterrumpida'**
  String get uninterruptedChat;

  /// No description provided for @silenceBrokeBy.
  ///
  /// In es, this message translates to:
  /// **'Rompió silencio: {name}'**
  String silenceBrokeBy(String name);

  /// No description provided for @mostActiveDayTitle.
  ///
  /// In es, this message translates to:
  /// **'DÍA MÁS ACTIVO DE LA HISTORIA'**
  String get mostActiveDayTitle;

  /// No description provided for @pctOfTotal.
  ///
  /// In es, this message translates to:
  /// **'{pct}% del total'**
  String pctOfTotal(String pct);

  /// No description provided for @daysCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 día} other{{count} días}}'**
  String daysCount(int count);

  /// No description provided for @hoursCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 hora} other{{count} horas}}'**
  String hoursCount(int count);

  /// No description provided for @minutesCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 minuto} other{{count} minutos}}'**
  String minutesCount(int count);

  /// No description provided for @secondsCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 segundo} other{{count} segundos}}'**
  String secondsCount(int count);

  /// No description provided for @searchHint.
  ///
  /// In es, this message translates to:
  /// **'Buscar palabras (ej. Disney, promo)...'**
  String get searchHint;

  /// No description provided for @searchPrompt.
  ///
  /// In es, this message translates to:
  /// **'Escribe una palabra para realizar la búsqueda optimizada.'**
  String get searchPrompt;

  /// No description provided for @noMatchesFound.
  ///
  /// In es, this message translates to:
  /// **'No se encontraron coincidencias para \"{query}\"'**
  String noMatchesFound(String query);

  /// No description provided for @versusNeedMinParticipants.
  ///
  /// In es, this message translates to:
  /// **'Se necesitan al menos 2 participantes en el chat para hacer una comparativa cara a cara.'**
  String get versusNeedMinParticipants;

  /// No description provided for @versusSelectParticipant.
  ///
  /// In es, this message translates to:
  /// **'Selecciona participante'**
  String get versusSelectParticipant;

  /// No description provided for @versusWinner.
  ///
  /// In es, this message translates to:
  /// **'Ganador general: {name}'**
  String versusWinner(String name);

  /// No description provided for @versusTie.
  ///
  /// In es, this message translates to:
  /// **'¡Empate técnico!'**
  String get versusTie;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
