import 'package:flutter/services.dart';

typedef EventCallback = void Function();

class FlutterScreenguardScreenRecordingEvent {
  static const MethodChannel _channel = MethodChannel('flutter_screenguard_screen_recording_event');
  
  EventCallback? _callback;

  FlutterScreenguardScreenRecordingEvent() {
    initialize();
  }

  Future<void> initialize() async {
    _channel.setMethodCallHandler(_handleMethodCall);
    await _channel.invokeMethod('registerScreenRecordingEventListener');
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    if (call.method == 'onScreenRecordingCaptured') {
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
    _channel.invokeMethod('stopListeningScreenRecording');
  }
}