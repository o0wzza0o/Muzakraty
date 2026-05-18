import 'dart:io';
import 'package:flutter/services.dart';

/// Service responsible for preventing screen captures and recordings.
/// Uses FLAG_SECURE on Android and UIScreen.isCaptured detection on iOS.
class ScreenSecurityService {
  static const _channel = MethodChannel('com.muzakraty/screen_security');

  /// Enable screen capture prevention (should be called on app start
  /// and when navigating to protected screens).
  static Future<void> enableProtection() async {
    try {
      if (Platform.isAndroid) {
        await _channel.invokeMethod('enableSecureFlag');
      } else if (Platform.isIOS) {
        await _channel.invokeMethod('enableScreenProtection');
      }
    } on PlatformException catch (_) {
      // Fallback: try flutter_windowmanager approach
      try {
        await _enableViaWindowManager();
      } catch (_) {
        // Security couldn't be enabled — log but don't crash
      }
    }
  }

  /// Disable screen capture prevention (only if needed for specific screens).
  static Future<void> disableProtection() async {
    try {
      if (Platform.isAndroid) {
        await _channel.invokeMethod('disableSecureFlag');
      } else if (Platform.isIOS) {
        await _channel.invokeMethod('disableScreenProtection');
      }
    } on PlatformException catch (_) {
      // Silently fail
    }
  }

  /// Check if screen is currently being recorded (iOS).
  static Future<bool> isScreenBeingRecorded() async {
    try {
      if (Platform.isIOS) {
        final result = await _channel.invokeMethod<bool>('isScreenCaptured');
        return result ?? false;
      }
    } on PlatformException catch (_) {
      // Silently fail
    }
    return false;
  }

  static Future<void> _enableViaWindowManager() async {
    // Alternative approach using flutter_windowmanager package
    try {
      if (Platform.isAndroid) {
        await _channel.invokeMethod('addFlags', {'flags': 0x00002000}); // FLAG_SECURE
      }
    } catch (_) {
      // Silently fail
    }
  }
}
