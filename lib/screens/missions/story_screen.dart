import 'package:flutter/material.dart';
import '../../models/story_page_model.dart';
// Assuming PixelButton is in pixel_widgets.dart
import '../../widgets/pixel_widgets.dart';
import '../../widgets/pixel_app_bar.dart'; 

class StoryScreen extends StatefulWidget {
  final List<StoryPageModel> storyPages;
  final String missionId; // To know which mission's theory is being completed

  const StoryScreen({
    super.key,
    required this.storyPages,
    required this.missionId,
  });

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  int _currentPageIndex = 0;

  void _nextPage() {
    if (_currentPageIndex < widget.storyPages.length - 1) {
      setState(() {
        _currentPageIndex++;
      });
    }
  }

  void _previousPage() {
    if (_currentPageIndex > 0) {
      setState(() {
        _currentPageIndex--;
      });
    }
  }

  void _finishTheory() {
    // TODO: Call UserService.markTheoryAsComplete(userId, widget.missionId)
    // TODO: Navigate to the next part of the mission (e.g., BattleScreen or details)
    if (Navigator.canPop(context)) {
      Navigator.pop(context); 
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.storyPages.isEmpty) {
      return Scaffold(
        appBar: const PixelAppBar(title: 'Teoría de la Misión'),
        body: const Center(child: Text('No hay páginas de historia disponibles.')),
      );
    }

    final currentPage = widget.storyPages[_currentPageIndex];
    final theme = Theme.of(context);

    return Scaffold(
      appBar: PixelAppBar(
        title: 'Teoría: Página ${_currentPageIndex + 1}/${widget.storyPages.length}',
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        titleFontSize: 12,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (currentPage.imageUrl != null && currentPage.imageUrl!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        // Placeholder for image - actual image loading will depend on asset location
                        child: Image.asset(
                          currentPage.imageUrl!,
                          fit: BoxFit.contain,
                          height: 200, // Example height
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.image_not_supported, size: 100, color: Colors.grey);
                          },
                        ),
                      ),
                    Text(
                      currentPage.text,
                      style: theme.textTheme.bodyLarge?.copyWith(height: 1.5), // Increased line height
                      textAlign: TextAlign.justify,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentPageIndex > 0)
                  PixelButton(
                    onPressed: _previousPage,
                    isSmall: true,
                    child: const Text('Anterior'),
                  )
                else
                  const SizedBox.shrink(), // Keep space consistent
                
                Text('${_currentPageIndex + 1} / ${widget.storyPages.length}'),

                if (_currentPageIndex < widget.storyPages.length - 1)
                  PixelButton(
                    onPressed: _nextPage,
                    isSmall: true,
                    child: const Text('Siguiente'),
                  )
                else
                  PixelButton(
                    onPressed: _finishTheory,
                    color: theme.colorScheme.secondary,
                    isSmall: true, // Use a different color for emphasis
                    child: Text('Finalizar Teoría', style: TextStyle(color: theme.colorScheme.onSecondary)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
