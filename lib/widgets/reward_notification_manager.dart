import 'package:flutter/material.dart';
import '../models/reward_model.dart';
import '../services/reward_notification_service.dart';

/// Widget para mostrar y gestionar las notificaciones de recompensas en cualquier pantalla
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
  final RewardNotificationService _notificationService = RewardNotificationService();

  @override
  void initState() {
    super.initState();
    // Escuchar los eventos de notificación
    _notificationService.rewardStream.listen((reward) {
      _showRewardNotification(reward);
    });
  }

  void _showRewardNotification(Reward reward) {
    // Usar el servicio para mostrar la notificación en la UI
    _notificationService.showRewardNotificationWidget(context, reward);
    
    // Opcional: Reproducir efectos
    _notificationService.playRewardSound();
  }

  @override
  Widget build(BuildContext context) {
    // Simplemente devolver el hijo que envuelve este widget
    return widget.child;
  }
}
