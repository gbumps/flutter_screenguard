// ignore_for_file: constant_identifier_names

import 'package:flutter/services.dart';

typedef EventCallback = void Function(Map<String, dynamic>? data);

class FlutterScreenguardScreenshotEvent {
  static const REGISTER_SCREENSHOT_EVT_LISTENER =
      'registerScreenshotEventListener';
  static const UNREGISTER_SCREENSHOT_EVT_LISTENER =
      'unregisterScreenshotEventListener';

  static const MethodChannel _channel =
      MethodChannel('flutter_screenguard_screenshot_event');

  EventCallback? _callback;

  FlutterScreenguardScreenshotEvent() {
    initialize();
  }

  Future<void> initialize() async {
    _channel.setMethodCallHandler(_handleMethodCall);
    await _channel.invokeMethod(REGISTER_SCREENSHOT_EVT_LISTENER);
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    if (call.method == 'onScreenshotCaptured') {
      _callback?.call(call.arguments);
    }
  }

  void addListener(EventCallback callback) {
    _callback = callback;
  }

  void dispose() {
    _callback = null;
    _stopListening();
  }

  void _stopListening() {
    _channel.invokeMethod(UNREGISTER_SCREENSHOT_EVT_LISTENER);
  }
}
