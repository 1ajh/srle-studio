import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for checking and handling app updates from GitHub
class UpdateService {
  static const String _githubOwner = '1ajh'; // Change to your GitHub username
  static const String _githubRepo = 'video-effects-studio';
  static const String _lastCheckKey = 'last_update_check';
  static const Duration _checkInterval = Duration(hours: 6);

  /// Check for updates from GitHub releases
  static Future<UpdateInfo?> checkForUpdates({bool force = false}) async {
    try {
      // Check if we should skip this check (unless forced)
      if (!force) {
        final prefs = await SharedPreferences.getInstance();
        final lastCheck = prefs.getInt(_lastCheckKey) ?? 0;
        final now = DateTime.now().millisecondsSinceEpoch;
        
        if (now - lastCheck < _checkInterval.inMilliseconds) {
          return null; // Too soon to check again
        }
        
        await prefs.setInt(_lastCheckKey, now);
      }

      // Get current app version
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      // Fetch latest release from GitHub
      final response = await http.get(
        Uri.parse('https://api.github.com/repos/$_githubOwner/$_githubRepo/releases/latest'),
        headers: {'Accept': 'application/vnd.github.v3+json'},
      );

      if (response.statusCode != 200) {
        return null;
      }

      final data = jsonDecode(response.body);
      final latestVersion = (data['tag_name'] as String).replaceFirst('v', '');
      final releaseNotes = data['body'] as String? ?? '';
      final releaseUrl = data['html_url'] as String;
      final assets = data['assets'] as List<dynamic>;

      // Compare versions
      if (_isNewerVersion(latestVersion, currentVersion)) {
        // Find appropriate download asset for current platform
        String? downloadUrl;
        
        if (Platform.isWindows) {
          downloadUrl = _findAssetUrl(assets, ['.exe', '.msix', '-windows']);
        } else if (Platform.isMacOS) {
          downloadUrl = _findAssetUrl(assets, ['.dmg', '.pkg', '-macos', '-darwin']);
        } else if (Platform.isLinux) {
          downloadUrl = _findAssetUrl(assets, ['.AppImage', '.deb', '.rpm', '-linux']);
        } else if (Platform.isAndroid) {
          downloadUrl = _findAssetUrl(assets, ['.apk']);
        } else if (Platform.isIOS) {
          // iOS updates go through App Store
          downloadUrl = releaseUrl;
        }

        return UpdateInfo(
          currentVersion: currentVersion,
          latestVersion: latestVersion,
          releaseNotes: releaseNotes,
          releaseUrl: releaseUrl,
          downloadUrl: downloadUrl ?? releaseUrl,
          isUpdateAvailable: true,
        );
      }

      return UpdateInfo(
        currentVersion: currentVersion,
        latestVersion: latestVersion,
        releaseNotes: releaseNotes,
        releaseUrl: releaseUrl,
        downloadUrl: releaseUrl,
        isUpdateAvailable: false,
      );
    } catch (e) {
      print('Update check failed: $e');
      return null;
    }
  }

  /// Compare version strings
  static bool _isNewerVersion(String latest, String current) {
    try {
      final latestParts = latest.split('.').map(int.parse).toList();
      final currentParts = current.split('.').map(int.parse).toList();

      // Pad shorter version with zeros
      while (latestParts.length < 3) latestParts.add(0);
      while (currentParts.length < 3) currentParts.add(0);

      for (int i = 0; i < 3; i++) {
        if (latestParts[i] > currentParts[i]) return true;
        if (latestParts[i] < currentParts[i]) return false;
      }
      
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Find download URL for current platform
  static String? _findAssetUrl(List<dynamic> assets, List<String> extensions) {
    for (final asset in assets) {
      final name = (asset['name'] as String).toLowerCase();
      for (final ext in extensions) {
        if (name.contains(ext.toLowerCase())) {
          return asset['browser_download_url'] as String;
        }
      }
    }
    return null;
  }

  /// Open the download URL in browser
  static Future<bool> openDownloadPage(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  /// Fetch remote effects registry (for dynamic effect updates)
  static Future<List<Map<String, dynamic>>?> fetchRemoteEffects() async {
    try {
      final response = await http.get(
        Uri.parse('https://raw.githubusercontent.com/$_githubOwner/$_githubRepo/main/effects_registry.json'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['effects']);
      }
    } catch (e) {
      print('Failed to fetch remote effects: $e');
    }
    return null;
  }
}

/// Information about an available update
class UpdateInfo {
  final String currentVersion;
  final String latestVersion;
  final String releaseNotes;
  final String releaseUrl;
  final String downloadUrl;
  final bool isUpdateAvailable;

  UpdateInfo({
    required this.currentVersion,
    required this.latestVersion,
    required this.releaseNotes,
    required this.releaseUrl,
    required this.downloadUrl,
    required this.isUpdateAvailable,
  });
}
