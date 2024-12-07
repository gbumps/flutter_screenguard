import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenguard/flutter_screenguard.dart';
import 'package:flutter_screenguard/flutter_screenguard_platform_interface.dart';
import 'package:flutter_screenguard/flutter_screenguard_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterScreenguardPlatform
    with MockPlatformInterfaceMixin
    implements FlutterScreenguardPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<void> register(
      {required Color color,
      Duration? timeAfterResume = const Duration(milliseconds: 1000)}) {
    throw UnimplementedError();
  }

  @override
  Future<void> registerScreenRecordingEventListener() {
    throw UnimplementedError();
  }

  @override
  Future<void> registerScreenshotEventListener(
      {bool? getScreenShotPath = false}) {
    throw UnimplementedError();
  }

  @override
  Future<void> registerWithBlurView(
      {required num radius,
      Duration? timeAfterResume = const Duration(milliseconds: 1000)}) {
    throw UnimplementedError();
  }

  @override
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
    throw UnimplementedError();
  }

  @override
  Future<void> registerWithoutEffect() {
    throw UnimplementedError();
  }

  @override
  Future<void> unregister() {
    throw UnimplementedError();
  }
}

void main() {
  final FlutterScreenguardPlatform initialPlatform =
      FlutterScreenguardPlatform.instance;

  test('$MethodChannelFlutterScreenguard is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterScreenguard>());
  });

  test('getPlatformVersion', () async {
    FlutterScreenguard flutterScreenguardPlugin = FlutterScreenguard();
    MockFlutterScreenguardPlatform fakePlatform =
        MockFlutterScreenguardPlatform();
    FlutterScreenguardPlatform.instance = fakePlatform;

    // expect(await flutterScreenguardPlugin.getPlatformVersion(), '42');
  });
}
