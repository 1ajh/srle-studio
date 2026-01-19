import 'package:flutter/material.dart';
import '../models/effect_mode.dart';

class EffectCard extends StatelessWidget {
  final EffectMode effect;
  final bool isSelected;
  final VoidCallback onTap;

  const EffectCard({
    super.key,
    required this.effect,
    required this.isSelected,
    required this.onTap,
  });

  IconData _getCategoryIcon() {
    switch (effect.category) {
      case EffectCategory.vocoder:
        return Icons.mic;
      case EffectCategory.colorGrade:
        return Icons.palette;
      case EffectCategory.glitch:
        return Icons.broken_image;
      case EffectCategory.audio:
        return Icons.audiotrack;
      case EffectCategory.ytpmv:
        return Icons.music_note;
      default:
        return Icons.auto_awesome;
    }
  }

  Color _getCategoryColor() {
    switch (effect.category) {
      case EffectCategory.vocoder:
        return Colors.purple;
      case EffectCategory.colorGrade:
        return Colors.orange;
      case EffectCategory.glitch:
        return Colors.red;
      case EffectCategory.audio:
        return Colors.blue;
      case EffectCategory.ytpmv:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor();

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
              : const Color(0xFF252525),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Category Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getCategoryIcon(),
                      color: categoryColor,
                      size: 18,
                    ),
                  ),
                  const Spacer(),
                  // Desktop Only Badge
                  if (effect.requiresDesktop)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.computer,
                        size: 12,
                        color: Colors.orange,
                      ),
                    ),
                  // Has Parameters Badge
                  if (effect.parameters.isNotEmpty) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.tune,
                        size: 12,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ],
              ),

              const Spacer(),

              // Effect Name
              Text(
                effect.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              // Description
              Text(
                effect.description,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
