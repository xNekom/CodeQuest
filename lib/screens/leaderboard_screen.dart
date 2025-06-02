import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/leaderboard_service.dart';
import '../services/tutorial_service.dart';
import '../models/leaderboard_entry_model.dart';
import '../widgets/pixel_widgets.dart';
import '../widgets/tutorial_floating_button.dart';
import '../utils/overflow_utils.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final LeaderboardService _leaderboardService = LeaderboardService();
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  int? _currentUserRanking;
  bool _isLoadingRanking = true;
  
  // GlobalKeys para el sistema de tutoriales
  final GlobalKey _userRankingKey = GlobalKey();
  final GlobalKey _leaderboardListKey = GlobalKey();
  final GlobalKey _topPlayersKey = GlobalKey();
  final GlobalKey _backButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadCurrentUserRanking();
    _checkAndStartTutorial();
  }
  
  /// Inicia el tutorial si es necesario
  Future<void> _checkAndStartTutorial() async {
    // Esperar a que la UI se construya completamente
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (mounted) {
      TutorialService.startTutorialIfNeeded(
        context,
        TutorialService.leaderboardTutorial,
        TutorialService.getLeaderboardTutorial(
          userRankingKey: _userRankingKey,
          leaderboardListKey: _leaderboardListKey,
          timeFilterKey: _topPlayersKey,
          backButtonKey: _backButtonKey,
        ),
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recargar datos solo cuando la ruta se vuelve activa
    if (mounted && ModalRoute.of(context)?.isCurrent == true) {
      // Usar Future.microtask en lugar de addPostFrameCallback para evitar bucles infinitos
      Future.microtask(() {
        if (mounted) {
          _loadCurrentUserRanking();
        }
      });
    }
  }

  Future<void> _loadCurrentUserRanking() async {
    if (_currentUser != null) {
      final ranking = await _leaderboardService.getUserRanking(
        _currentUser.uid,
      );
      setState(() {
        _currentUserRanking = ranking;
        _isLoadingRanking = false;
      });
    } else {
      setState(() {
        _isLoadingRanking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'TABLA DE CLASIFICACIÓN',
          style: TextStyle(
            fontFamily: 'PixelFont',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          key: _backButtonKey,
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(
                context,
              ).colorScheme.primary.withAlpha(51), // 0.2 * 255 ≈ 51
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: Column(
          children: [
            // Header con información del usuario actual
            if (_currentUser != null) _buildCurrentUserHeader(),

            // Lista del leaderboard
            Expanded(
              child: StreamBuilder<List<LeaderboardEntryModel>>(
                stream: _leaderboardService.getLeaderboardEntries(limit: 100),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: PixelCard(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Error al cargar la clasificación',
                              style: TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              snapshot.error.toString(),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final entries = snapshot.data ?? [];

                  if (entries.isEmpty) {
                    return Center(
                      child: PixelCard(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.leaderboard,
                              size: 48,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No hay datos de clasificación',
                              style: TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Sé el primero en aparecer en la tabla de clasificación',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    key: _leaderboardListKey,
                    padding: const EdgeInsets.all(16),
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      final isCurrentUser = _currentUser?.uid == entry.userId;
                      return _buildLeaderboardEntry(
                        entry,
                        index + 1,
                        isCurrentUser,
                        key: index == 0 ? _topPlayersKey : null,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: TutorialFloatingButton(
        tutorialSteps: TutorialService.getLeaderboardTutorial(
          userRankingKey: _userRankingKey,
          leaderboardListKey: _leaderboardListKey,
          timeFilterKey: _topPlayersKey,
          backButtonKey: _backButtonKey,
        ),
      ),
    );
  }

  Widget _buildCurrentUserHeader() {
    return Container(
      key: _userRankingKey,
      margin: const EdgeInsets.all(16),
      child: PixelCard(
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.person, size: 24, color: Colors.blue),
                const SizedBox(width: 12),
                const Text(
                  'Tu posición:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (_isLoadingRanking)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else if (_currentUserRanking != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getRankingColor(_currentUserRanking!),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                    child: Text(
                      '#$_currentUserRanking',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  const Text(
                    'No clasificado',
                    style: TextStyle(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardEntry(
    LeaderboardEntryModel entry,
    int position,
    bool isCurrentUser, {
    GlobalKey? key,
  }) {
    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 8),
      child: PixelCard(
        child: Container(
          decoration:
              isCurrentUser
                  ? BoxDecoration(
                    border: Border.all(color: Colors.blue, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  )
                  : null,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Posición
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getRankingColor(position),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: Center(
                  child: Text(
                    '$position',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Información del usuario
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        OverflowUtils.expandedText(
                          entry.username,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isCurrentUser ? Colors.blue : null,
                          ),
                          maxLines: 1,
                        ),
                        if (isCurrentUser)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'TÚ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Última actualización: ${_formatDate(entry.lastUpdated)}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),

              // Puntuación
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                    child: Text(
                      '${entry.score}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'puntos',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getRankingColor(int position) {
    switch (position) {
      case 1:
        return Colors.amber; // Oro
      case 2:
        return Colors.grey[400]!; // Plata
      case 3:
        return Colors.brown; // Bronce
      default:
        return Colors.blue; // Azul para el resto
    }
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Desconocido';

    try {
      DateTime date;
      if (timestamp is DateTime) {
        date = timestamp;
      } else {
        // Asumir que es un Timestamp de Firestore
        date = timestamp.toDate();
      }

      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return 'Hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
      } else if (difference.inHours > 0) {
        return 'Hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
      } else if (difference.inMinutes > 0) {
        return 'Hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
      } else {
        return 'Hace un momento';
      }
    } catch (e) {
      return 'Desconocido';
    }
  }
}
