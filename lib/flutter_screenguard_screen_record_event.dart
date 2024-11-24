// ignore_for_file: constant_identifier_names

import 'package:flutter/services.dart';

typedef EventCallback = void Function(Map<String, dynamic>? data);

class FlutterScreenguardScreenRecordingEvent {
  static const MethodChannel _channel =
      MethodChannel('flutter_screenguard_screen_recording_event');

  static const REGISTER_SCREEN_RECORDING_EVT_LISTENER =
      'registerScreenRecordingEventListener';
  static const UNREGISTER_SCREEN_RECORDING_EVT_LISTENER =
      'unregisterScreenRecordingEventListener';

  EventCallback? _callback;

  FlutterScreenguardScreenRecordingEvent() {
    initialize();
  }

  Future<void> initialize() async {
    _channel.setMethodCallHandler(_handleMethodCall);
    await _channel.invokeMethod(REGISTER_SCREEN_RECORDING_EVT_LISTENER);
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    if (call.method == 'onScreenRecordingCaptured') {
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
    _channel.invokeMethod(UNREGISTER_SCREEN_RECORDING_EVT_LISTENER);
  }
}
