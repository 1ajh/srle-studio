import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

/// Service for managing user preferences across all platforms
class PreferencesService extends ChangeNotifier {
  static PreferencesService? _instance;
  late SharedPreferences _prefs;

  // Settings keys
  static const String _keyOutputDirectory = 'output_directory';
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyAutoCheckUpdates = 'auto_check_updates';
  static const String _keyDefaultQuality = 'default_quality';
  static const String _keyShowDesktopOnlyEffects = 'show_desktop_only_effects';
  static const String _keyNotificationsEnabled = 'notifications_enabled';
  static const String _keyPreserveOriginalAudio = 'preserve_original_audio';
  static const String _keyRecentFiles = 'recent_files';
  static const String _keyFavoriteEffects = 'favorite_effects';
  static const String _keyProcessingHistory = 'processing_history';
  static const String _keyFirstLaunch = 'first_launch';

  // Default values
  String _outputDirectory = '';
  String _themeMode = 'dark';
  bool _autoCheckUpdates = true;
  String _defaultQuality = 'high';
  bool _showDesktopOnlyEffects = true;
  bool _notificationsEnabled = true;
  bool _preserveOriginalAudio = false;
  List<String> _recentFiles = [];
  List<String> _favoriteEffects = [];
  List<String> _processingHistory = [];
  bool _firstLaunch = true;

  // Getters
  String get outputDirectory => _outputDirectory;
  String get themeMode => _themeMode;
  bool get autoCheckUpdates => _autoCheckUpdates;
  String get defaultQuality => _defaultQuality;
  bool get showDesktopOnlyEffects => _showDesktopOnlyEffects;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get preserveOriginalAudio => _preserveOriginalAudio;
  List<String> get recentFiles => List.unmodifiable(_recentFiles);
  List<String> get favoriteEffects => List.unmodifiable(_favoriteEffects);
  List<String> get processingHistory => List.unmodifiable(_processingHistory);
  bool get firstLaunch => _firstLaunch;

  PreferencesService._();

  static Future<PreferencesService> getInstance() async {
    if (_instance == null) {
      _instance = PreferencesService._();
      await _instance!._init();
    }
    return _instance!;
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    _outputDirectory = _prefs.getString(_keyOutputDirectory) ?? await _getDefaultOutputDirectory();
    _themeMode = _prefs.getString(_keyThemeMode) ?? 'dark';
    _autoCheckUpdates = _prefs.getBool(_keyAutoCheckUpdates) ?? true;
    _defaultQuality = _prefs.getString(_keyDefaultQuality) ?? 'high';
    _showDesktopOnlyEffects = _prefs.getBool(_keyShowDesktopOnlyEffects) ?? true;
    _notificationsEnabled = _prefs.getBool(_keyNotificationsEnabled) ?? true;
    _preserveOriginalAudio = _prefs.getBool(_keyPreserveOriginalAudio) ?? false;
    _recentFiles = _prefs.getStringList(_keyRecentFiles) ?? [];
    _favoriteEffects = _prefs.getStringList(_keyFavoriteEffects) ?? [];
    _processingHistory = _prefs.getStringList(_keyProcessingHistory) ?? [];
    _firstLaunch = _prefs.getBool(_keyFirstLaunch) ?? true;
    notifyListeners();
  }

