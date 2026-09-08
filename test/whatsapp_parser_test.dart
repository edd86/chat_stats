import 'package:flutter_test/flutter_test.dart';
import 'package:chat_stats/features/chat_import/utils/whatsapp_parser.dart';
import 'package:chat_stats/features/chat_dashboard/domain/models/message_analysis.dart';

void main() {
  group('WhatsAppParser Unit Tests', () {
    test(
      'extractChatTitle extracts room title after "Chat de WhatsApp con"',
      () {
        const fileName =
            'Chat de WhatsApp con En este grupo no se Admiten Ronalds 😅.txt';
        final title = WhatsAppParser.extractChatTitle(fileName);
        expect(title, equals('En este grupo no se Admiten Ronalds 😅'));
      },
    );

    test('extractChatTitle falls back to clean filename when no prefix', () {
      const fileName = 'Mi Grupo Familiar.txt';
      final title = WhatsAppParser.extractChatTitle(fileName);
      expect(title, equals('Mi Grupo Familiar'));
    });

    test(
      'parseChatContent accurately parses messages, senders, system events and media',
      () async {
        const sampleText = '''
3/7/24 14:31 - Los mensajes y las llamadas están cifrados de extremo a extremo.
3/7/24 14:31 - Creaste este grupo
3/7/24 14:32 - EdDⓈ: Buenas tardes chicos en este grupo estamos los q contratamos el servicio de Disney plus...
3/7/24 14:34 - Amael Vargas: Ok, administrador
3/7/24 14:35 - EdDⓈ: <Multimedia omitido>
3/7/24 14:51 - Daniel Torres: me agrada el nombre del grupo <Se editó este mensaje.>
''';

        final result = await WhatsAppParser.parseChatContent(
          rawFileName: 'Chat de WhatsApp con Disney Group.txt',
          fileContent: sampleText,
        );

        expect(result.chat.name, equals('Disney Group'));
        expect(result.chat.totalMessages, equals(6));
        expect(result.chat.totalMedia, equals(1));
        expect(result.participants.length, equals(3));

        // EdDⓈ sent 2 messages (1 media)
        final edd = result.participants.firstWhere((p) => p.name == 'EdDⓈ');
        expect(edd.messageCount, equals(2));
        expect(edd.mediaCount, equals(1));

        // System messages
        final systemMessages = result.messages
            .where((m) => m.isSystem)
            .toList();
        expect(systemMessages.length, equals(2));

        // Edited message check
        final editedMsg = result.messages.firstWhere((m) => m.isEdited);
        expect(editedMsg.sender, equals('Daniel Torres'));
      },
    );

    test(
      'parseChatContent and MessageAnalysis correctly process mentions with bidi control characters',
      () async {
        const sampleText = '''
7/9/26 12:28 - Papa: Hola a todos
7/9/26 12:28 - Mama: Hola hijo
7/9/26 12:29 - EdD🧐: @\u2068Papa\u2069 @\u2068Mama\u2069
''';

        final result = await WhatsAppParser.parseChatContent(
          rawFileName: 'Chat de WhatsApp con Familia.txt',
          fileContent: sampleText,
        );

        final messagesMap = result.messages
            .map(
              (m) => {
                'sender': m.sender,
                'content': m.content,
                'char_count': m.charCount,
                'is_deleted': m.isDeleted ? 1 : 0,
                'is_media': m.isMedia ? 1 : 0,
              },
            )
            .toList();

        final analysis = MessageAnalysis.process(messagesMap, [], []);

        final eddParticipant = analysis.participants.firstWhere(
          (p) => p.name == 'EdD🧐',
        );
        expect(eddParticipant.mentionsCount, equals(2));
        expect(analysis.mentionsReceived['Papa'], equals(1));
        expect(analysis.mentionsReceived['Mama'], equals(1));
      },
    );
  });
}
