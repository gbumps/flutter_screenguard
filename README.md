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
_flutterScreenguardPlugin.register(color: "#FFF", timeAfterResume: Timer);
```






