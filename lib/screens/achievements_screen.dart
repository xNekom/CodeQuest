import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/reward_notification_service.dart';
import '../services/reward_service.dart';
import '../services/tutorial_service.dart';
import '../models/achievement_model.dart';
import '../models/reward_model.dart'; // Importar Reward
import '../widgets/achievement_card.dart';
import '../widgets/pixel_art_background.dart';
import '../widgets/pixel_widgets.dart';
import '../widgets/tutorial_floating_button.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final AuthService _authService = AuthService();
  final RewardService _rewardService = RewardService();
  final RewardNotificationService _rewardNotificationService = RewardNotificationService();
  late User? _currentUser;
  bool _isLoading = true;
  List<Achievement> _allAchievements = [];
  List<Achievement> _unlockedAchievements = [];
  StreamSubscription<List<Achievement>>? _allSub;
  StreamSubscription<List<Achievement>>? _unlockedAchievementsSub;
  StreamSubscription<Reward>? _rewardSubscription; // Usar Reward importado

  // GlobalKeys para el sistema de tutoriales
  final GlobalKey _progressBarKey = GlobalKey();
  final GlobalKey _achievementListKey = GlobalKey();
  final GlobalKey _backButtonKey = GlobalKey();  @override
  void initState() {
    super.initState();
    _currentUser = _authService.currentUser;
    if (_currentUser != null) {
      _unlockedAchievementsSub = _rewardService
          .getUnlockedAchievements(_currentUser!.uid)
          .listen((unlocked) {
        if (mounted) {
          setState(() {
            _unlockedAchievements = unlocked;
            _isLoading = false; // Marcar como cargado cuando se reciben los datos
          });
        }
      });
      _allSub = _rewardService.getAchievements().listen((all) {
        if (mounted) {
          setState(() {
            _allAchievements = all;
            _isLoading = false; // Marcar como cargado cuando se reciben los datos
          });
        }
      });
      _rewardSubscription = _rewardNotificationService.rewardStream.listen((reward) {
        if (mounted) {
          _rewardNotificationService.showRewardNotificationWidget(context, reward);
        }
      });
    } else {
      // Si no hay usuario, no cargar y quitar el spinner
      setState(() {
        _isLoading = false;
      });
    }
    _checkAndStartTutorial();
  }

  /// Inicia el tutorial si es necesario
  Future<void> _checkAndStartTutorial() async {
    // Esperar a que la UI se construya completamente
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (mounted) {
      TutorialService.startTutorialIfNeeded(
        context,
        TutorialService.achievementsTutorial,
        TutorialService.getAchievementsTutorial(
          progressKey: _progressBarKey,
          achievementGridKey: _achievementListKey,
          rewardsKey: _backButtonKey,
        ),
      );
    }
  }

  @override
  void dispose() {
    _unlockedAchievementsSub?.cancel();
    _allSub?.cancel();
    _rewardSubscription?.cancel();
    super.dispose();
  }

  bool _isAchievementUnlocked(String id) =>
      _unlockedAchievements.any((a) => a.id == id);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        key: _backButtonKey,
        title: const Text('LOGROS', style: TextStyle(fontFamily: 'PixelFont', fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: PixelArtBackground(
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _buildContent(),
      ),
      floatingActionButton: TutorialFloatingButton(
        tutorialKey: TutorialService.achievementsTutorial,
        tutorialSteps: TutorialService.getAchievementsTutorial(
          progressKey: _progressBarKey,
          achievementGridKey: _achievementListKey,
          rewardsKey: _backButtonKey,
        ),
      ),
    );
  }
  Widget _buildContent() {
    final pct = _allAchievements.isEmpty
        ? 0.0
        : _unlockedAchievements.length / _allAchievements.length;
    return Column(
      children: [
        _buildProgressSection(pct),
        Expanded(
          child: _allAchievements.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  key: _achievementListKey,
                  itemCount: _allAchievements.length,
                  itemBuilder: (ctx, i) {
                    final a = _allAchievements[i];
                    final unlocked = _isAchievementUnlocked(a.id);
                    return AchievementCard(
                      achievement: a,
                      isUnlocked: unlocked,
                      onTap: () => _showAchievementDetails(a, unlocked),
                    );
                  },
                ),
        ),
      ],
    );
  }
  Widget _buildProgressSection(double progressPercentage) {
    return Container(
      key: _progressBarKey,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withAlpha(204),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.tertiary, width: 2),
      ),
      child: Column(
        children: [
          Text(
            'Progreso de Logros',
            style: TextStyle(
              fontFamily: 'PixelFont',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Stack(
            children: [
              // Barra de progreso de fondo
              Container(
                width: double.infinity,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              // Barra de progreso real
              FractionallySizedBox(
                widthFactor: progressPercentage,
                child: Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiary,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.tertiary.withAlpha(77),
                        spreadRadius: 1,
                        blurRadius: 3,
                      ),
                    ],
                  ),
                ),
              ),
              // Texto de porcentaje
              Center(
                child: Container(
                  height: 20,
                  alignment: Alignment.center,
                  child: Text(
                    '${(progressPercentage * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: progressPercentage > 0.5 ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${_unlockedAchievements.length} de ${_allAchievements.length} logros desbloqueados',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(204),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay logros disponibles',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vuelve más tarde para ver los nuevos logros',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showAchievementDetails(Achievement a, bool unlocked) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          unlocked ? a.name : 'Logro Bloqueado',
          style: TextStyle(
            fontFamily: 'PixelFont',
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: unlocked ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: unlocked ? Theme.of(context).colorScheme.tertiary : Colors.grey,
                  width: 2,
                ),
              ),
              child: unlocked
                  ? Center(
                      child: Image.network(
                        a.iconUrl,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.emoji_events, size: 48, color: Theme.of(context).colorScheme.tertiary);
                        },
                      ),
                    )
                  : const Center(
                      child: Icon(
                        Icons.lock,
                        size: 48,
                        color: Colors.grey,
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            Text(
              unlocked 
                  ? a.description 
                  : 'Completa las misiones necesarias para desbloquear este logro.',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            if (unlocked && a.unlockedDate != null) ...[
              const SizedBox(height: 16),
              Text(
                'Desbloqueado el ${_formatDate(a.unlockedDate!.toDate())}',
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(179),
                ),
              ),
            ],
          ],
        ),
        actions: [
          PixelButton(
            onPressed: () => Navigator.of(context).pop(),
            width: 120,
            height: 40,
            color: Theme.of(context).colorScheme.secondary,
            child: const Text(
              'CERRAR',
              style: TextStyle(fontFamily: 'PixelFont', color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
