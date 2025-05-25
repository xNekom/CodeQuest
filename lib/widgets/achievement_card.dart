// ignore_for_file: use_super_parameters, deprecated_member_use

import 'package:flutter/material.dart';
import '../models/achievement_model.dart';
import '../theme/pixel_theme.dart';

class AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final bool isUnlocked;
  final VoidCallback? onTap;

  const AchievementCard({
    Key? key,
    required this.achievement,
    this.isUnlocked = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: isUnlocked 
              ? PixelTheme.secondaryColor.withOpacity(0.7)
              : Colors.grey.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUnlocked 
                ? PixelTheme.accentColor 
                : Colors.grey.shade600,
            width: 2,
          ),
          boxShadow: isUnlocked ? [
            BoxShadow(
              color: PixelTheme.accentColor.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 3),
            )
          ] : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Icono del logro
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: isUnlocked ? Theme.of(context).colorScheme.surface : Colors.black38,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isUnlocked ? PixelTheme.accentColor : Colors.grey.shade700,
                    width: 2,
                  ),
                ),
                child: isUnlocked
                    ? Image.network(
                        achievement.iconUrl,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.emoji_events, size: 32, color: PixelTheme.accentColor);
                        },
                      )
                    : const Icon(Icons.lock, size: 32, color: Colors.grey),
              ),
              const SizedBox(width: 16),
              // Información del logro
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isUnlocked ? achievement.name : '???',
                      style: TextStyle(
                        fontFamily: 'PixelFont',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isUnlocked ? Theme.of(context).colorScheme.onSurface : Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isUnlocked ? achievement.description : 'Logro bloqueado',
                      style: TextStyle(
                        fontSize: 14,
                        color: isUnlocked ? Theme.of(context).colorScheme.onSurface.withOpacity(0.8) : Colors.grey.shade600,
                      ),
                    ),
                    if (isUnlocked && achievement.unlockedDate != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Desbloqueado el ${_formatDate(achievement.unlockedDate!.toDate())}',
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Indicador de estado
              isUnlocked
                  ? const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 24,
                    )
                  : const Icon(
                      Icons.lock_outline,
                      color: Colors.grey,
                      size: 24,
                    ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