  Future<String> _getDefaultOutputDirectory() async {
    if (kIsWeb) {
      return 'Downloads';
    }
    
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        return 'VideoEffectsStudio';
      } else if (Platform.isWindows) {
        final home = Platform.environment['USERPROFILE'] ?? '';
        return '$home\\Videos\\VideoEffectsStudio';
      } else if (Platform.isMacOS) {
        final home = Platform.environment['HOME'] ?? '';
        return '$home/Movies/VideoEffectsStudio';
      } else if (Platform.isLinux) {
        final home = Platform.environment['HOME'] ?? '';
        return '$home/Videos/VideoEffectsStudio';
      }
    } catch (_) {}
    
    return 'VideoEffectsStudio';
  }

  // Setters with persistence
  Future<void> setOutputDirectory(String value) async {
    _outputDirectory = value;
    await _prefs.setString(_keyOutputDirectory, value);
    notifyListeners();
  }

  Future<void> setThemeMode(String value) async {
    _themeMode = value;
    await _prefs.setString(_keyThemeMode, value);
    notifyListeners();
  }

  Future<void> setAutoCheckUpdates(bool value) async {
    _autoCheckUpdates = value;
    await _prefs.setBool(_keyAutoCheckUpdates, value);
    notifyListeners();
  }

  Future<void> setDefaultQuality(String value) async {
    _defaultQuality = value;
    await _prefs.setString(_keyDefaultQuality, value);
    notifyListeners();
  }

  Future<void> setShowDesktopOnlyEffects(bool value) async {
    _showDesktopOnlyEffects = value;
    await _prefs.setBool(_keyShowDesktopOnlyEffects, value);
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    await _prefs.setBool(_keyNotificationsEnabled, value);
    notifyListeners();
  }

  Future<void> setPreserveOriginalAudio(bool value) async {
    _preserveOriginalAudio = value;
    await _prefs.setBool(_keyPreserveOriginalAudio, value);
    notifyListeners();
  }

  Future<void> setFirstLaunch(bool value) async {
    _firstLaunch = value;
    await _prefs.setBool(_keyFirstLaunch, value);
    notifyListeners();
  }

  // Recent files management
  Future<void> addRecentFile(String filePath) async {
    _recentFiles.remove(filePath); // Remove if exists
    _recentFiles.insert(0, filePath); // Add to start
    if (_recentFiles.length > 20) {
      _recentFiles = _recentFiles.sublist(0, 20); // Keep max 20
    }
    await _prefs.setStringList(_keyRecentFiles, _recentFiles);
    notifyListeners();
  }

  Future<void> removeRecentFile(String filePath) async {
    _recentFiles.remove(filePath);
    await _prefs.setStringList(_keyRecentFiles, _recentFiles);
    notifyListeners();
  }

  Future<void> clearRecentFiles() async {
    _recentFiles.clear();
    await _prefs.setStringList(_keyRecentFiles, []);
    notifyListeners();
  }

  // Favorite effects management
  Future<void> toggleFavoriteEffect(String effectId) async {
    if (_favoriteEffects.contains(effectId)) {
      _favoriteEffects.remove(effectId);
    } else {
      _favoriteEffects.add(effectId);
    }
    await _prefs.setStringList(_keyFavoriteEffects, _favoriteEffects);
    notifyListeners();
  }

  bool isEffectFavorite(String effectId) {
    return _favoriteEffects.contains(effectId);
  }

  // Processing history management
  Future<void> addToHistory(String entry) async {
    _processingHistory.insert(0, entry);
    if (_processingHistory.length > 100) {
      _processingHistory = _processingHistory.sublist(0, 100);
    }
    await _prefs.setStringList(_keyProcessingHistory, _processingHistory);
    notifyListeners();
  }

  Future<void> clearHistory() async {
    _processingHistory.clear();
    await _prefs.setStringList(_keyProcessingHistory, []);
    notifyListeners();
  }

  // Reset all settings
  Future<void> resetToDefaults() async {
    await _prefs.clear();
    await _loadPreferences();
  }
}

/// Quality preset options
class QualityPreset {
  static const String low = 'low';
  static const String medium = 'medium';
  static const String high = 'high';
  static const String ultra = 'ultra';

  static String getLabel(String quality) {
    switch (quality) {
      case low:
        return 'Low (480p)';
      case medium:
        return 'Medium (720p)';
      case high:
        return 'High (1080p)';
      case ultra:
        return 'Ultra (4K)';
      default:
        return 'High (1080p)';
    }
  }

  static String getFFmpegScale(String quality) {
    switch (quality) {
      case low:
        return '-vf scale=854:480';
      case medium:
        return '-vf scale=1280:720';
      case high:
        return '-vf scale=1920:1080';
      case ultra:
        return '-vf scale=3840:2160';
      default:
        return '';
    }
  }

  static List<String> get all => [low, medium, high, ultra];
}
