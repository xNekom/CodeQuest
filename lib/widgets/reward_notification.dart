// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../models/reward_model.dart';
import '../theme/pixel_theme.dart';
import 'pixel_widgets.dart';

class RewardNotification extends StatefulWidget {
  final Reward reward;
  final VoidCallback? onDismiss;

  const RewardNotification({
    super.key,
    required this.reward,
    this.onDismiss,
  });

  @override
  State<RewardNotification> createState() => _RewardNotificationState();
}

class _RewardNotificationState extends State<RewardNotification> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    
    _controller.forward();

    // Auto dismiss after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      if (widget.onDismiss != null) {
        widget.onDismiss!();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String rewardTypeText = _getRewardTypeText(widget.reward.type);
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: PixelTheme.primaryColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: PixelTheme.accentColor,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: PixelTheme.accentColor.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.stars,
                        color: Colors.amber,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '¡RECOMPENSA OBTENIDA!',
                        style: TextStyle(
                          fontFamily: 'PixelFont',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.stars,
                        color: Colors.amber,
                        size: 24,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(
                        color: PixelTheme.accentColor,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Image.network(
                        widget.reward.iconUrl,
                        width: 60,
                        height: 60,
                        errorBuilder: (context, error, stackTrace) {
                          return _getRewardIcon(widget.reward.type);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.reward.name,
                    style: const TextStyle(
                      fontFamily: 'PixelFont',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.reward.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    rewardTypeText,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _getRewardTypeColor(widget.reward.type),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  PixelButton(
                    onPressed: _dismiss,
                    width: 120,
                    height: 40,
                    child: const Text(
                      'ACEPTAR',
                      style: TextStyle(fontFamily: 'PixelFont', color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _getRewardIcon(RewardType type) {
    switch (type) {
      case RewardType.points:
        return const Icon(Icons.star, color: Colors.amber, size: 40);
      case RewardType.item:
        return const Icon(Icons.inventory_2, color: Colors.blue, size: 40);
      case RewardType.badge:
        return const Icon(Icons.emoji_events, color: Colors.orange, size: 40);
    }
  }

  String _getRewardTypeText(RewardType type) {
    switch (type) {
      case RewardType.points:
        return '+ ${widget.reward.value} puntos de experiencia';
      case RewardType.item:
        return 'Nuevo objeto para tu inventario';
      case RewardType.badge:
        return 'Nueva insignia desbloqueada';
    }
  }

  Color _getRewardTypeColor(RewardType type) {
    switch (type) {
      case RewardType.points:
        return Colors.amber;
      case RewardType.item:
        return Colors.blue;
      case RewardType.badge:
        return Colors.orange;
    }
  }
}
