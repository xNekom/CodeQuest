import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:codequest/services/tutorial_service.dart';
import 'package:codequest/widgets/interactive_tutorial.dart';
import 'package:codequest/widgets/tutorial_manager.dart';
import 'package:codequest/widgets/tutorial_floating_button.dart';

void main() {
  group('Tutorial System Tests', () {
    setUp(() {
      // Limpiar SharedPreferences antes de cada test
      SharedPreferences.setMockInitialValues({});
    });

    group('TutorialService Tests', () {
      test('should mark tutorial as completed', () async {
        final tutorialService = TutorialService();
        const tutorialKey = 'test_tutorial';

        // Verificar que inicialmente no está completado
        bool isCompleted = await tutorialService.isTutorialCompleted(
          tutorialKey,
        );
        expect(isCompleted, false);

        // Marcar como completado
        await tutorialService.markTutorialCompleted(tutorialKey);

        // Verificar que ahora está completado
        isCompleted = await tutorialService.isTutorialCompleted(tutorialKey);
        expect(isCompleted, true);
      });

      test('should reset all tutorials', () async {
        final tutorialService =
            TutorialService(); // Marcar algunos tutoriales como completados
        await tutorialService.markTutorialCompleted(
          TutorialService.homeScreenTutorial,
        );
        await tutorialService.markTutorialCompleted(
          TutorialService.missionScreenTutorial,
        );

        // Verificar que están completados
        expect(
          await tutorialService.isTutorialCompleted(
            TutorialService.homeScreenTutorial,
          ),
          true,
        );
        expect(
          await tutorialService.isTutorialCompleted(
            TutorialService.missionScreenTutorial,
          ),
          true,
        ); // Resetear todos
        await tutorialService.resetAllTutorials();

        // Verificar que ya no están completados
        expect(
          await tutorialService.isTutorialCompleted(
            TutorialService.homeScreenTutorial,
          ),
          false,
        );
        expect(
          await tutorialService.isTutorialCompleted(
            TutorialService.missionScreenTutorial,
          ),
          false,
        );
      });

      test('should return correct tutorial steps for home screen', () {
        final steps = TutorialService.getHomeScreenTutorial();
        expect(steps, isNotEmpty);
        expect(steps.first.title, contains('Bienvenido'));
        expect(steps.last.title, contains('Listo'));
      });

      // Character selection tutorial was removed - test removed
      test('should return correct tutorial steps for missions', () {
        final steps = TutorialService.getMissionScreenTutorial();
        expect(steps, isNotEmpty);
        expect(steps.first.title, contains('Bienvenido a las Misiones'));
      });
      test('should return correct tutorial steps for achievements', () {
        final steps = TutorialService.getAchievementsTutorial();
        expect(steps, isNotEmpty);
        expect(steps.first.title, contains('Galería de Logros'));
      });
    });

    group('InteractiveTutorialStep Tests', () {
      test('should create tutorial step with required properties', () {
        const step = InteractiveTutorialStep(
          title: 'Test Title',
          description: 'Test Description',
          icon: Icons.help,
        );

        expect(step.title, 'Test Title');
        expect(step.description, 'Test Description');
        expect(step.icon, Icons.help);
        expect(step.showPulse, false); // default value
        expect(step.targetKey, null); // default value
      });

      test('should create tutorial step with custom properties', () {
        const step = InteractiveTutorialStep(
          title: 'Custom Title',
          description: 'Custom Description',
          icon: Icons.star,
          showPulse: true,
        );

        expect(step.title, 'Custom Title');
        expect(step.description, 'Custom Description');
        expect(step.icon, Icons.star);
        expect(step.showPulse, true);
      });
    });

    group('Widget Tests', () {
      testWidgets('TutorialFloatingButton should render correctly', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(home: Scaffold(body: const TutorialFloatingButton())),
        );

        // Verificar que el botón se renderiza
        expect(find.byType(FloatingActionButton), findsOneWidget);
        expect(find.byIcon(Icons.help_outline), findsOneWidget);
      });

      testWidgets('TutorialFloatingButton menu should expand on tap', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(home: Scaffold(body: const TutorialFloatingButton())),
        );

        // Tocar el botón
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        // Verificar que el menú se expande (deberían aparecer más botones)
        expect(find.byType(FloatingActionButton), findsWidgets);
      });

      testWidgets('TutorialManager should render child widget', (
        WidgetTester tester,
      ) async {
        const testWidget = Text('Test Child');
        const tutorialKey = 'test_key';
        const tutorialSteps = <InteractiveTutorialStep>[
          InteractiveTutorialStep(
            title: 'Test',
            description: 'Test description',
            icon: Icons.help,
          ),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: TutorialManager(
              tutorialKey: tutorialKey,
              tutorialSteps: tutorialSteps,
              autoStart: false, // No iniciar automáticamente en tests
              child: testWidget,
            ),
          ),
        );

        // Verificar que el widget hijo se renderiza
        expect(find.text('Test Child'), findsOneWidget);
      });

      testWidgets('InteractiveTutorial should show tutorial steps', (
        WidgetTester tester,
      ) async {
        const tutorialSteps = <InteractiveTutorialStep>[
          InteractiveTutorialStep(
            title: 'Step 1',
            description: 'First step description',
            icon: Icons.looks_one,
          ),
          InteractiveTutorialStep(
            title: 'Step 2',
            description: 'Second step description',
            icon: Icons.looks_two,
          ),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: InteractiveTutorial(
                steps: tutorialSteps,
                autoStart: true,
                child: const SizedBox.shrink(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verificar que aparece el primer paso
        expect(find.text('Step 1'), findsOneWidget);
        expect(find.text('First step description'), findsOneWidget);
      });
    });

    group('Integration Tests', () {
      testWidgets('Complete tutorial flow should work', (
        WidgetTester tester,
      ) async {
        // Mock SharedPreferences
        SharedPreferences.setMockInitialValues({});

        const tutorialKey = 'integration_test';
        const tutorialSteps = <InteractiveTutorialStep>[
          InteractiveTutorialStep(
            title: 'Integration Test',
            description: 'Test description',
            icon: Icons.integration_instructions,
          ),
        ];

        bool tutorialCompleted = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TutorialManager(
                tutorialKey: tutorialKey,
                tutorialSteps: tutorialSteps,
                autoStart: false,
                onTutorialCompleted: () {
                  tutorialCompleted = true;
                },
                child: const Text('Main Content'),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verificar estado inicial
        expect(find.text('Main Content'), findsOneWidget);
        expect(tutorialCompleted, false);

        // El tutorial no debe aparecer automáticamente porque autoStart es false
        expect(find.text('Integration Test'), findsNothing);
      });

      test('Tutorial service constants should be accessible', () {
        expect(TutorialService.homeScreenTutorial, isNotEmpty);
        expect(TutorialService.missionScreenTutorial, isNotEmpty);
        expect(TutorialService.achievementScreenTutorial, isNotEmpty);
        expect(TutorialService.missionDetailTutorial, isNotEmpty);
        expect(TutorialService.welcomeTutorial, isNotEmpty);
        expect(TutorialService.theoryScreenTutorial, isNotEmpty);
      });
    });

    group('Error Handling Tests', () {
      test('should handle invalid tutorial keys gracefully', () async {
        final tutorialService = TutorialService();

        // Probar con clave vacía
        bool isCompleted = await tutorialService.isTutorialCompleted('');
        expect(isCompleted, false);

        // Probar marcar clave vacía como completada
        await tutorialService.markTutorialCompleted('');
        isCompleted = await tutorialService.isTutorialCompleted('');
        expect(isCompleted, true);
      });

      testWidgets('should handle empty tutorial steps', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: InteractiveTutorial(
                steps: const [], // Lista vacía
                autoStart: true,
                child: const Text('Content'),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Debería mostrar solo el contenido, sin errores
        expect(find.text('Content'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });

    group('Performance Tests', () {
      test('should handle multiple rapid tutorial state changes', () async {
        final tutorialService = TutorialService();
        const tutorialKey = 'performance_test';

        // Cambiar estado múltiples veces rápidamente
        for (int i = 0; i < 100; i++) {
          await tutorialService.markTutorialCompleted('${tutorialKey}_$i');
        }

        // Verificar que todos fueron marcados
        for (int i = 0; i < 100; i++) {
          bool isCompleted = await tutorialService.isTutorialCompleted(
            '${tutorialKey}_$i',
          );
          expect(isCompleted, true);
        }
      });
    });
  });
}
