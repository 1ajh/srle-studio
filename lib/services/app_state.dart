import 'package:flutter/foundation.dart';
import '../models/effect_mode.dart';
import '../models/effects_registry.dart';
import '../services/ffmpeg_service.dart';
import '../services/update_service.dart';

/// Main application state provider
class AppState extends ChangeNotifier {
  // Selected files
  List<String> _selectedFiles = [];
  List<String> get selectedFiles => _selectedFiles;

  // Selected effect
  EffectMode? _selectedEffect;
  EffectMode? get selectedEffect => _selectedEffect;

  // Effect parameters
  Map<String, dynamic> _effectParameters = {};
  Map<String, dynamic> get effectParameters => _effectParameters;

  // Processing state
  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  double _processingProgress = 0.0;
  double get processingProgress => _processingProgress;

  String _processingStatus = '';
  String get processingStatus => _processingStatus;

  // Results
  List<ProcessResult> _results = [];
  List<ProcessResult> get results => _results;

  // Update info
  UpdateInfo? _updateInfo;
  UpdateInfo? get updateInfo => _updateInfo;

  // Filter
  String _categoryFilter = '';
  String get categoryFilter => _categoryFilter;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  /// Get filtered effects list
  List<EffectMode> get filteredEffects {
    var effects = EffectsRegistry.allEffects;

    if (_categoryFilter.isNotEmpty) {
      effects = effects.where((e) => e.category == _categoryFilter).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      effects = effects.where((e) =>
        e.name.toLowerCase().contains(query) ||
        e.description.toLowerCase().contains(query)
      ).toList();
    }

    return effects;
  }

  /// Get all categories
  List<String> get categories => EffectsRegistry.categories;

  /// Set selected files
  void setSelectedFiles(List<String> files) {
    _selectedFiles = files;
    notifyListeners();
  }

  /// Add files to selection
  void addFiles(List<String> files) {
    _selectedFiles.addAll(files);
    notifyListeners();
  }

  /// Remove file from selection
  void removeFile(String file) {
    _selectedFiles.remove(file);
    notifyListeners();
  }

  /// Clear all selected files
  void clearFiles() {
    _selectedFiles.clear();
    notifyListeners();
  }

  /// Select an effect
  void selectEffect(EffectMode? effect) {
    _selectedEffect = effect;
    _effectParameters = {};
    
    // Initialize default parameter values
    if (effect != null) {
      for (final param in effect.parameters) {
        _effectParameters[param.id] = param.defaultValue;
      }
    }
    
    notifyListeners();
  }

  /// Update effect parameter
  void setParameter(String id, dynamic value) {
    _effectParameters[id] = value;
    notifyListeners();
  }

  /// Set category filter
  void setCategoryFilter(String category) {
    _categoryFilter = category;
    notifyListeners();
  }

  /// Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Start processing
  Future<void> startProcessing() async {
    if (_selectedFiles.isEmpty || _selectedEffect == null) return;

    _isProcessing = true;
    _processingProgress = 0.0;
    _results.clear();
    notifyListeners();

    if (_selectedFiles.length == 1) {
      // Single file processing
      _processingStatus = 'Processing ${_selectedFiles.first.split('/').last}...';
      notifyListeners();

      final result = await FFmpegService.processVideo(
        inputPath: _selectedFiles.first,
        effect: _selectedEffect!,
        parameters: _effectParameters,
        onProgress: (progress) {
          _processingProgress = progress;
          notifyListeners();
        },
      );

      _results.add(result);
    } else {
      // Batch processing
      await for (final update in FFmpegService.processBatch(
        inputPaths: _selectedFiles,
        effect: _selectedEffect!,
        parameters: _effectParameters,
      )) {
        _processingStatus = 'Processing ${update.currentIndex + 1}/${update.totalCount}: ${update.currentFileName}';
        _processingProgress = update.overallProgress;
        _results = update.results;
        notifyListeners();
      }
    }

    _isProcessing = false;
    _processingStatus = 'Complete';
    _processingProgress = 1.0;
    notifyListeners();
  }

  /// Cancel processing
  Future<void> cancelProcessing() async {
    await FFmpegService.cancelAll();
    _isProcessing = false;
    _processingStatus = 'Cancelled';
    notifyListeners();
  }

  /// Clear results
  void clearResults() {
    _results.clear();
    notifyListeners();
  }

  /// Check for updates
  Future<void> checkForUpdates({bool force = false}) async {
    _updateInfo = await UpdateService.checkForUpdates(force: force);
    notifyListeners();
  }

  /// Dismiss update notification
  void dismissUpdate() {
    _updateInfo = null;
    notifyListeners();
  }
}
