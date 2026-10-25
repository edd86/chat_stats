// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Estatísticas do WhatsApp';

  @override
  String get chatsImported => 'CHATS IMPORTADOS';

  @override
  String get noChatsYet =>
      'Você ainda não salvou nenhuma conversa.\nImporte um arquivo .zip ou .txt acima para começar.';

  @override
  String get importChatSuccess => 'Conversa importada com sucesso!';

  @override
  String chatLoadError(String error) {
    return 'Erro ao carregar conversas: $error';
  }

  @override
  String get uploadTitle => 'Toque aqui para importar uma conversa';

  @override
  String get uploadSubtitle =>
      'Envie um arquivo .zip ou .txt exportado do WhatsApp';

  @override
  String get processingMessages => 'Processando mensagens...';

  @override
  String get howToExport => 'Como exportar do WhatsApp?';

  @override
  String get howToExportButton => 'Como exportar uma conversa?';

  @override
  String get exportStep1 =>
      '1. Abra a conversa ou grupo do WhatsApp que deseja analisar.';

  @override
  String get exportStep2Android =>
      '2. Toque nos três pontinhos (⋮) no canto superior direito.';

  @override
  String get exportStep2Ios =>
      '2. Toque no nome do contato ou grupo na parte superior.';

  @override
  String get exportStep3Android =>
      '3. Selecione \"Mais\" ➔ \"Exportar conversa\".';

  @override
  String get exportStep3Ios =>
      '3. Role para baixo e selecione \"Exportar conversa\".';

  @override
  String get exportStep4 => '4. IMPORTANTE! Escolha a opção \"Sem mídia\".';

  @override
  String get exportStep5Android =>
      '5. Compartilhe diretamente com \"Chat Stats\" ou salve o arquivo .zip/.txt e selecione-o aqui.';

  @override
  String get exportStep5Ios =>
      '5. Compartilhe diretamente com este aplicativo ou salve em \"Arquivos\" e selecione-o por aqui.';

  @override
  String importedOn(String date) {
    return 'Importado em $date';
  }

  @override
  String get deleteChat => 'Excluir do SQLite';

  @override
  String get deleteConfirmTitle => 'Excluir conversa?';

  @override
  String get deleteConfirmMessage =>
      'Tem certeza de que deseja excluir esta conversa do banco de dados?';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Excluir';

  @override
  String messagesCount(int count) {
    return '$count msgs';
  }

  @override
  String usersCount(int count) {
    return '$count usuários';
  }

  @override
  String mediaCount(int count) {
    return '$count mídias';
  }

  @override
  String get securityAndPrivacy => 'Segurança e Privacidade';

  @override
  String get privacyExplanation =>
      'Suas conversas são processadas 100% no seu dispositivo e nunca são enviadas para nenhum servidor externo.';

  @override
  String get biometricLockTitle => 'Bloqueio com Biometria / PIN';

  @override
  String get biometricLockSubtitle =>
      'Solicitar autenticação ao abrir o aplicativo';

  @override
  String get securityLockActivated => 'Bloqueio de Segurança Ativado';

  @override
  String get securityLockPrompt =>
      'Confirme sua identidade para acessar suas conversas e estatísticas.';

  @override
  String get unlock => 'Desbloquear';

  @override
  String get authReason =>
      'Confirme sua identidade para acessar suas conversas e estatísticas.';

  @override
  String get language => 'Idioma';

  @override
  String get languageSubtitle => 'Selecione o idioma do aplicativo';

  @override
  String get systemDefaultLanguage => 'Padrão do sistema';

  @override
  String get spanishLanguage => 'Español (Latinoamérica)';

  @override
  String get englishLanguage => 'English';

  @override
  String get portugueseLanguage => 'Português';

  @override
  String get chatDetails => 'Detalhes da Conversa';

  @override
  String localData(String fileName) {
    return 'Dados locais: $fileName';
  }

  @override
  String get loading => 'Carregando...';

  @override
  String get error => 'Erro';

  @override
  String get chatNotFound => 'Conversa não encontrada localmente.';

  @override
  String get versusDuel => 'Duelo: Cara a Cara ⚔️';

  @override
  String get searchInChat => 'Busca Local';

  @override
  String get wrapped => 'Wrapped';

  @override
  String get filterAllTime => 'Todo o período';

  @override
  String get filterLast30Days => 'Últimos 30 dias';

  @override
  String get filterThisYear => 'Este ano';

  @override
  String get filterCustom => 'Personalizado';

  @override
  String get kpiMessages => 'Mensagens';

  @override
  String get kpiInPeriod => 'No período';

  @override
  String get kpiTotalExchanged => 'Total trocadas';

  @override
  String get kpiMedia => 'Arquivos';

  @override
  String get kpiAudiosPhotos => 'Áudios, fotos, figurinhas';

  @override
  String get kpiWords => 'Palavras';

  @override
  String get kpiWrittenContent => 'Conteúdo escrito';

  @override
  String get kpiParticipants => 'Participantes';

  @override
  String get kpiActiveMembers => 'Membros ativos';

  @override
  String get kpiDailyAverage => 'Média Diária';

  @override
  String get kpiDailyPace => 'Ritmo de atividade';

  @override
  String get kpiMsgsPerDay => 'msgs/dia';

  @override
  String get kpiChatDuration => 'Duração da Conversa';

  @override
  String get kpiHistorySpan => 'Histórico registrado';

  @override
  String get kpiEmojis => 'Emojis Usados';

  @override
  String get kpiExpressions => 'Expressões e rostos';

  @override
  String get kpiTotalLinks => 'Links Enviados';

  @override
  String get kpiWebReferences => 'Referências da web';

  @override
  String get activityOverTime => 'ATIVIDADE AO LONGO DO TEMPO';

  @override
  String get activityHeatmap => 'MAPA DE ATIVIDADE (DIA × HORA)';

  @override
  String get lessActivity => 'Menos';

  @override
  String get moreActivity => 'Mais';

  @override
  String get hourlyDistribution => 'DISTRIBUIÇÃO HORÁRIA';

  @override
  String peakHourLabel(String hour, String count) {
    return 'Pico: $hour:00h ($count msgs)';
  }

  @override
  String get timeSlotDawn => 'Madrugada';

  @override
  String get timeSlotMorning => 'Manhã';

  @override
  String get timeSlotAfternoon => 'Tarde';

  @override
  String get timeSlotNight => 'Noite';

  @override
  String slotShareBadge(String pct) {
    return '$pct% das mensagens';
  }

  @override
  String get viewByPeriods => 'Por Períodos';

  @override
  String get viewBy24Hours => '24 Horas';

  @override
  String get conversationDynamics => 'DINÂMICA DA CONVERSA';

  @override
  String get longestSilenceTitle => 'MAIOR SILÊNCIO';

  @override
  String get uninterruptedChat => 'Conversa ininterrupta';

  @override
  String silenceBrokeBy(String name) {
    return 'Quebrou o silêncio: $name';
  }

  @override
  String get mostActiveDayTitle => 'DIA MAIS ATIVO DA HISTÓRIA';

  @override
  String pctOfTotal(String pct) {
    return '$pct% do total';
  }

  @override
  String daysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dias',
      one: '1 dia',
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
  String get searchHint => 'Pesquisar palavras (ex. Disney, promo)...';

  @override
  String get searchPrompt =>
      'Digite uma palavra para realizar a busca otimizada.';

  @override
  String noMatchesFound(String query) {
    return 'Nenhum resultado encontrado para \"$query\"';
  }

  @override
  String get versusNeedMinParticipants =>
      'São necessários pelo menos 2 participantes para fazer uma comparação cara a cara.';

  @override
  String get versusSelectParticipant => 'Selecionar participante';

  @override
  String versusWinner(String name) {
    return 'Vencedor geral: $name';
  }

  @override
  String get versusTie => 'Empate técnico!';
}
