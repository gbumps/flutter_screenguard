import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import 'flutter_screenguard_platform_interface.dart';

/// An implementation of [FlutterScreenguardPlatform] that uses method channels.
class MethodChannelFlutterScreenguard extends FlutterScreenguardPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_screenguard');

  final _screenshotChannel =
      const MethodChannel('flutter_screenguard_screenshot_event');
  final _recordingChannel =
      const MethodChannel('flutter_screenguard_screen_recording_event');

  final _screenshotController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _recordingController =
      StreamController<Map<String, dynamic>>.broadcast();

  bool _handlersInitialized = false;

  void _ensureHandlersInitialized() {
    if (_handlersInitialized) return;
    _handlersInitialized = true;

    _screenshotChannel.setMethodCallHandler((call) async {
      if (call.method == 'onScreenshotCaptured') {
        _screenshotController.add(Map<String, dynamic>.from(call.arguments));
      }
    });

    _recordingChannel.setMethodCallHandler((call) async {
      if (call.method == 'onScreenRecordingCaptured') {
        _recordingController
            .add(Map<String, dynamic>.from(call.arguments ?? {}));
      }
    });
  }

  @override
  Stream<Map<String, dynamic>> get onScreenshotCaptured {
    _ensureHandlersInitialized();
    return _screenshotController.stream;
  }

  @override
  Stream<Map<String, dynamic>> get onScreenRecordingCaptured {
    _ensureHandlersInitialized();
    return _recordingController.stream;
  }

  static const List<Alignment> alignments = [
    Alignment.topLeft,
    Alignment.topCenter,
    Alignment.topRight,
    Alignment.centerLeft,
    Alignment.center,
    Alignment.centerRight,
    Alignment.bottomLeft,
    Alignment.bottomCenter,
    Alignment.bottomRight,
  ];

  /// activate a screenshot blocking with a color effect view (iOS 13+, Android 8+)
  /// [color] color of the background
  ///
  /// Throws a [PlatformException] if there were technical problems on native side
  /// (e.g. lack of relevant hardware).
  @override
  Future<void> register({
    required Color color,
  }) async {
    final colorHex =
        '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
    await methodChannel.invokeMethod<void>('activateShield', <String, dynamic>{
      'color': colorHex,
    });
  }

  /// [iOS 13+, Android 8+] activate a screenshot blocking with an image effect view
  /// [color] color of the background
  ///
  /// [uri] (required) uri of the image
  ///
  /// [width] (required) width of the image
  ///
  /// [height] (required) height of the image
  ///
  /// [alignment] Alignment of the image, default Alignment.center
  ///
  /// Throws a [PlatformException] if there were technical problems on native side
  @override
  Future<void> registerWithImage({
    required String uri,
    required double width,
    required double height,
    Color? color = Colors.black,
    Alignment? alignment,
    double? top,
    double? left,
    double? bottom,
    double? right,
  }) async {
    final colorHex =
        '#${color?.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
    final align = alignments.indexWhere(
      (element) => element == alignment,
    );
    await methodChannel
        .invokeMethod<void>('activateShieldWithImage', <String, dynamic>{
      'uri': uri,
      'width': width.toString(),
      'height': height.toString(),
      'alignment': align == -1 ? 4 : align,
      'top': top,
      'left': left,
      'bottom': bottom,
      'right': right,
      'color': colorHex,
    });
  }

  /// [iOS, Android] activate a screenshot blocking with a blurred effect view (iOS 13+, Android 8+)
  /// [radius] radius
  ///
  /// Throws a [PlatformException] if there were technical problems on native side
  /// (e.g. lack of relevant hardware).
  @override
  Future<void> registerWithBlurView({
    required num radius,
    String? localImagePath,
  }) async {
    await methodChannel
        .invokeMethod<void>('activateShieldWithBlurView', <String, dynamic>{
      'radius': radius,
      'localImagePath': localImagePath,
    });
  }

  /// unregister and deactivate all screenguard and listener
  /// Throws a [PlatformException] if there were technical problems on native side
  @override
  Future<void> unregister() async {
    await methodChannel.invokeMethod<void>('deactivateShield');
  }

  /// [Android 5+] activate a screenshot blocking without any effect (blur, image, color)
  @override
  Future<void> registerWithoutEffect() async {
    await methodChannel.invokeMethod<void>('activateShieldWithoutEffect');
  }

  @override
  Future<List<Map<String, dynamic>>> getScreenGuardLogs({
    required int maxCount,
  }) async {
    final List<dynamic>? logs = await methodChannel.invokeMethod<List<dynamic>>(
      'getScreenGuardLogs',
      {'maxCount': maxCount},
    );
    if (logs == null) {
      return [];
    }
    return logs.cast<Map<String, dynamic>>();
  }

  @override
  Future<void> initSettings({
    bool? enableCapture = false,
    bool? enableRecord = false,
    bool? enableContentMultitask = false,
    bool? displayOverlay = false,
    bool? displayScreenguardOverlayAndroid = true,
    int? timeAfterResume = 1000,
    bool? getScreenshotPath = false,
    int? limitCaptureEvtCount = 0,
    bool? trackingLog = false,
  }) async {
    await methodChannel.invokeMethod('initSettings', {
      'enableCapture': enableCapture,
      'enableRecord': enableRecord,
      'enableContentMultitask': enableContentMultitask,
      'displayOverlay': displayOverlay,
      'displayScreenguardOverlayAndroid': displayScreenguardOverlayAndroid,
      'timeAfterResume': timeAfterResume,
      'getScreenshotPath': getScreenshotPath,
      'limitCaptureEvtCount': limitCaptureEvtCount,
      'trackingLog': trackingLog,
    });
  }
}
