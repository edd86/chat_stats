import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/chat_dashboard_provider.dart';

class ChatSearchPage extends ConsumerStatefulWidget {
  final int chatId;
  final String? initialQuery;

  const ChatSearchPage({super.key, required this.chatId, this.initialQuery});

  @override
  ConsumerState<ChatSearchPage> createState() => _ChatSearchPageState();
}

class _ChatSearchPageState extends ConsumerState<ChatSearchPage> {
  late final TextEditingController _searchController;
  String _query = '';
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _query = widget.initialQuery ?? '';
    _searchController = TextEditingController(text: _query);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String val) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => _query = val);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final searchResultsAsync = ref.watch(
      chatSearchProvider((chatId: widget.chatId, query: _query)),
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: widget.initialQuery == null || widget.initialQuery!.isEmpty,
          style: const TextStyle(color: AppColors.onSurface),
          decoration: InputDecoration(
            hintText: 'Buscar palabras (e.g. Disney, promo)...',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.clear,
                      color: AppColors.onSurfaceVariant,
                    ),
                    onPressed: () {
                      _debounceTimer?.cancel();
                      _searchController.clear();
                      setState(() => _query = '');
                    },
                  )
                : null,
          ),
          onChanged: _onSearchChanged,
        ),
      ),
      body: _query.isEmpty
          ? const Center(
              child: Text(
                'Escribe una palabra para realizar la búsqueda optimizada.',
                style: TextStyle(color: AppColors.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            )
          : searchResultsAsync.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return Center(
                    child: Text(
                      'No se encontraron coincidencias para "$_query"',
                      style: const TextStyle(color: AppColors.onSurfaceVariant),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    return Card(
                      color: AppColors.surfaceContainer,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              msg.sender,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '${msg.dateStr} ${msg.timeStr}',
                              style: const TextStyle(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            msg.content,
                            style: const TextStyle(color: AppColors.onSurface),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (err, _) =>
                  Center(child: Text('Error en búsqueda SQLite: $err')),
            ),
    );
  }
}
