import 'package:chat_stats/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../localization/locale_provider.dart';
import '../theme/app_colors.dart';

void showLanguageSelectorSheet(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surfaceContainer,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      final currentLocale = ref.watch(localeProvider);
      final l10n = AppLocalizations.of(sheetContext);

      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.language_rounded, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Text(
                    l10n?.language ?? 'Idioma',
                    style: Theme.of(sheetContext).textTheme.headlineMedium?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                l10n?.languageSubtitle ?? 'Selecciona el idioma de la aplicación',
                style: const TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: kSupportedLanguages.length,
                  separatorBuilder: (_, _) => const Divider(
                    color: AppColors.outlineVariant,
                    height: 1,
                  ),
                  itemBuilder: (context, index) {
                    final item = kSupportedLanguages[index];
                    final isSelected = (item.locale == null && currentLocale == null) ||
                        (item.locale != null &&
                            currentLocale != null &&
                            item.locale!.languageCode == currentLocale.languageCode);

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      leading: Text(
                        item.flagEmoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                      title: Text(
                        item.label,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? AppColors.primary : AppColors.onSurface,
                        ),
                      ),
                      subtitle: Text(
                        item.nativeLabel,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                          : null,
                      onTap: () async {
                        await ref.read(localeProvider.notifier).setLocale(item.locale);
                        if (sheetContext.mounted) {
                          Navigator.pop(sheetContext);
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
