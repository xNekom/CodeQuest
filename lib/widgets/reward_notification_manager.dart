import 'dart:async';
import 'package:flutter/material.dart';

class RewardNotificationManager extends StatefulWidget {
  final Widget child;

  const RewardNotificationManager({
    super.key,
    required this.child,
  });

  @override
  State<RewardNotificationManager> createState() => _RewardNotificationManagerState();
}

class _RewardNotificationManagerState extends State<RewardNotificationManager> {
  StreamSubscription<Map<String, dynamic>>? _subscription;

  @override
  void initState() {
    super.initState();
    // Como no existe rewardNotificationStream, vamos a comentar esto por ahora
    // _subscription = _rewardService.rewardNotificationStream.listen(_showRewardNotification);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _showRewardNotification(Map<String, dynamic> achievement) {
    // Verificar que el widget esté montado antes de mostrar la notificación
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.star, color: Colors.yellow),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '¡Logro desbloqueado!',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(achievement['name'] ?? 'Logro desconocido'),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Método público para mostrar notificaciones manualmente
  void showAchievementNotification(String achievementName) {
    if (!mounted) return;
    
    _showRewardNotification({
      'name': achievementName,
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}