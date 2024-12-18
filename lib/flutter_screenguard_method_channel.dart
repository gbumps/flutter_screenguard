import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'flutter_screenguard_platform_interface.dart';

/// An implementation of [FlutterScreenguardPlatform] that uses method channels.
class MethodChannelFlutterScreenguard extends FlutterScreenguardPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_screenguard');

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
  /// [timeAfterResume] (Android only) Time delayed for the view to stop displaying when going back
  /// to the application (in milliseconds). Default = 1000ms
  ///
  /// function will throw warning when [timeAfterResume] bigger than 3000ms,
  /// users have to wait for the application to turn off the filter before going back
  /// to the main view, which is a very bad user experiences.
  ///
  /// Throws a [PlatformException] if there were technical problems on native side
  /// (e.g. lack of relevant hardware).
  @override
  Future<void> register({
    required Color color,
    Duration? timeAfterResume,
  }) async {
    final colorHex =
        '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
    await methodChannel.invokeMethod<void>('register', <String, dynamic>{
      'color': colorHex,
      'timeAfterResume': (timeAfterResume ?? const Duration(milliseconds: 1000))
          .inMilliseconds,
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
  /// [timeAfterResume] (Android only) Time delayed for the view to stop displaying when going back
  /// to the application (in milliseconds). Default = 1000ms
  ///
  /// function will throw warning when [timeAfterResume] bigger than 3000ms,
  /// users have to wait for the application
  /// to turn off the filter before going back to the main view, which is a very bad user
  /// experiences.
  ///
  /// Throws a [PlatformException] if there were technical problems on native side
  @override
  Future<void> registerWithImage(
      {required String uri,
      required double width,
      required double height,
      Color? color = Colors.black,
      Duration? timeAfterResume = const Duration(milliseconds: 1000),
      Alignment? alignment,
      double? top,
      double? left,
      double? bottom,
      double? right}) async {
    final colorHex =
        '#${color?.value.toRadixString(16).padLeft(8, '0').substring(2)}';
    final align = alignments.indexWhere(
      (element) => element == alignment,
    );
    await methodChannel
        .invokeMethod<void>('registerWithImage', <String, dynamic>{
      'uri': uri,
      'width': width.toString(),
      'height': height.toString(),
      'alignment': align == -1 ? null : align,
      'top': top,
      'left': left,
      'bottom': bottom,
      'right': right,
      'color': colorHex,
      'timeAfterResume': (timeAfterResume ?? const Duration(milliseconds: 1000))
          .inMilliseconds,
    });
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
  @override
  Future<void> registerWithBlurView(
      {required num radius,
      String? localImagePath,
      Duration? timeAfterResume = const Duration(milliseconds: 1000)}) async {
    await methodChannel
        .invokeMethod<void>('registerWithBlurView', <String, dynamic>{
      'radius': radius,
      'localImagePath': localImagePath,
      'timeAfterResume': (timeAfterResume ?? const Duration(milliseconds: 1000))
          .inMilliseconds,
    });
  }

  /// unregister and deactivate all screenguard and listener
  /// Throws a [PlatformException] if there were technical problems on native side
  @override
  Future<void> unregister() async {
    await methodChannel.invokeMethod<void>('unregister');
  }
}
