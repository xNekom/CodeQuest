// import 'package:audioplayers/audioplayers.dart'; // Comentado temporalmente
// import 'package:flutter/foundation.dart'; // Comentado temporalmente - no utilizado
import 'dart:async';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  // final AudioPlayer _backgroundPlayer = AudioPlayer(); // Comentado temporalmente
  // final AudioPlayer _effectPlayer = AudioPlayer(); // Comentado temporalmente
  
  bool _isBackgroundMusicEnabled = true;
  bool _areSoundEffectsEnabled = true;
  double _backgroundVolume = 0.5;
  double _effectVolume = 0.7;
  
  // Campos comentados temporalmente - funcionalidad de audio deshabilitada
  // String? _currentBackgroundTrack;
  // bool _isInitialized = false;
  // StreamSubscription<void>? _victoryCompleteSubscription;

  // Getters
  bool get isBackgroundMusicEnabled => _isBackgroundMusicEnabled;
  bool get areSoundEffectsEnabled => _areSoundEffectsEnabled;
  double get backgroundVolume => _backgroundVolume;
  double get effectVolume => _effectVolume;

  Future<void> initialize() async {
    // Comentado temporalmente - funcionalidad de audio deshabilitada
    /*
    if (_isInitialized) return;
    
    try {
      // Configurar el reproductor de fondo para loop
      await _backgroundPlayer.setReleaseMode(ReleaseMode.loop);
      await _backgroundPlayer.setVolume(_backgroundVolume);
      
      // Configurar el reproductor de efectos
      await _effectPlayer.setVolume(_effectVolume);
      
      _isInitialized = true;
      
      // Iniciar música de fondo principal
      await playMainTheme();
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing audio service: $e');
      }
    }
    */
  }

  Future<void> playMainTheme() async {
    // Comentado temporalmente - funcionalidad de audio deshabilitada
    /*
    if (!_isBackgroundMusicEnabled) return;
    
    try {
      await _backgroundPlayer.stop();
      await _backgroundPlayer.play(AssetSource('music/main_theme.mp3'));
      _currentBackgroundTrack = 'main_theme';
      
      if (kDebugMode) {
        print('Playing main theme');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error playing main theme: $e');
      }
    }
    */
  }

  Future<void> playBattleTheme() async {
    // Comentado temporalmente - funcionalidad de audio deshabilitada
    /*
    if (!_isBackgroundMusicEnabled || _currentBackgroundTrack == 'battle_theme') return;
    
    try {
      await _backgroundPlayer.stop();
      await _backgroundPlayer.play(AssetSource('music/battle_theme.mp3'));
      _currentBackgroundTrack = 'battle_theme';
      
      if (kDebugMode) {
        print('Playing battle theme');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error playing battle theme: $e');
      }
    }
    */
  }

  Future<void> playVictoryTheme() async {
    // Comentado temporalmente - funcionalidad de audio deshabilitada
    /*
    if (!_areSoundEffectsEnabled) return;
    
    try {
      // Cancelar suscripción anterior si existe
      await _victoryCompleteSubscription?.cancel();
      
      // Reproducir tema de victoria como efecto (no en loop)
      await _effectPlayer.stop();
      await _effectPlayer.play(AssetSource('music/victory_theme.mp3'));
      
      if (kDebugMode) {
        print('Playing victory theme');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error playing victory theme: $e');
      }
    }
    */
  }

  Future<void> playClickSound() async {
    // Comentado temporalmente - funcionalidad de audio deshabilitada
  }

  Future<void> playSuccessSound() async {
    // Comentado temporalmente - funcionalidad de audio deshabilitada
  }

  Future<void> playErrorSound() async {
    // Comentado temporalmente - funcionalidad de audio deshabilitada
  }

  Future<void> stopBackgroundMusic() async {
    // Comentado temporalmente - funcionalidad de audio deshabilitada
  }

  Future<void> stopAllAudio() async {
    // Comentado temporalmente - funcionalidad de audio deshabilitada
  }

  Future<void> setBackgroundMusicEnabled(bool enabled) async {
    _isBackgroundMusicEnabled = enabled;
    // Comentado temporalmente - funcionalidad de audio deshabilitada
  }

  Future<void> setSoundEffectsEnabled(bool enabled) async {
    _areSoundEffectsEnabled = enabled;
    // Comentado temporalmente - funcionalidad de audio deshabilitada
  }

  Future<void> setBackgroundVolume(double volume) async {
    _backgroundVolume = volume.clamp(0.0, 1.0);
    // Comentado temporalmente - funcionalidad de audio deshabilitada
  }

  Future<void> setEffectVolume(double volume) async {
    _effectVolume = volume.clamp(0.0, 1.0);
    // Comentado temporalmente - funcionalidad de audio deshabilitada
  }

  void pauseOnAppBackground() {
    // Comentado temporalmente - funcionalidad de audio deshabilitada
  }

  void resumeOnAppForeground() {
    // Comentado temporalmente - funcionalidad de audio deshabilitada
  }

  void dispose() {
    // Comentado temporalmente - funcionalidad de audio deshabilitada
  }
}