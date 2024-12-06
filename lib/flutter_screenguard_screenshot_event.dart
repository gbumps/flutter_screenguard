// ignore_for_file: constant_identifier_names

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class FlutterScreenguardScreenshotEvent
    extends ValueNotifier<FileCaptureDetail?> {
  static const REGISTER_SCREENSHOT_EVT_LISTENER =
      'registerScreenshotEventListener';
  static const UNREGISTER_SCREENSHOT_EVT_LISTENER =
      'unregisterScreenshotEventListener';
  static const ON_SCREENSHOT_CAPTURED = 'onScreenshotCaptured';

  static const MethodChannel _channel =
      MethodChannel('flutter_screenguard_screenshot_event');

  final bool getScreenshotData;

  FlutterScreenguardScreenshotEvent({this.getScreenshotData = false}) : super(null);

  Future<void> initialize() async {
    _channel.setMethodCallHandler(_handleMethodCall);
    await _channel
        .invokeMethod(REGISTER_SCREENSHOT_EVT_LISTENER, <String, dynamic>{
      'getScreenshotData': getScreenshotData,
    });
  }

  Future<void> _handleMethodCall(MethodCall data) async {
    if (data.method == ON_SCREENSHOT_CAPTURED) {
      Map<String, dynamic> arguments =
          Map<String, dynamic>.from(data.arguments);
      FileCaptureDetail fileCaptureDetail =
          FileCaptureDetail.fromJson(arguments);
      value = fileCaptureDetail;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _channel.invokeMethod(UNREGISTER_SCREENSHOT_EVT_LISTENER);
  }
}

class FileCaptureDetail {
  final String? path;
  final String? name;
  final String? type;

  FileCaptureDetail({
    this.path,
    this.name,
    this.type,
  });

  factory FileCaptureDetail.fromJson(Map<String, dynamic> json) {
    return FileCaptureDetail(
      path: json['path'] as String?,
      name: json['name'] as String?,
      type: json['type'] as String?,
    );
  }
}
