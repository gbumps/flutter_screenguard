import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path/path.dart' as path;

import 'dart:ui' as ui;

import 'flutter_screenguard_platform_interface.dart';

class FlutterScreenguard {
  late GlobalKey globalKey;

  FlutterScreenguard({required this.globalKey});

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
  /// Throws a [PlatformException] if there were technical problems on native side
  /// (e.g. lack of relevant hardware).
  Future<void> registerWithBlurView({
    required num radius,
    Duration? timeAfterResume = const Duration(milliseconds: 1000),
  }) async {
    final url = await _captureAsUiImage();
    if (url != null) {
    return FlutterScreenguardPlatform.instance
        .registerWithBlurView(radius: radius, timeAfterResume: timeAfterResume, url: url!);
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

  Future<void> registerWithoutEffect() {
    return FlutterScreenguardPlatform.instance.registerWithoutEffect();
  }

  Future<void> registerScreenshotEventListener() {
    return FlutterScreenguardPlatform.instance
        .registerScreenshotEventListener();
  }

  Future<void> registerScreenRecordingEventListener() {
    return FlutterScreenguardPlatform.instance
        .registerScreenRecordingEventListener();
  }

  Future<void> unregister() {
    return FlutterScreenguardPlatform.instance.unregister();
  }

  Future<String?> _captureAsUiImage(
      {double? pixelRatio = 1,
      Duration delay = const Duration(milliseconds: 40)}) {
    return Future.delayed(delay, () async {
      try {
        var findRenderObject = globalKey.currentContext?.findRenderObject();
        if (findRenderObject == null) {
          return null;
        }
        RenderRepaintBoundary boundary =
            findRenderObject as RenderRepaintBoundary;
        BuildContext? context = globalKey.currentContext;
        if (pixelRatio == null) {
          if (context != null) {
            pixelRatio = pixelRatio ?? MediaQuery.of(context).devicePixelRatio;
          }
        }
        ui.Image image = await boundary.toImage(pixelRatio: pixelRatio ?? 1);
        ByteData? byteData =
            await image.toByteData(format: ui.ImageByteFormat.png);
        image.dispose();

        Uint8List? pngBytes = byteData?.buffer.asUint8List();
        if (pngBytes != null) {
          final Directory cacheDir = await Directory.systemTemp.createTemp();
          final String filePath = path.join(cacheDir.path,
              'screenguard_${DateTime.now().millisecondsSinceEpoch}.png');

          // Write the image data to the file
          final File file = File(filePath);
          await file.writeAsBytes(pngBytes);

          return filePath;
        }
        return null;
      } catch (e) {
        return null;
      }
    });
  }
}
