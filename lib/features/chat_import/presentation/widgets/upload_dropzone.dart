import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class UploadDropzone extends StatelessWidget {
  final VoidCallback onTap;
  final bool isLoading;

  const UploadDropzone({
    super.key,
    required this.onTap,
    this.isLoading = false,
  });

  void _showExportInstructions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceContainerLow,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DefaultTabController(
          length: 2,
          child: Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 16,
              bottom: MediaQuery.of(context).padding.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.help_outline, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '¿Cómo exportar desde WhatsApp?',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.onSurfaceVariant,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const TabBar(
                  indicatorColor: AppColors.primary,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.onSurfaceVariant,
                  tabs: [
                    Tab(icon: Icon(Icons.android), text: 'Android'),
                    Tab(icon: Icon(Icons.apple), text: 'iPhone (iOS)'),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 300,
                  child: TabBarView(
                    children: [
                      _buildStepList([
                        '1. Abre el chat o grupo en WhatsApp que deseas analizar.',
                        '2. Toca los tres puntos (⋮) en la esquina superior derecha.',
                        '3. Selecciona "Más" ➔ "Exportar chat".',
                        '4. ¡IMPORTANTE! Elige la opción "Sin archivos multimedia".',
                        '5. Comparte directo con "Chat Stats" o guarda el archivo .zip/.txt y selecciónalo aquí.',
                      ]),
                      _buildStepList([
                        '1. Abre el chat o grupo en WhatsApp que deseas analizar.',
                        '2. Toca el nombre del contacto o grupo en la parte superior.',
                        '3. Desplázate hacia abajo y selecciona "Exportar chat".',
                        '4. ¡IMPORTANTE! Elige la opción "Sin archivos multimedia".',
                        '5. Comparte directo a esta app o guarda en "Archivos" y selecciónalo desde aquí.',
                      ]),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepList(List<String> steps) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      itemCount: steps.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final text = steps[index];
        final isImportant = text.contains('IMPORTANTE');
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isImportant
                ? AppColors.primaryContainer.withValues(alpha: 0.3)
                : AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(10),
            border: isImportant
                ? Border.all(color: AppColors.primary, width: 1)
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                isImportant ? Icons.star_rounded : Icons.check_circle_outline,
                size: 18,
                color: isImportant ? AppColors.primary : AppColors.secondary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 13,
                    color: isImportant
                        ? AppColors.onSurface
                        : AppColors.onSurfaceVariant,
                    fontWeight: isImportant
                        ? FontWeight.bold
                        : FontWeight.normal,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.5),
            width: 1.5,
          ),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.surfaceContainer, AppColors.surfaceContainerLow],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading) ...[
              const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                'Analizando y guardando chat en Local',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cloud_upload_outlined,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Seleccionar archivo o exportar desde WhatsApp',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Selecciona un archivo .zip o .txt, o comparte directamente desde WhatsApp.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () => _showExportInstructions(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.6),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.help_outline_rounded,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '¿Cómo exportar desde WhatsApp?',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 13,
                    color: AppColors.tertiary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Importante: Exportar sin archivos multimedia',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
