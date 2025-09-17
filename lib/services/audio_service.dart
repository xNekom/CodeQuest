import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _backgroundPlayer = AudioPlayer();
  final AudioPlayer _effectPlayer = AudioPlayer();

  bool _isBackgroundMusicEnabled = true;
  bool _areSoundEffectsEnabled = true;
  double _backgroundVolume = 0.5;
  double _effectVolume = 0.7;

  String? _currentBackgroundTrack;
  bool _isInitialized = false;
  StreamSubscription<void>? _victoryCompleteSubscription;

  // Getters
  bool get isBackgroundMusicEnabled => _isBackgroundMusicEnabled;
  bool get areSoundEffectsEnabled => _areSoundEffectsEnabled;
  double get backgroundVolume => _backgroundVolume;
  double get effectVolume => _effectVolume;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Configurar el reproductor de fondo para loop
      await _backgroundPlayer.setReleaseMode(ReleaseMode.loop);
      await _backgroundPlayer.setVolume(_backgroundVolume);

      // Configurar el reproductor de efectos
      await _effectPlayer.setVolume(_effectVolume);

      _isInitialized = true;

      // No reproducir automáticamente, esperar interacción del usuario
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error initializing audio service: $e');
      }
    }
  }

  Future<void> playMainTheme() async {
    if (!_isBackgroundMusicEnabled) return;

    try {
      await _backgroundPlayer.stop();
      await _backgroundPlayer.setReleaseMode(ReleaseMode.loop);
      await _backgroundPlayer.play(AssetSource('music/main_theme.mp3'));
      _currentBackgroundTrack = 'main_theme';

      if (kDebugMode) {
        debugPrint('Playing main theme in loop');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error playing main theme: $e');
      }
    }
  }

  Future<void> playBackgroundMusicWithUserInteraction() async {
    // Este método se llama después de una interacción del usuario
    // para cumplir con las políticas de autoplay del navegador
    if (!_isBackgroundMusicEnabled) return;

    try {
      await playMainTheme();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error playing background music after user interaction: $e');
      }
    }
  }

  Future<void> playBattleTheme() async {
    if (!_isBackgroundMusicEnabled || _currentBackgroundTrack == 'battle_theme') {
      return;
    }

    try {
      await _backgroundPlayer.stop();
      await _backgroundPlayer.setReleaseMode(ReleaseMode.loop);
      await _backgroundPlayer.play(AssetSource('music/battle_theme.mp3'));
      _currentBackgroundTrack = 'battle_theme';

      if (kDebugMode) {
        debugPrint('Playing battle theme in loop');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error playing battle theme: $e');
      }
    }
  }

  Future<void> playVictoryTheme() async {
    if (!_areSoundEffectsEnabled) return;

    try {
      // Cancelar suscripción anterior si existe
      await _victoryCompleteSubscription?.cancel();

      // Reproducir tema de victoria como efecto (no en loop)
      await _effectPlayer.stop();
      await _effectPlayer.play(AssetSource('music/victory_theme.mp3'));

      if (kDebugMode) {
        debugPrint('Playing victory theme');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error playing victory theme: $e');
      }
    }
  }

  Future<void> playClickSound() async {
    if (!_areSoundEffectsEnabled) return;

    try {
      await _effectPlayer.play(AssetSource('music/tap_sound.mp3'));

      if (kDebugMode) {
        debugPrint('Playing click sound');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error playing click sound: $e');
      }
    }
  }

  Future<void> playSuccessSound() async {
    if (!_areSoundEffectsEnabled) return;

    try {
      await _effectPlayer.play(AssetSource('music/tap_sound.mp3'));

      if (kDebugMode) {
        debugPrint('Playing success sound');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error playing success sound: $e');
      }
    }
  }

  Future<void> playErrorSound() async {
    if (!_areSoundEffectsEnabled) return;

    try {
      await _effectPlayer.play(AssetSource('music/tap_sound.mp3'));

      if (kDebugMode) {
        debugPrint('Playing error sound');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error playing error sound: $e');
      }
    }
  }

  Future<void> stopBackgroundMusic() async {
    try {
      await _backgroundPlayer.stop();
      _currentBackgroundTrack = null;

      if (kDebugMode) {
        debugPrint('Background music stopped');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error stopping background music: $e');
      }
    }
  }

  Future<void> stopAllAudio() async {
    try {
      await _backgroundPlayer.stop();
      await _effectPlayer.stop();
      await _victoryCompleteSubscription?.cancel();
      _currentBackgroundTrack = null;

      if (kDebugMode) {
        debugPrint('All audio stopped');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error stopping all audio: $e');
      }
    }
  }

  Future<void> setBackgroundMusicEnabled(bool enabled) async {
    _isBackgroundMusicEnabled = enabled;

    if (!enabled) {
      await stopBackgroundMusic();
    } else if (_isInitialized) {
      await playMainTheme();
    }
  }

  Future<void> setSoundEffectsEnabled(bool enabled) async {
    _areSoundEffectsEnabled = enabled;

    if (!enabled) {
      await _effectPlayer.stop();
    }
  }

  Future<void> setBackgroundVolume(double volume) async {
    _backgroundVolume = volume.clamp(0.0, 1.0);

    try {
      await _backgroundPlayer.setVolume(_backgroundVolume);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error setting background volume: $e');
      }
    }
  }

  Future<void> setEffectVolume(double volume) async {
    _effectVolume = volume.clamp(0.0, 1.0);

    try {
      await _effectPlayer.setVolume(_effectVolume);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error setting effect volume: $e');
      }
    }
  }

  void pauseOnAppBackground() {
    try {
      _backgroundPlayer.pause();
      _effectPlayer.pause();

      if (kDebugMode) {
        debugPrint('Audio paused on app background');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error pausing audio on app background: $e');
      }
    }
  }

  void resumeOnAppForeground() {
    try {
      if (_isBackgroundMusicEnabled && _currentBackgroundTrack != null) {
        _backgroundPlayer.resume();
      }

      if (kDebugMode) {
        debugPrint('Audio resumed on app foreground');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error resuming audio on app foreground: $e');
      }
    }
  }

  void dispose() {
    try {
      _victoryCompleteSubscription?.cancel();
      _backgroundPlayer.dispose();
      _effectPlayer.dispose();

      if (kDebugMode) {
        debugPrint('Audio service disposed');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error disposing audio service: $e');
      }
    }
  }
}
