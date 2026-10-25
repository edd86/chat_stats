// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Estadísticas de WhatsApp';

  @override
  String get chatsImported => 'CHATS IMPORTADOS';

  @override
  String get noChatsYet =>
      'Aún no has guardado ninguna sala de chat.\nImporta un archivo .zip o .txt arriba para comenzar.';

  @override
  String get importChatSuccess => '¡Chat importado con éxito!';

  @override
  String chatLoadError(String error) {
    return 'Error al cargar chats: $error';
  }

  @override
  String get uploadTitle => 'Toca aquí para importar un chat';

  @override
  String get uploadSubtitle =>
      'Sube un archivo .zip o .txt exportado de WhatsApp';

  @override
  String get processingMessages => 'Procesando mensajes...';

  @override
  String get howToExport => '¿Cómo exportar desde WhatsApp?';

  @override
  String get howToExportButton => '¿Cómo exportar un chat?';

  @override
  String get exportStep1 =>
      '1. Abre el chat o grupo en WhatsApp que deseas analizar.';

  @override
  String get exportStep2Android =>
      '2. Toca los tres puntos (⋮) en la esquina superior derecha.';

  @override
  String get exportStep2Ios =>
      '2. Toca el nombre del contacto o grupo en la parte superior.';

  @override
  String get exportStep3Android => '3. Selecciona \"Más\" ➔ \"Exportar chat\".';

  @override
  String get exportStep3Ios =>
      '3. Desplázate hacia abajo y selecciona \"Exportar chat\".';

  @override
  String get exportStep4 =>
      '4. ¡IMPORTANTE! Elige la opción \"Sin archivos multimedia\".';

  @override
  String get exportStep5Android =>
      '5. Comparte directo con \"Chat Stats\" o guarda el archivo .zip/.txt y selecciónalo aquí.';

  @override
  String get exportStep5Ios =>
      '5. Comparte directo a esta app o guarda en \"Archivos\" y selecciónalo desde aquí.';

  @override
  String importedOn(String date) {
    return 'Importado el $date';
  }

  @override
  String get deleteChat => 'Eliminar de SQLite';

  @override
  String get deleteConfirmTitle => '¿Eliminar chat?';

  @override
  String get deleteConfirmMessage =>
      '¿Estás seguro de que deseas eliminar este chat de la base de datos?';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String messagesCount(int count) {
    return '$count msgs';
  }

  @override
  String usersCount(int count) {
    return '$count usuarios';
  }

  @override
  String mediaCount(int count) {
    return '$count multimedia';
  }

  @override
  String get securityAndPrivacy => 'Seguridad y Privacidad';

  @override
  String get privacyExplanation =>
      'Tus chats se procesan 100% en tu dispositivo y nunca se envían a ningún servidor externo.';

  @override
  String get biometricLockTitle => 'Bloqueo con Huella / PIN';

  @override
  String get biometricLockSubtitle => 'Solicitar autenticación al abrir la app';

  @override
  String get securityLockActivated => 'Bloqueo de Seguridad Activado';

  @override
  String get securityLockPrompt =>
      'Confirma tu identidad para acceder a tus chats y estadísticas.';

  @override
  String get unlock => 'Desbloquear';

  @override
  String get authReason =>
      'Confirma tu identidad para acceder a tus chats y estadísticas.';

  @override
  String get language => 'Idioma';

  @override
  String get languageSubtitle => 'Selecciona el idioma de la aplicación';

  @override
  String get systemDefaultLanguage => 'Predeterminado del sistema';

  @override
  String get spanishLanguage => 'Español (Latinoamérica)';

  @override
  String get englishLanguage => 'English';

  @override
  String get portugueseLanguage => 'Português';

  @override
  String get chatDetails => 'Detalles del Chat';

  @override
  String localData(String fileName) {
    return 'Datos locales: $fileName';
  }

  @override
  String get loading => 'Cargando...';

  @override
  String get error => 'Error';

  @override
  String get chatNotFound => 'Chat no encontrado localmente.';

  @override
  String get versusDuel => 'Duelo: Cara a Cara ⚔️';

  @override
  String get searchInChat => 'Buscar en Local';

  @override
  String get wrapped => 'Wrapped';

  @override
  String get filterAllTime => 'Todo el tiempo';

  @override
  String get filterLast30Days => 'Últimos 30 días';

  @override
  String get filterThisYear => 'Este año';

  @override
  String get filterCustom => 'Personalizado';

  @override
  String get kpiMessages => 'Mensajes';

  @override
  String get kpiInPeriod => 'En período';

  @override
  String get kpiTotalExchanged => 'Total intercambiados';

  @override
  String get kpiMedia => 'Archivos';

  @override
  String get kpiAudiosPhotos => 'Audios, fotos, stickers';

  @override
  String get kpiWords => 'Palabras';

  @override
  String get kpiWrittenContent => 'Contenido escrito';

  @override
  String get kpiParticipants => 'Participantes';

  @override
  String get kpiActiveMembers => 'Miembros activos';

  @override
  String get kpiDailyAverage => 'Promedio Diario';

  @override
  String get kpiDailyPace => 'Ritmo de actividad';

  @override
  String get kpiMsgsPerDay => 'msgs/día';

  @override
  String get kpiChatDuration => 'Duración del Chat';

  @override
  String get kpiHistorySpan => 'Historial registrado';

  @override
  String get kpiEmojis => 'Emojis Usados';

  @override
  String get kpiExpressions => 'Expresiones y caras';

  @override
  String get kpiTotalLinks => 'Links Enviados';

  @override
  String get kpiWebReferences => 'Referencias web';

  @override
  String get activityOverTime => 'ACTIVIDAD A LO LARGO DEL TIEMPO';

  @override
  String get activityHeatmap => 'MAPA DE ACTIVIDAD (DÍA × HORA)';

  @override
  String get lessActivity => 'Menos';

  @override
  String get moreActivity => 'Más';

  @override
  String get hourlyDistribution => 'DISTRIBUCIÓN HORARIA';

  @override
  String peakHourLabel(String hour, String count) {
    return 'Pico: $hour:00h ($count msgs)';
  }

  @override
  String get timeSlotDawn => 'Madrugada';

  @override
  String get timeSlotMorning => 'Mañana';

  @override
  String get timeSlotAfternoon => 'Tarde';

  @override
  String get timeSlotNight => 'Noche';

  @override
  String slotShareBadge(String pct) {
    return '$pct% de los mensajes';
  }

  @override
  String get viewByPeriods => 'Por Períodos';

  @override
  String get viewBy24Hours => '24 Horas';

  @override
  String get conversationDynamics => 'DINÁMICA DE LA CONVERSACIÓN';

  @override
  String get longestSilenceTitle => 'EL SILENCIO MÁS LARGO';

  @override
  String get uninterruptedChat => 'Conversación ininterrumpida';

  @override
  String silenceBrokeBy(String name) {
    return 'Rompió silencio: $name';
  }

  @override
  String get mostActiveDayTitle => 'DÍA MÁS ACTIVO DE LA HISTORIA';

  @override
  String pctOfTotal(String pct) {
    return '$pct% del total';
  }

  @override
  String daysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días',
      one: '1 día',
    );
    return '$_temp0';
  }

  @override
  String hoursCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count horas',
      one: '1 hora',
    );
    return '$_temp0';
  }

  @override
  String minutesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutos',
      one: '1 minuto',
    );
    return '$_temp0';
  }

  @override
  String secondsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count segundos',
      one: '1 segundo',
    );
    return '$_temp0';
  }

  @override
  String get searchHint => 'Buscar palabras (ej. Disney, promo)...';

  @override
  String get searchPrompt =>
      'Escribe una palabra para realizar la búsqueda optimizada.';

  @override
  String noMatchesFound(String query) {
    return 'No se encontraron coincidencias para \"$query\"';
  }

  @override
  String get versusNeedMinParticipants =>
      'Se necesitan al menos 2 participantes en el chat para hacer una comparativa cara a cara.';

  @override
  String get versusSelectParticipant => 'Selecciona participante';

  @override
  String versusWinner(String name) {
    return 'Ganador general: $name';
  }

  @override
  String get versusTie => '¡Empate técnico!';
}
