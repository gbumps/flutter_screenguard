// ignore_for_file: constant_identifier_names

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class FlutterScreenguardScreenRecordingEvent
    extends ValueNotifier<String?> {
  static const MethodChannel _channel =
      MethodChannel('flutter_screenguard_screen_recording_event');

  static const REGISTER_SCREEN_RECORDING_EVT_LISTENER =
      'registerScreenRecordingEventListener';
  static const UNREGISTER_SCREEN_RECORDING_EVT_LISTENER =
      'unregisterScreenRecordingEventListener';
  static const ON_SCREEN_RECORDING_CAPTURED = 'onScreenRecordingCaptured';

  FlutterScreenguardScreenRecordingEvent() : super('');

  Future<void> initialize() async {
    _channel.setMethodCallHandler(_handleMethodCall);
    await _channel.invokeMethod(REGISTER_SCREEN_RECORDING_EVT_LISTENER);
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    if (call.method == ON_SCREEN_RECORDING_CAPTURED) {
      value = 'Screen record running';
    }
  }

  @override
  void dispose() {
    super.dispose();
    _channel.invokeMethod(UNREGISTER_SCREEN_RECORDING_EVT_LISTENER);
  }
}
