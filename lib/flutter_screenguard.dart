
import 'flutter_screenguard_platform_interface.dart';

class FlutterScreenguard {
  Future<void> register() {
    return FlutterScreenguardPlatform.instance.register();
  }

  Future<void> registerWithBlurView() {
    return FlutterScreenguardPlatform.instance.registerWithBlurView();
  }

  Future<void> registerWithImage() {
    return FlutterScreenguardPlatform.instance.registerWithImage();
  }

  Future<void> registerWithoutEffect() {
    return FlutterScreenguardPlatform.instance.registerWithoutEffect();
  }

  Future<void> registerScreenshotEventListener() {
    return FlutterScreenguardPlatform.instance.registerScreenshotEventListener();
  }

  Future<void> registerScreenRecordingEventListener() {
    return FlutterScreenguardPlatform.instance.registerScreenRecordingEventListener();
  }

  Future<void> unregister() {
    return FlutterScreenguardPlatform.instance.unregister();
  }
}
