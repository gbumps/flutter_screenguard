import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:flutter_screenguard/flutter_screenguard.dart';
import 'package:flutter_screenguard/flutter_screenguard_screen_record_event.dart';
import 'package:flutter_screenguard/flutter_screenguard_screenshot_event.dart';

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
  late final FlutterScreenguard _flutterScreenguardPlugin;
  late final FlutterScreenguardScreenshotEvent
      _flutterScreenguardScreenshotListener;
  late final FlutterScreenguardScreenRecordingEvent
      _flutterScreenguardScreenRecordingEvent;
  late TextEditingController textController;
  final GlobalKey globalKey = GlobalKey();

  late int selection;

  @override
  void initState() {
    super.initState();
    _flutterScreenguardPlugin = FlutterScreenguard(globalKey: globalKey);
    _flutterScreenguardScreenshotListener =
        FlutterScreenguardScreenshotEvent(getScreenshotData: true)
          ..initialize();
    _flutterScreenguardScreenRecordingEvent =
        FlutterScreenguardScreenRecordingEvent()..initialize();
    selection = -1;
    textController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _flutterScreenguardPlugin.unregister();
    _flutterScreenguardScreenshotListener.dispose();
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
                      radius: 6,
                      timeAfterResume: const Duration(milliseconds: 2000));
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
                    timeAfterResume: const Duration(milliseconds: 2000),
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
                  'deactivate screen blocking',
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
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    selection = 4;
                  });
                  _flutterScreenguardScreenshotListener.addListener(
                    () {
                      showDialog<void>(
                        context: context,
                        barrierDismissible: true, // user must tap button!
                        builder: (BuildContext context) {
                          FileCaptureDetail? d =
                              _flutterScreenguardScreenshotListener.value;
                          return AlertDialog(
                            title: const Text('Screenshot capture'),
                            content: SingleChildScrollView(
                              child: ListBody(
                                children: <Widget>[
                                  Text('path: ${d?.path}'),
                                  Text(
                                    'name: ${d?.name}',
                                  ),
                                  Text(
                                    'type: ${d?.type}',
                                  )
                                ],
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('OK'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
                child: Text(
                  'Activate screenshot listener',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: selection == 4 ? Colors.green : Colors.black,
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
                    selection = 5;
                  });
                  _flutterScreenguardScreenshotListener.dispose();
                },
                child: Text(
                  'deactivate screenshot listener',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: selection == 5 ? Colors.green : Colors.black,
                    fontSize: 16,
                  ),
                ),
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
