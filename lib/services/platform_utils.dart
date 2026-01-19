import 'package:flutter/foundation.dart';
import 'dart:io';

/// Platform utilities for determining app capabilities
class PlatformUtils {
  /// Check if the current platform is a desktop platform
  static bool get isDesktop {
    if (kIsWeb) return false;
    return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  }

  /// Check if the current platform is a mobile platform
  static bool get isMobile {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  /// Check if the current platform is web
  static bool get isWeb => kIsWeb;

  /// Check if FFmpeg Kit is supported on this platform
  static bool get supportsFFmpegKit {
    // FFmpeg Kit supports mobile and desktop but not web
    return !kIsWeb;
  }

  /// Check if file drag and drop is supported
  static bool get supportsDragDrop {
    return isDesktop || isWeb;
  }

  /// Check if the app can open file locations in system explorer
  static bool get canOpenFileLocation {
    return isDesktop;
  }

  /// Get the platform name for display
  static String get platformName {
    if (kIsWeb) return 'Web';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isLinux) return 'Linux';
    return 'Unknown';
  }

  /// Get the recommended file picker type for videos
  static List<String>? get videoExtensions {
    return ['mp4', 'mov', 'avi', 'mkv', 'webm', 'wmv', 'flv', 'm4v'];
  }
}
