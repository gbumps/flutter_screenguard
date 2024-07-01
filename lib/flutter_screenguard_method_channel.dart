import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_screenguard_platform_interface.dart';

/// An implementation of [FlutterScreenguardPlatform] that uses method channels.
class MethodChannelFlutterScreenguard extends FlutterScreenguardPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_screenguard');

  @override
  Future<void> register() async {
    await methodChannel.invokeMethod<String>('register', );
  }
}
