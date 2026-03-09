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
  Future<void> register({
    required Color color,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> registerWithBlurView({
    required num radius,
    String? localImagePath,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> registerWithImage({
    required String uri,
    required double width,
    required double height,
    Color? color = Colors.black,
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

  @override
  Future<List<Map<String, dynamic>>> getScreenGuardLogs({
    required int maxCount,
  }) {
    return Future.value([]);
  }

  @override
  Stream<Map<String, dynamic>> get onScreenshotCaptured => const Stream.empty();

  @override
  Stream<Map<String, dynamic>> get onScreenRecordingCaptured =>
      const Stream.empty();

  @override
  Future<void> initSettings({
    bool? enableCapture = false,
    bool? enableRecord = false,
    bool? enableContentMultitask = false,
    bool? displayOverlay = false,
    bool? displayScreenguardOverlayAndroid = true,
    int? timeAfterResume = 1000,
    bool? getScreenshotPath = false,
    int? limitCaptureEvtCount = 0,
    bool? trackingLog = false,
  }) {
    return Future.value();
  }
}

void main() {
  final FlutterScreenguardPlatform initialPlatform =
      FlutterScreenguardPlatform.instance;

  test('$MethodChannelFlutterScreenguard is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterScreenguard>());
  });

  test('initSettings works', () async {
    FlutterScreenguard flutterScreenguardPlugin = FlutterScreenguard();
    MockFlutterScreenguardPlatform fakePlatform =
        MockFlutterScreenguardPlatform();
    FlutterScreenguardPlatform.instance = fakePlatform;

    await flutterScreenguardPlugin.initSettings(
        enableCapture: false, enableRecord: false);
  });
}
