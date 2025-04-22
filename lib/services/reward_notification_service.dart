import 'dart:async';
import 'package:flutter/material.dart';
import '../models/reward_model.dart';
import '../widgets/reward_notification.dart';

class RewardNotificationService {
  static final RewardNotificationService _instance = RewardNotificationService._internal();
  factory RewardNotificationService() => _instance;
  RewardNotificationService._internal();

  final StreamController<Reward> _rewardStreamController = StreamController<Reward>.broadcast();
  Stream<Reward> get rewardStream => _rewardStreamController.stream;

  // Método para mostrar una notificación de recompensa
  void showRewardNotification(Reward reward) {
    _rewardStreamController.add(reward);
  }

  // Método para mostrar la notificación en la UI
  void showRewardNotificationWidget(BuildContext context, Reward reward) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry; // Declarar como late final

    overlayEntry = OverlayEntry( // Asignar aquí
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.15,
        left: 0,
        right: 0,
        child: Center(
          child: RewardNotification(
            reward: reward,
            onDismiss: () {
              // Eliminar la entrada de overlay cuando se cierre la notificación
              Future.delayed(const Duration(milliseconds: 300), () {
                if (overlayEntry.mounted) { // Verificar si aún está montado antes de remover
                  overlayEntry.remove();
                }
              });
            },
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
  }

  // Método para reproducir efectos de sonido (opcional)
  void playRewardSound() {
    // Implementar la reproducción de sonido con un paquete de audio
    // Por ejemplo:
    // AudioPlayer().play('assets/sounds/reward.mp3');
  }

  // Método para reproducir una animación de confeti (opcional)
  void playConfettiAnimation(BuildContext context) {
    // Implementar una animación de confeti
    // Por ejemplo usando el paquete confetti
  }

  void dispose() {
    _rewardStreamController.close();
  }
}
