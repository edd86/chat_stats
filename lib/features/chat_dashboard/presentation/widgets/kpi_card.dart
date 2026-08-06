import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;

  const KpiCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant, width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: color),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
