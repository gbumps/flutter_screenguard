import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'flutter_screenguard_platform_interface.dart';

/// An implementation of [FlutterScreenguardPlatform] that uses method channels.
class MethodChannelFlutterScreenguard extends FlutterScreenguardPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_screenguard');

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

  @override
  Future<void> registerWithBlurView(
      {required int radius,
      Duration? timeAfterResume = const Duration(milliseconds: 1000)}) async {
    await methodChannel
        .invokeMethod<void>('registerWithBlurView', <String, dynamic>{
      'radius': radius,
      'timeAfterResume': (timeAfterResume ?? const Duration(milliseconds: 1000))
          .inMilliseconds,
    });
  }

  @override
  Future<void> unregister() async {
    await methodChannel.invokeMethod<void>('unregister');
  }
}
