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

  Future<void> register() {
    throw UnimplementedError('register() has not been implemented.');
  }

  Future<void> registerWithBlurView() {
    throw UnimplementedError(
        'registerWithBlurView() has not been implemented.');
  }

  Future<void> registerWithImage() {
    throw UnimplementedError('registerWithImage() has not been implemented.');
  }

  Future<void> registerWithoutEffect() {
    throw UnimplementedError(
        'registerWithoutEffect() has not been implemented.');
  }

  Future<void> registerScreenshotEventListener() {
    throw UnimplementedError(
        'registerScreenshotEventListener() has not been implemented.');
  }

  Future<void> registerScreenRecordingEventListener() {
    throw UnimplementedError(
        'registerScreenRecordingEventListener() has not been implemented.');
  }
  Future<void> unregister() {
    throw UnimplementedError(
        'unregister() has not been implemented.');
  }
}
