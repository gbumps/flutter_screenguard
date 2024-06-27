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
}

void main() {
  final FlutterScreenguardPlatform initialPlatform = FlutterScreenguardPlatform.instance;

  test('$MethodChannelFlutterScreenguard is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterScreenguard>());
  });

  test('getPlatformVersion', () async {
    FlutterScreenguard flutterScreenguardPlugin = FlutterScreenguard();
    MockFlutterScreenguardPlatform fakePlatform = MockFlutterScreenguardPlatform();
    FlutterScreenguardPlatform.instance = fakePlatform;

    expect(await flutterScreenguardPlugin.getPlatformVersion(), '42');
  });
}
