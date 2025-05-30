import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/mission_model.dart';
import '../../models/story_page_model.dart';
import '../../services/user_service.dart';
import '../../services/mission_service.dart';
import '../../utils/overflow_utils.dart';
import '../../widgets/pixel_widgets.dart';
import '../../theme/pixel_theme.dart';
import 'story_screen.dart';
import 'question_screen.dart';

class TheoryScreen extends StatefulWidget {
  final String missionId;
  final String? theoryText;
  final List<String>? examples;
  final List<StoryPageModel>? storyPages;
  final bool isReplay;

  const TheoryScreen({
    super.key,
    required this.missionId,
    this.theoryText,
    this.examples,
    this.storyPages,
    this.isReplay = false,
  });

  @override
  State<TheoryScreen> createState() => _TheoryScreenState();
}

class _TheoryScreenState extends State<TheoryScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _showTechnicalExplanation = false;
  MissionModel? mission;
  int get _totalPages =>
      (widget.storyPages?.length ?? 0) +
      (widget.theoryText != null ? 1 : 0) +
      (widget.examples?.isNotEmpty == true ? 1 : 0);

  @override
  void initState() {
    super.initState();
    _loadMission();
  }

  Future<void> _loadMission() async {
    try {
      final loadedMission = await MissionService().getMissionById(
        widget.missionId,
      );
      if (mounted) {
        setState(() {
          mission = loadedMission;
        });
      }
    } catch (e) {
      print('Error loading mission: $e');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (!mounted || !_pageController.hasClients) return;

    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishTheory();
    }
  }

  void _previousPage() {
    if (!mounted || !_pageController.hasClients) return;

    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _finishTheory() async {
    if (!mounted) return;

    if (!widget.isReplay) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && mounted) {
        try {
          await UserService()
              .markTheoryAsComplete(user.uid, widget.missionId)
              .timeout(const Duration(seconds: 10));
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error al completar teoría: $e')),
            );
          }
          return; // No navegar si hay error
        }
      }
    }

    // Navegar directamente a los ejercicios
    await _navigateToExercises();
  }

  Future<void> _navigateToExercises() async {
    if (!mounted) return;

    try {
      // Obtener la misión para acceder a sus objetivos
      final mission = await MissionService().getMissionById(widget.missionId);
      if (mission == null || !mounted) return;

      // Buscar el primer objetivo de tipo 'questions'
      final questionObjective = mission.objectives.firstWhere(
        (obj) => obj.type == 'questions',
        orElse: () => mission.objectives.first,
      );

      if (questionObjective.type == 'questions' &&
          questionObjective.questionIds.isNotEmpty) {
        // Navegar a la pantalla de preguntas
        final result = await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => QuestionScreen(
                  missionId: widget.missionId,
                  isReplay: widget.isReplay,
                ),
          ),
        );

        // Si se completaron los ejercicios, retornar el resultado
        if (mounted && Navigator.canPop(context)) {
          Navigator.pop(context, result);
        }
      } else {
        // Si no hay ejercicios, simplemente retornar true
        if (mounted && Navigator.canPop(context)) {
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar ejercicios: $e')),
        );
        // En caso de error, retornar a la pantalla anterior
        if (Navigator.canPop(context)) {
          Navigator.pop(context, false);
        }
      }
    }
  }

  Widget _buildTheoryPage() {
    if (widget.theoryText == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OverflowUtils.safeRow(
            children: [
              Icon(Icons.school, color: Colors.purple[700], size: 28),
              const SizedBox(width: 12),
              Flexible(
                child: OverflowUtils.safeText(
                  'Teoría de la Misión',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[700],
                  ),
                  maxLines: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Botones para alternar entre explicación narrativa y técnica
          if (mission?.technicalExplanation != null) ...[
            OverflowUtils.safeRow(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showTechnicalExplanation = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          !_showTechnicalExplanation
                              ? Colors.purple[700]
                              : Colors.grey[400],
                      foregroundColor: Colors.white,
                    ),
                    child: OverflowUtils.safeText(
                      'Explicación Narrativa',
                      maxLines: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showTechnicalExplanation = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _showTechnicalExplanation
                              ? Colors.purple[700]
                              : Colors.grey[400],
                      foregroundColor: Colors.white,
                    ),
                    child: OverflowUtils.safeText(
                      'Explicación Técnica',
                      maxLines: 1,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.purple[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.purple[300]!),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return RawScrollbar(
                    thumbVisibility: true,
                    thickness: 12,
                    radius: const Radius.circular(0), // Bordes cuadrados para estilo retro
                    thumbColor: PixelTheme.primaryColor,
                    trackColor: PixelTheme.primaryColor.withOpacity(0.2),
                    trackBorderColor: PixelTheme.primaryColor.withOpacity(0.4),
                    trackRadius: const Radius.circular(0),
                    crossAxisMargin: 2,
                    mainAxisMargin: 4,
                    child: SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 16), // Margen para la scrollbar
                          child: Text(
                            _showTechnicalExplanation &&
                                    mission?.technicalExplanation != null
                                ? mission!.technicalExplanation!
                                : widget.theoryText!,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(height: 1.6, fontSize: 14), // Reducido de 16 a 14
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExamplesPage() {
    if (widget.examples?.isEmpty != false) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OverflowUtils.safeRow(
            children: [
              Icon(Icons.code, color: Colors.blue[700], size: 28),
              const SizedBox(width: 12),
              Flexible(
                child: OverflowUtils.safeText(
                  'Ejemplos de Código',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                  maxLines: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: RawScrollbar(
              thumbVisibility: true,
              thickness: 12,
              radius: const Radius.circular(0), // Bordes cuadrados para estilo retro
              thumbColor: PixelTheme.primaryColor,
              trackColor: PixelTheme.primaryColor.withOpacity(0.2),
              trackBorderColor: PixelTheme.primaryColor.withOpacity(0.4),
              trackRadius: const Radius.circular(0),
              crossAxisMargin: 2,
              mainAxisMargin: 4,
              child: ListView.builder(
                itemCount: widget.examples!.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16, right: 16), // Margen derecho para la scrollbar
                    padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[700]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ejemplo ${index + 1}:',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.green[400],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.examples![index],
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          color: Colors.white,
                          fontSize: 12, // Reducido de 14 a 12
                        ),
                      ),
                    ],
                  ),
                );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryPage(StoryPageModel storyPage) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Text(
              'Página ${storyPage.pageNumber}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.purple[700],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.purple[25],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.purple[200]!),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return RawScrollbar(
                    thumbVisibility: true,
                    thickness: 12,
                    radius: const Radius.circular(0), // Bordes cuadrados para estilo retro
                    thumbColor: PixelTheme.primaryColor,
                    trackColor: PixelTheme.primaryColor.withOpacity(0.2),
                    trackBorderColor: PixelTheme.primaryColor.withOpacity(0.4),
                    trackRadius: const Radius.circular(0),
                    crossAxisMargin: 2,
                    mainAxisMargin: 4,
                    child: SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 16), // Margen para la scrollbar
                          child: Text(
                            storyPage.text,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(height: 1.6, fontSize: 14), // Reducido de 16 a 14
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          if (storyPage.imageUrl?.isNotEmpty == true) ...[
            const SizedBox(height: 16),
            Center(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 200),
                child: Image.network(
                  storyPage.imageUrl!,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.image_not_supported),
                    );
                  },
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Si solo hay storyPages, usar StoryScreen directamente
    if (widget.storyPages?.isNotEmpty == true &&
        widget.theoryText == null &&
        (widget.examples?.isEmpty ?? true)) {
      return StoryScreen(
        storyPages: widget.storyPages!,
        missionId: widget.missionId,
      );
    }

    // Si no hay contenido, mostrar mensaje
    if (_totalPages == 0) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Teoría'),
          backgroundColor: Colors.purple[700],
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text(
            'No hay contenido de teoría disponible para esta misión.',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teoría'),
        backgroundColor: Colors.purple[700],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Indicador de progreso
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                OverflowUtils.safeRow(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: OverflowUtils.safeText(
                        'Página ${_currentPage + 1} de $_totalPages',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value:
                      _totalPages > 0 ? (_currentPage + 1) / _totalPages : 0.0,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.purple[700]!,
                  ),
                ),
              ],
            ),
          ),
          // Contenido de las páginas
          Expanded(
            child:
                _totalPages > 0
                    ? PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        if (mounted) {
                          setState(() {
                            _currentPage = index;
                          });
                        }
                      },
                      children: [
                        // Páginas de historia
                        if (widget.storyPages?.isNotEmpty == true)
                          ...widget.storyPages!.map(
                            (page) => _buildStoryPage(page),
                          ),
                        // Página de teoría
                        if (widget.theoryText != null) _buildTheoryPage(),
                        // Página de ejemplos
                        if (widget.examples?.isNotEmpty == true)
                          _buildExamplesPage(),
                      ],
                    )
                    : const Center(
                      child: Text(
                        'No hay contenido disponible.',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
          ),
          // Botones de navegación
          if (_totalPages > 0)
            Container(
              padding: const EdgeInsets.all(16),
              child: OverflowUtils.safeRow(
                children: [
                  if (_currentPage > 0)
                    Flexible(
                      child: PixelButton(
                        onPressed: _previousPage,
                        child: OverflowUtils.safeText('Anterior', maxLines: 1),
                      ),
                    ),
                  const Expanded(child: SizedBox()),
                  Flexible(
                    child: PixelButton(
                      onPressed: _nextPage,
                      child: OverflowUtils.safeText(
                        _currentPage < _totalPages - 1
                            ? 'Siguiente'
                            : 'Finalizar',
                        maxLines: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
