import 'package:flutter/services.dart';

typedef EventCallback = void Function();

class FlutterScreenguardScreenshotEvent {
  static const MethodChannel _channel = MethodChannel('flutter_screenguard_screenshot_event');
  
  EventCallback? _callback;

  FlutterScreenguardScreenshotEvent () {
    initialize();
  }

  Future<void> initialize() async {
    _channel.setMethodCallHandler(_handleMethodCall);
    await _channel.invokeMethod('registerScreenshotEventListener');
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    if (call.method == 'onScreenshotCaptured') {
      _callback?.call();
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
    _channel.invokeMethod('deactivateScreenshotDetector');
  }
}