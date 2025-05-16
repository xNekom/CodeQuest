import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/achievement_model.dart';
import '../services/auth_service.dart';
import '../services/reward_service.dart';
import '../widgets/achievement_card.dart';
import '../theme/pixel_theme.dart';
import '../widgets/pixel_widgets.dart';
import '../widgets/pixel_art_background.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final AuthService _authService = AuthService();
  final RewardService _rewardService = RewardService();
  late User? _currentUser;
  bool _isLoading = true;
  List<Achievement> _allAchievements = [];
  List<Achievement> _unlockedAchievements = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    _currentUser = _authService.currentUser;
    if (_currentUser == null) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/auth');
      }
      return;
    }

    try {
      final all = await _rewardService.getAchievements().first;
      final unlocked = await _rewardService.getUnlockedAchievements(_currentUser!.uid).first;
      if (mounted) {
        setState(() {
          _allAchievements = all;
          _unlockedAchievements = unlocked;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error al cargar los logros: $e');
      if (mounted) {
        setState(() {
          _allAchievements = [];
          _unlockedAchievements = [];
          _isLoading = false;
        });
      }
    }
  }

  bool _isAchievementUnlocked(String achievementId) {
    return _unlockedAchievements.any((a) => a.id == achievementId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'LOGROS',
          style: TextStyle(
            fontFamily: 'PixelFont',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary, // Updated
        elevation: 0,
      ),
      body: PixelArtBackground(
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.tertiary, // Updated
                ),
              )
            : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    // Calculamos el progreso general de logros
    final progressPercentage = _allAchievements.isEmpty
        ? 0.0
        : _unlockedAchievements.length / _allAchievements.length;

    return Column(
      children: [
        _buildProgressSection(progressPercentage),
        Expanded(
          child: _allAchievements.isEmpty
              ? _buildEmptyState()
              : _buildAchievementsList(),
        ),
      ],
    );
  }

  Widget _buildProgressSection(double progressPercentage) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withAlpha(204), // Updated
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.tertiary, width: 2), // Updated
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
                    color: Theme.of(context).colorScheme.tertiary, // Updated
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.tertiary.withAlpha(77), // Updated
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

  Widget _buildAchievementsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _allAchievements.length,
      itemBuilder: (context, index) {
        final achievement = _allAchievements[index];
        final isUnlocked = _isAchievementUnlocked(achievement.id);
        return AchievementCard(
          achievement: achievement,
          isUnlocked: isUnlocked,
          onTap: () => _showAchievementDetails(achievement, isUnlocked),
        );
      },
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

  void _showAchievementDetails(Achievement achievement, bool isUnlocked) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          isUnlocked ? achievement.name : 'Logro Bloqueado',
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
                color: isUnlocked ? Theme.of(context).colorScheme.primary : Colors.grey.shade300, // Updated
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isUnlocked ? Theme.of(context).colorScheme.tertiary : Colors.grey, // Updated
                  width: 2,
                ),
              ),
              child: isUnlocked
                  ? Center(
                      child: Image.network(
                        achievement.iconUrl,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.emoji_events, size: 48, color: Theme.of(context).colorScheme.tertiary); // Updated
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
              isUnlocked 
                  ? achievement.description 
                  : 'Completa las misiones necesarias para desbloquear este logro.',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            if (isUnlocked && achievement.unlockedDate != null) ...[
              const SizedBox(height: 16),
              Text(
                'Desbloqueado el ${_formatDate(achievement.unlockedDate!.toDate())}',
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
            color: Theme.of(context).colorScheme.secondary, // Updated
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
