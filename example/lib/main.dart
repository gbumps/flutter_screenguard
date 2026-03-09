import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:flutter_screenguard/flutter_screenguard.dart';

void main() {
  runApp(const MaterialApp(localizationsDelegates: [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ], supportedLocales: [
    Locale('en', 'US'), // English
  ], home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late FlutterScreenguard _flutterScreenguardPlugin;
  late TextEditingController textController;
  final GlobalKey globalKey = GlobalKey();

  late int selection;
  StreamSubscription? _screenshotSubscription;

  @override
  void initState() {
    super.initState();
    _flutterScreenguardPlugin = FlutterScreenguard(globalKey: globalKey);
    selection = -1;
    textController = TextEditingController();
  }

  Future<void> _initScreenGuard() async {
    await _flutterScreenguardPlugin.initSettings(
      displayOverlay: true,
      displayScreenguardOverlayAndroid: true,
      limitCaptureEvtCount: 4,
      timeAfterResume: 5000
    );
    _screenshotSubscription =
        _flutterScreenguardPlugin.onScreenshotCaptured.listen((event) {
      debugPrint("Screenshot captured: $event");
    });
  }

  @override
  void dispose() {
    _flutterScreenguardPlugin.unregister();
    _screenshotSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: globalKey,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Test screenguard'),
        ),
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  await _initScreenGuard();
                },
                child: const Text('Init Settings'),
              ),
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    selection = 0;
                  });
                  await _flutterScreenguardPlugin.register(color: Colors.red);
                },
                child: Text(
                  'Activate with color ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: selection == 0 ? Colors.green : Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(
                height: 14,
              ),
              ElevatedButton(
                onPressed: () async {
                  await _flutterScreenguardPlugin.registerWithBlurView(
                    radius: 15,
                    globalKey: globalKey,
                  );
                  setState(() {
                    selection = 1;
                  });
                },
                child: Text(
                  'Activate with blurview',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: selection == 1 ? Colors.green : Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(
                height: 14,
              ),
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    selection = 2;
                  });
                  await _flutterScreenguardPlugin.registerWithImage(
                    uri:
                        'https://image.shutterstock.com/image-photo/red-mum-flower-photography-on-260nw-2533542589.jpg',
                    width: 150,
                    height: 300,
                    alignment: Alignment.topCenter,
                    color: Colors.green,
                  );
                },
                child: Text(
                  'Activate with image',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: selection == 2 ? Colors.green : Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(
                height: 14,
              ),
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    selection = 3;
                  });
                  await _flutterScreenguardPlugin.unregister();
                },
                child: Text(
                  'Deactivate screen blocking',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selection == 3 ? Colors.green : Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(
                height: 14,
              ),
              const SizedBox(
                height: 14,
              ),
              TextFormField(
                controller: textController,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
