# flutter_screenguard

A Native screenshot blocking plugin for Flutter developer, with powerful event detection capabilities.

![Demo](https://i.ibb.co/JRRWzmD8/406836547-ea6cba30-5930-4219-92c5-283db2cf125e-ezgif-com-resize.gif)

---


## ✨ Features

- 🛡️ **Block screenshots** with customizable color overlay, blur effect, or image overlay
- 📸 **Screenshot detection** — listen for screenshot events with optional captured file info
- 🎥 **Screen recording detection** — detect when screen recording starts/stops
- 📝 **Event logging** — track and retrieve screenguard logs from native storage
- 🔧 **Highly configurable** — fine-tune behavior per platform with `initSettings`

## 📋 Requirements

| Platform | Minimum Version |
|----------|----------------|
| Flutter  | ≥ 3.7.0        |
| Dart     | ≥ 3.4.0 < 4.0.0 |
| iOS      | ≥ 12.0         |
| Android compileSdk | 34     |
| Java     | 17             |
| Android Gradle Plugin | ≥ 8.3.0 |
| Gradle wrapper | ≥ 7.6    |

## 📦 Installation

Add `flutter_screenguard` to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_screenguard: ^2.0.0
```

Or install via CLI:

```shell
flutter pub add flutter_screenguard
```

---

## ⚠️ Post-Installation Setup (Android) (v1.0.0 only)

> [!IMPORTANT]
> You **must** complete these steps on Android for color overlay and blur effects to work properly.
> v2.0.0+ no longer need to do this step!

### 1. Register the overlay Activity

Open `android/app/src/main/AndroidManifest.xml` and add `ScreenGuardColorActivity` inside the `<application>` tag:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application ...>
        <activity
            android:name=".MainActivity" ...>
            ...
        </activity>

        <!-- Add this ↓ -->
        <activity android:name="com.screenguard.flutter_screenguard.ScreenGuardColorActivity"
            android:theme="@style/Theme.AppCompat.Translucent"
            android:configChanges="keyboard|keyboardHidden|orientation|screenLayout|screenSize|smallestScreenSize|uiMode"
            android:windowSoftInputMode="stateAlwaysVisible|adjustResize"
            android:exported="false"
        />
    </application>
</manifest>
```

Open up [your_project_path]/android/app/src/main/res/values/styles.xml and add style Theme.AppCompat.Translucent like below
```
<resource>

<style name="AppTheme">your current app style theme.............</style>

+ <style name="Theme.AppCompat.Translucent">
+        <item name="android:windowNoTitle">true</item>
+        <item name="android:windowBackground">@android:color/transparent</item>
+        <item name="android:colorBackgroundCacheHint">@null</item>
+        <item name="android:windowIsTranslucent">true</item>
+        <item name="android:windowAnimationStyle">@null</item>
+        <item name="android:windowSoftInputMode">adjustResize</item>
+ </style>
</resource>
```

---

## 🚀 Usage

### Import

```dart
import 'package:flutter_screenguard/flutter_screenguard.dart';
```

### Basic Setup

```dart
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final FlutterScreenguard _screenguard;
  final GlobalKey _globalKey = GlobalKey();
  StreamSubscription? _screenshotSub;
  StreamSubscription? _recordingSub;

  @override
  void initState() {
    super.initState();
    // Pass globalKey if you plan to use registerWithBlurView
    _screenguard = FlutterScreenguard(globalKey: _globalKey);
    _initScreenGuard();
  }

  Future<void> _initScreenGuard() async {
    // ① Initialize settings (required before calling any register method)
    await _screenguard.initSettings(
      displayOverlay: true,
      displayScreenguardOverlayAndroid: true,
      timeAfterResume: 2000,
    );

    // Listen for screenshot events
    _screenshotSub = _screenguard.onScreenshotCaptured.listen((event) {
      debugPrint('Screenshot captured: $event');
    });

    // Listen for screen recording events
    _recordingSub = _screenguard.onScreenRecordingCaptured.listen((event) {
      debugPrint('Recording event: $event');
    });

    // ④ Activate screen protection (pick one)
    await _screenguard.register(color: Colors.black);
  }

  @override
  void dispose() {
    _screenguard.unregister();
    _screenshotSub?.cancel();
    _recordingSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: _globalKey,  // Required for blur effect
      child: Scaffold(
        body: Center(child: Text('Protected Content')),
      ),
    );
  }
}
```

> [!NOTE]
> You must call `initSettings()` **before** any `register*` method, or an exception will be thrown.

---

## 📖 API Reference

### `initSettings`

Initialize the screen guard with configuration options. **Must be called first.**

```dart
await _screenguard.initSettings(
  enableCapture: false,
  enableRecord: false,
  enableContentMultitask: false,
  displayOverlay: false,
  displayScreenguardOverlayAndroid: true,
  timeAfterResume: 1000,
  getScreenshotPath: false,
  limitCaptureEvtCount: 0,
  trackingLog: false,
);
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `enableCapture` | `bool?` | `false` | Enable screenshot capture detection |
| `enableRecord` | `bool?` | `false` | Enable screen recording detection |
| `enableContentMultitask` | `bool?` | `false` | Show content in multitask/app switcher *(iOS only)* |
| `displayOverlay` | `bool?` | `false` | Display overlay when user captures the screen *(iOS only)* |
| `displayScreenguardOverlayAndroid` | `bool?` | `true` | Display overlay when returning from background *(Android only)* |
| `timeAfterResume` | `int?` | `1000` | Delay (ms) before the overlay disappears when returning to the app |
| `getScreenshotPath` | `bool?` | `false` | Include file path in screenshot event data |
| `limitCaptureEvtCount` | `int?` | `0` | Max number of screenshot events to trigger (`0` = unlimited) |
| `trackingLog` | `bool?` | `false` | Save events to native storage for later retrieval |

---

### `register`

Activate screen protection with a **solid color** overlay.

![flt_sg_color](https://github.com/user-attachments/assets/ae6a060f-0e40-4b48-ae52-a87da3b7077e)


```dart
await _screenguard.register(color: Colors.red);
```

```dart
await _screenguard.register(color: Color(0xFFFFFC31));
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `color` | `Color` | ✅ | Background color for the protection overlay |

---

### `registerWithBlurView`

Activate screen protection with a **blurred snapshot** of the current screen.

> [!IMPORTANT]
> You must wrap your root widget with `RepaintBoundary` and pass its `GlobalKey` to `FlutterScreenguard` (via constructor or method parameter).

![fpt_sg_blur](https://github.com/user-attachments/assets/ee1e1415-53a7-4de1-808d-4de388359a0a)


```dart
// GlobalKey provided in constructor
await _screenguard.registerWithBlurView(radius: 25);

// Or provide GlobalKey per-call
await _screenguard.registerWithBlurView(radius: 25, globalKey: myKey);
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `radius` | `num` | ✅ | Blur radius. Recommended range: **15–50** |
| `globalKey` | `GlobalKey?` | — | Override the key passed in the constructor |

> [!TIP]
> A radius below **15** is too subtle — content remains readable. Above **50** is overkill — content shrinks and disappears. The sweet spot is **15–50**.

---

### `registerWithImage`

Activate screen protection with a **custom image** overlay.

Uses [SDWebImage](https://github.com/SDWebImage/SDWebImage) on iOS and [Glide](https://github.com/bumptech/glide) on Android for fast loading and caching.

![flt_sg_img](https://github.com/user-attachments/assets/970cd9fb-047b-415c-bcd5-d3fbc2719e0c)


```dart
await _screenguard.registerWithImage(
  uri: 'https://example.com/logo.png',
  width: 150,
  height: 300,
  alignment: Alignment.center,
  color: Colors.black,
);
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `uri` | `String` | ✅ | URL of the image to display |
| `width` | `double` | ✅ | Width of the image |
| `height` | `double` | ✅ | Height of the image |
| `color` | `Color?` | — | Background color (default: `Colors.black`) |
| `alignment` | `Alignment?` | — | Image position using Flutter [Alignment](https://api.flutter.dev/flutter/painting/Alignment-class.html) constants |
| `top` | `double?` | — | Custom top position |
| `left` | `double?` | — | Custom left position |
| `bottom` | `double?` | — | Custom bottom position |
| `right` | `double?` | — | Custom right position |

> [!NOTE]
> `alignment` takes priority over manual positioning (`top`, `left`, `bottom`, `right`). Set `alignment` to `null` if you want to use custom positions.

---

### `registerWithoutEffect`

Activate screen protection **without any visual overlay**. *(Android only)*

```dart
await _screenguard.registerWithoutEffect();
```

---

### `unregister`

Deactivate all screen protection and clean up.

```dart
await _screenguard.unregister();
```

---

### `onScreenshotCaptured`

A `Stream<Map<String, dynamic>>` that emits events when a screenshot is captured.

```dart
_screenguard.onScreenshotCaptured.listen((event) {
  debugPrint('Screenshot: $event');
  // event may contain: path, name, type (if getScreenshotPath is enabled)
});
```

---

### `onScreenRecordingCaptured`

A `Stream<Map<String, dynamic>>` that emits events when screen recording starts or stops.

```dart
_screenguard.onScreenRecordingCaptured.listen((event) {
  final isRecording = event['isRecording'] as bool;
  debugPrint('Recording: $isRecording');
});
```

| Key | Type | Description |
|-----|------|-------------|
| `isRecording` | `bool` | `true` = recording started, `false` = recording stopped |
| `activationStatus` | `Map` | Contains `method` (String) and `isActivated` (bool) |

---

### `getScreenGuardLogs`

Retrieve stored event logs from native storage. Requires `trackingLog: true` in `initSettings`.

```dart
final logs = await _screenguard.getScreenGuardLogs(maxCount: 50);
for (final log in logs) {
  debugPrint('Log: $log');
}
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `maxCount` | `int` | ✅ | Maximum number of log entries to retrieve |

---

## 🧪 Testing

### iOS Simulator

Navigate to **Device → Trigger Screenshot** in the Simulator menu (iOS 14+).

### Android Emulator

- Use an emulator with **Google Play Services** and install a third-party screenshot/recording app (e.g., XRecorder, AZ Screen Recorder).
- Android 12+ emulators have built-in screenshot and screen recording in the **Quick Settings Panel**.

---

## ⚡ Limitations

| Limitation | Details |
|------------|---------|
| **Minimum OS** | Screenshot blocking requires **iOS 13+** / **Android 8+** |
| **Single registration** | Call only **one** `register*` method at a time. Call `unregister()` before switching |

---

## 📄 License

MIT License © 2024 [Goosebump](https://github.com/gbumps)

See [LICENSE](LICENSE) for details.
