# flutter_screenguard

A Native screenshot blocking plugin for Flutter developer, with background customizable after captured. Screenshot detector are also supported.

## Requirements

- Flutter >=3.7.0
- Dart >=3.4.0 <4.0.0
- iOS >=12.0
- Android compileSDK 34
- Java 17
- Android Gradle Plugin >=8.3.0
- Gradle wrapper >=7.6

## Installation

To use this plugin, add `flutter_screenguard` as a dependency in your `pubspec.yaml` file

```
dependencies:
   flutter_screenguard: ^1.0.0
```

Or you can run this command to install it from the flutter pub.

```shell
flutter pub add flutter_screenguard
```

## Usage

import the plugin as follow

```dart
import 'package:flutter_screenguard/flutter_screenguard.dart';
```

then, create an instance of `FlutterScreenguard` as such 

```dart
import 'package:flutter_screenguard/flutter_screenguard.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  late final FlutterScreenguard _flutterScreenguardPlugin;
  
  @override
  void initState() {
    super.initState();
    _flutterScreenguardPlugin = FlutterScreenguard();
  }
}
```

### register

Activate the screenguard with your custom background color layout.

```dart
  await _flutterScreenguardPlugin.register(
    color: Colors.red,
  );
```

```dart
  await _flutterScreenguardPlugin.register(
    color: Color(0xFFFFFC31),
    timeAfterResume: const Duration(milliseconds: 2500),
  );
``` 

```dart
  await _flutterScreenguardPlugin.register(
    color: Color.fromRGBO(178, 178, 178, 1),
    timeAfterResume: const Duration(milliseconds: 3000),
  );
```

#### Parameters:

- **color**: The background color you want to display from, [Colors class](https://api.flutter.dev/flutter/material/Colors-class.html)

- **timeAfterResume (Android only)**: A small amount of time (in milliseconds) for the view to disappear before jumping back to the main application view.

### registerWithBlurView

Activate screenguard with a blurred effect view after captured.

Blurview on Android using [Blurry](https://github.com/wasabeef/Blurry).

(Remember to register the instance with a GlobalKey before proceed!)

```dart
import 'package:flutter_screenguard/flutter_screenguard.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  late final FlutterScreenguard _flutterScreenguardPlugin;

  final GlobalKey globalKey = GlobalKey();
  
  @override
  void initState() {
    super.initState();
    _flutterScreenguardPlugin = FlutterScreenguard(globalKey: globalKey);
  }
}
```

then use as such

```dart
await _flutterScreenguardPlugin.registerWithBlurView(
    radius: 6,
    timeAfterResume: const Duration(milliseconds: 2000));
```

#### Parameters:

- **radius**: blur radius value number in between [15, 50], throws warning if smaller than 15 or bigger than 50, exception if smaller than 1 or not a number.

- **timeAfterResume (Android only)**: A small amount of time (in milliseconds) for the view to disappear before jumping back to the main application view.


### registerWithImage

Activate screenguard with a custom image view and background color.

ImageView using SDWebImage on iOS and Glide on Android for faster loading and caching.

```dart
  await _flutterScreenguardPlugin.registerWithImage(
    uri: 'https://image.shutterstock.com/image-photo/red-mum-flower-photography-on-260nw-2533542589.jpg',
    width: 150,
    height: 300,
    alignment: Alignment.topCenter,
    timeAfterResume: const Duration(milliseconds: 2000),
    color: Colors.green,
  );
```

#### Parameters:

- **width**	  Width of the image

- **height**	Heigh of the image

- **uri**	Source uri of the image

- **color**: The background color you want to display from, [Colors class](https://api.flutter.dev/flutter/material/Colors-class.html)

- **alignment**	 Position of image predefined in library 

- **timeAfterResume (Android only)**: A small amount of time (in milliseconds) for the view to disappear before jumping back to the main application view.

- **top**  Top position of the image

- **left** Left position of the image

- **bottom**	Bottom of the image

- **right**	Right of the image

### registerWithoutEffect

(Android only) Activate screenguard without any effect above for Android only.

### registerScreenShotEventListener

Activate a screenshot detector and receive an event callback with screenshot information (if allowed) after a screenshot has been triggered successfully.

```dart
import 'package:flutter_screenguard/flutter_screenguard_screenshot_event.dart';
```

then, create an instance of `FlutterScreenguardScreenshotEvent` as such 

```dart
import 'package:flutter_screenguard/flutter_screenguard.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  late final FlutterScreenguardScreenshotEvent
      _flutterScreenguardScreenshotListener;
  
  @override
  void initState() {
    super.initState();
    _flutterScreenguardScreenshotListener =
        FlutterScreenguardScreenshotEvent(getScreenshotData: false)
          ..initialize();
  }
}
```
then use as such 

```dart

  _flutterScreenguardScreenshotListener.addListener(
    () {
      FileCaptureDetail? data =
          _flutterScreenguardScreenshotListener.value;
      debugPrint(
        'path: ${data?.path}',
      );
      debugPrint(
        'name: ${data?.name}',
      );
      debugPrint(
        'type: ${data?.type}',
      );
    },
  );
```


If true, callback will return a `FileCaptureDetail` object containing info of the previous image screenshot.

If false, callback will return null.

### registerRecordingEventListener

(iOS only) Activate a screen recording detector and receive an event callback after a record has done.


```dart
import 'package:flutter_screenguard/flutter_screenguard_screen_record_event.dart';
```

then, create an instance of `FlutterScreenguardScreenshotEvent` as such 

```dart
import 'package:flutter_screenguard/flutter_screenguard.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  late final FlutterScreenguardScreenRecordingEvent
      _flutterScreenguardScreenRecordingListener;
  
  @override
  void initState() {
    super.initState();
    _flutterScreenguardScreenRecordingEvent =
        FlutterScreenguardScreenRecordingEvent()
          ..initialize();
  }
}
```
then use as such 

```dart
  _flutterScreenguardScreenRecordingEvent.addListener(
    () {
      debugPrint(
        'screen is recording!',
      );
    },
  );
```


### unregister

deactivate the screenguard 

```dart
  await _flutterScreenguardPlugin.unregister();
```
