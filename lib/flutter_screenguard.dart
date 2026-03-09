import 'package:flutter/material.dart';
import 'package:flutter_screenguard/flutter_screenguard_helper.dart';

import 'flutter_screenguard_platform_interface.dart';

class FlutterScreenguard {
  GlobalKey? globalKey;

  static bool _isInitialized = false;

  FlutterScreenguard({this.globalKey});

  /// Initialize the screen guard with settings
  /// [enableCapture] enable screenshot capture
  /// [enableRecord] enable screen recording
  /// [enableContentMultitask] enable content visibility in multitask mode (iOS only)
  /// [displayOverlay] when enabled, the screen guard will be displayed over the app if user capture the screen (iOS only)
  /// [displayScreenguardOverlayAndroid] when enabled, displays an overlay when user returns to the app from background (Android only, default true)
  /// [timeAfterResume] Time delayed for the view to stop displaying when going back to the application (in milliseconds)
  /// [getScreenshotPath] get screenshot path after captured
  /// [limitCaptureEvtCount] Limit the number of screenshot events triggered
  /// [trackingLog] Allow to record log in native storage
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
    await FlutterScreenguardPlatform.instance.initSettings(
      enableCapture: enableCapture,
      enableRecord: enableRecord,
      enableContentMultitask: enableContentMultitask,
      displayOverlay: displayOverlay,
      displayScreenguardOverlayAndroid: displayScreenguardOverlayAndroid,
      timeAfterResume: timeAfterResume,
      getScreenshotPath: getScreenshotPath,
      limitCaptureEvtCount: limitCaptureEvtCount,
      trackingLog: trackingLog,
    );
    _isInitialized = true;
  }

  void _checkInitialized() {
    if (!_isInitialized) {
      throw Exception(
          'ScreenGuard is not initialized. Please call initSettings() first!');
    }
  }

  /// Activate a screenshot blocking with a color effect view (iOS 13+, Android 8+)
  /// [color] color of the background
  ///
  /// Throws a [PlatformException] if there were technical problems on native side
  /// (e.g. lack of relevant hardware).
  Future<void> register({
    required Color color,
  }) {
    _checkInitialized();
    return FlutterScreenguardPlatform.instance.register(
      color: color,
    );
  }

  /// [iOS, Android] Activate a screenshot blocking with a blurred effect view (iOS 13+, Android 8+)
  /// [radius] blur radius value number in between [15, 50]
  /// [globalKey] GlobalKey of the widget to capture for blur effect
  ///
  /// function will throw an exception if globalKey is not initialized
  ///
  /// Throws a [PlatformException] if there were technical problems on native side
  Future<void> registerWithBlurView({
    required num radius,
    GlobalKey? globalKey,
  }) async {
    _checkInitialized();
    final key = globalKey ?? this.globalKey;
    assert(key != null,
        'globalKey must be provided either in constructor or method parameter');
    assert(radius > 0);
    if (radius < 15 || radius > 50) {
      debugPrint(
          'Warning: Set blur radius smaller than 15 wont help much, as content still look very clear and easy to read. Same with bigger than 50 but content will be shrinked and vanished inside the view, blurring is meaningless.');
    }
    final url =
        await FlutterScreenguardHelper.captureAsUiImage(globalKey: key!);
    if (url != null) {
      return FlutterScreenguardPlatform.instance.registerWithBlurView(
        radius: radius,
        localImagePath: url,
      );
    }
  }

  /// [iOS 13+, Android 8+] Activate a screenshot blocking with an image effect view
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
  }) {
    _checkInitialized();
    return FlutterScreenguardPlatform.instance.registerWithImage(
      uri: uri,
      width: width,
      height: height,
      color: color,
      alignment: alignment,
      top: top,
      left: left,
      bottom: bottom,
      right: right,
    );
  }

  /// [Android 8+](Android only) Activate a screenshot blocking without any effect
  /// (image, color, blur)
  /// Throws a [PlatformException] if there were technical problems on native side
  Future<void> registerWithoutEffect() {
    _checkInitialized();
    return FlutterScreenguardPlatform.instance.registerWithoutEffect();
  }

  /// [Android 8+, iOS 12+] Deactivate all screenshot protection
  /// on Android, the function will not work properly when the protection filter is activated
  /// due to Android technical platform
  /// Throws a [PlatformException] if there were technical problems on native side
  Future<void> unregister() {
    return FlutterScreenguardPlatform.instance.unregister();
  }

  /// [iOS, Android] get screen guard logs
  Future<List<Map<String, dynamic>>> getScreenGuardLogs({
    required int maxCount,
  }) {
    return FlutterScreenguardPlatform.instance.getScreenGuardLogs(
      maxCount: maxCount,
    );
  }

  /// [iOS, Android] stream for screenshot captured event
  Stream<Map<String, dynamic>> get onScreenshotCaptured =>
      FlutterScreenguardPlatform.instance.onScreenshotCaptured;

  /// [iOS, Android] stream for screen recording captured event
  /// Returns a Map with:
  /// - isRecording: bool - whether recording started (true) or stopped (false)
  /// - activationStatus: Map with method (String) and isActivated (bool)
  Stream<Map<String, dynamic>> get onScreenRecordingCaptured =>
      FlutterScreenguardPlatform.instance.onScreenRecordingCaptured;
}
