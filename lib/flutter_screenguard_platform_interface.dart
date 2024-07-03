import 'package:flutter/material.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_screenguard_method_channel.dart';

abstract class FlutterScreenguardPlatform extends PlatformInterface {
  /// Constructs a FlutterScreenguardPlatform.
  FlutterScreenguardPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterScreenguardPlatform _instance =
      MethodChannelFlutterScreenguard();

  /// The default instance of [FlutterScreenguardPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterScreenguard].
  static FlutterScreenguardPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterScreenguardPlatform] when
  /// they register themselves.
  static set instance(FlutterScreenguardPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

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
    throw UnimplementedError('register() has not been implemented.');
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
  /// Throws a [PlatformException] if there were technical problems on native side
  /// (e.g. lack of relevant hardware).
  Future<void> registerWithBlurView({
    required int radius,
    Duration? timeAfterResume = const Duration(milliseconds: 1000),
  }) {
    throw UnimplementedError(
        'registerWithBlurView() has not been implemented.');
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
    required int width,
    required int height,
    Color? color = Colors.black,
    Duration? timeAfterResume = const Duration(milliseconds: 1000),
    Alignment? alignment = Alignment.center,
    int? top, 
    int? left, 
    int? bottom, 
    int? right, 
  }) {
    throw UnimplementedError('register() has not been implemented.');
  }

  /// [Android 5+] activate a screenshot blocking without any effect (blur, image, color)
  /// 
  /// Throws a [PlatformException] if there were technical problems on native side
  Future<void> registerWithoutEffect() {
    throw UnimplementedError(
        'registerWithoutEffect() has not been implemented.');
  }

  /// [iOS 12+, Android 8+] activate a screenshot listener
  /// 
  /// function will throw warning when [timeAfterResume] bigger than 3000ms, 
  /// users have to wait for the application
  /// to turn off the filter before going back to the main view, which is a very bad user
  /// experiences.
  /// 
  /// Throws a [PlatformException] if there were technical problems on native side
  Future<void> registerScreenshotEventListener({
    bool? getScreenShotPath = false,
  }) {
    throw UnimplementedError(
        'registerScreenshotEventListener() has not been implemented.');
  }

  /// [iOS] activate a screenshot blocking with a color effect view (iOS 13+, Android 8+)
  /// [color] color of the background
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
  Future<void> registerScreenRecordingEventListener() {
    throw UnimplementedError(
        'registerScreenRecordingEventListener() has not been implemented.');
  }

  /// unregister and deactivate all screenguard and listener
  /// Throws a [PlatformException] if there were technical problems on native side
  Future<void> unregister() {
    throw UnimplementedError(
        'unregister() has not been implemented.');
  }
}
