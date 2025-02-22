import 'package:flutter/material.dart';
import 'package:flutter_screenguard/flutter_screenguard_helper.dart';

import 'flutter_screenguard_platform_interface.dart';

class FlutterScreenguard {
  GlobalKey? globalKey;

  FlutterScreenguard({this.globalKey});

  /// activate a screenshot blocking with a color effect view (iOS 13+, Android 8+)
  /// [color] color of the background
  ///
  /// [timeAfterResume] (Android only) Time delayed for the view to stop displaying when going back
  /// to the application (in milliseconds). Default = 1000ms
  ///
  /// function will throw warning when [timeAfterResume] bigger than 3000ms,
  /// users have to wait for the application to turn off the filter before going back
  /// to the main view, which is a very bad user experiences.
  ///
  /// Throws a [PlatformException] if there were technical problems on native side
  /// (e.g. lack of relevant hardware).
  Future<void> register({
    required Color color,
    Duration? timeAfterResume = const Duration(milliseconds: 1000),
  }) {
    /// activate a screenshot blocking with a color effect view (iOS 13+, Android 8+)
    /// [color] color of the background, default Colors.black
    ///
    /// [timeAfterResume] (Android only) Time delayed for the view to stop displaying when going back
    /// to the application (in milliseconds). Default = 1000ms
    ///
    /// function will throw warning when [timeAfterResume] bigger than 3000ms,
    /// users have to wait for the application to turn off the filter before going back
    /// to the main view, which is a very bad user experiences.
    ///
    /// Throws a [PlatformException] if there were technical problems on native side
    /// (e.g. lack of relevant hardware).
    return FlutterScreenguardPlatform.instance.register(
      color: color,
      timeAfterResume: timeAfterResume,
    );
  }

  /// [iOS, Android] activate a screenshot blocking with a blurred effect view (iOS 13+, Android 8+)
  /// [radius] radius
  ///
  /// [timeAfterResume] (Android only) Time delayed for the view to stop displaying when going back
  /// to the application (in milliseconds). Default = 1000ms
  ///
  /// function will throw warning when [timeAfterResume] bigger than 3000ms,
  /// users have to wait for the application to turn off the filter before going back
  /// to the main view, which is a very bad user experiences.
  ///
  /// function will throw an exception if globalKey is not initialized
  ///
  /// Throws a [PlatformException] if there were technical problems on native side
  Future<void> registerWithBlurView({
    required num radius,
    Duration? timeAfterResume = const Duration(milliseconds: 1000),
  }) async {
    assert(globalKey != null);
    assert(radius > 0);
    if (radius < 15 || radius > 50) {
      debugPrint(
          'Warning: Set blur radius smaller than 15 wont help much, as content still look very clear and easy to read. Same with bigger than 50 but content will be shrinked and vanished inside the view, blurring is meaningless.');
    }
    final url =
        await FlutterScreenguardHelper.captureAsUiImage(globalKey: globalKey!);
    if (url != null) {
      return FlutterScreenguardPlatform.instance.registerWithBlurView(
        radius: radius,
        timeAfterResume: timeAfterResume,
        localImagePath: url,
      );
    }
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
  /// [timeAfterResume] (Android only) Time delayed for the view to stop displaying when going back
  /// to the application (in milliseconds). Default = 1000ms
  ///
  /// function will throw warning when [timeAfterResume] bigger than 3000ms,
  /// users have to wait for the application
  /// to turn off the filter before going back to the main view, which is a very bad user
  /// experiences.
  ///
  /// Throws a [PlatformException] if there were technical problems on native side
  Future<void> registerWithImage({
    required String uri,
    required double width,
    required double height,
    Color? color = Colors.black,
    Duration? timeAfterResume = const Duration(milliseconds: 1000),
    Alignment? alignment,
    double? top,
    double? left,
    double? bottom,
    double? right,
  }) {
    return FlutterScreenguardPlatform.instance.registerWithImage(
      uri: uri,
      width: width,
      height: height,
      color: color,
      timeAfterResume: timeAfterResume,
      alignment: alignment,
      top: top,
      left: left,
      bottom: bottom,
      right: right,
    );
  }

  /// [Android 8+](Android only) activate a screenshot blocking without any effect
  /// (image, color, blur)
  /// Throws a [PlatformException] if there were technical problems on native side
  Future<void> registerWithoutEffect() {
    return FlutterScreenguardPlatform.instance.registerWithoutEffect();
  }

  /// [Android 8+, iOS 12+] activate a screenshot listener
  /// on Android, the function will not work properly when the protection filter is activated
  /// due to specification of Android platform
  /// Throws a [PlatformException] if there were technical problems on native side
  Future<void> registerScreenshotEventListener() {
    return FlutterScreenguardPlatform.instance
        .registerScreenshotEventListener();
  }

  /// [iOS 12+] (iOS only) activate a screen recording listener
  /// on Android, the function will not work properly when the protection filter is activated
  /// due to Android technical platform
  /// Throws a [PlatformException] if there were technical problems on native side
  Future<void> registerScreenRecordingEventListener() {
    return FlutterScreenguardPlatform.instance
        .registerScreenRecordingEventListener();
  }

  /// [Android 8+, iOS 12+] deactivate all screenshot
  /// on Android, the function will not work properly when the protection filter is activated
  /// due to Android technical platform
  /// Throws a [PlatformException] if there were technical problems on native side
  Future<void> unregister() {
    return FlutterScreenguardPlatform.instance.unregister();
  }
}
