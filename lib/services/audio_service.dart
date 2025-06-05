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
  bool _isAppInBackground = false;

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
      
      // Iniciar música de fondo principal
      await playMainTheme();
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing audio service: $e');
      }
    }
  }

  Future<void> playMainTheme() async {
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
  }

  Future<void> playBattleTheme() async {
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
        print('Playing victory theme');
      }
      
      // Escuchar cuando termine el tema de victoria
      _victoryCompleteSubscription = _effectPlayer.onPlayerComplete.listen((event) {
        if (kDebugMode) {
          print('Victory theme completed, returning to main theme');
        }
        // Cuando termine el tema de victoria, volver al tema principal
        playMainTheme();
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error playing victory theme: $e');
      }
    }
  }

  Future<void> setBackgroundMusicEnabled(bool enabled) async {
    _isBackgroundMusicEnabled = enabled;
    
    if (!enabled) {
      await _backgroundPlayer.stop();
      _currentBackgroundTrack = null;
    } else {
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
    await _backgroundPlayer.setVolume(_backgroundVolume);
  }

  Future<void> setEffectVolume(double volume) async {
    _effectVolume = volume.clamp(0.0, 1.0);
    await _effectPlayer.setVolume(_effectVolume);
  }

  Future<void> pauseBackgroundMusic() async {
    await _backgroundPlayer.pause();
  }

  Future<void> resumeBackgroundMusic() async {
    if (_isBackgroundMusicEnabled) {
      await _backgroundPlayer.resume();
    }
  }

  Future<void> stopAllAudio() async {
    await _backgroundPlayer.stop();
    await _effectPlayer.stop();
    _currentBackgroundTrack = null;
  }

  // Métodos para manejar el ciclo de vida de la app
  Future<void> pauseOnAppBackground() async {
    if (_isAppInBackground) return;
    
    _isAppInBackground = true;
    await _backgroundPlayer.pause();
    await _effectPlayer.pause();
    
    if (kDebugMode) {
      print('Audio paused - app in background');
    }
  }
  
  Future<void> resumeOnAppForeground() async {
    if (!_isAppInBackground) return;
    
    _isAppInBackground = false;
    
    if (_isBackgroundMusicEnabled) {
      await _backgroundPlayer.resume();
    }
    
    if (_areSoundEffectsEnabled) {
      await _effectPlayer.resume();
    }
    
    if (kDebugMode) {
      print('Audio resumed - app in foreground');
    }
  }

  void dispose() {
    _victoryCompleteSubscription?.cancel();
    _backgroundPlayer.dispose();
    _effectPlayer.dispose();
  }
}