import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_screenguard/flutter_screenguard.dart';
import 'package:flutter_screenguard/flutter_screenguard_screen_record_event.dart';
import 'package:flutter_screenguard/flutter_screenguard_screenshot_event.dart';

void main() {
  runApp(const MyApp());
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

  late int selection;

  @override
  void initState() {
    super.initState();
    _flutterScreenguardPlugin = FlutterScreenguard();
    _flutterScreenguardScreenshotListener = FlutterScreenguardScreenshotEvent();
    _flutterScreenguardScreenshotListener.addListener(() {
      //add listener when a screenshot is triggered
      debugPrint('1234: screenshot detected!');
    });
    selection = -1; // initPlatformState();
  }

  @override
  void dispose() {
    super.dispose();
    _flutterScreenguardPlugin.unregister();
    _flutterScreenguardScreenshotListener.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Test screenguard'),
        ),
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () async {
                  await _flutterScreenguardPlugin.register(color: Colors.green);
                  setState(() {
                    selection = 0;
                  });
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
              InkWell(
                onTap: () async {
                  await _flutterScreenguardPlugin.registerWithBlurView(
                      radius: 18,
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
              InkWell(
                onTap: () async {
                  await _flutterScreenguardPlugin.registerWithImage(
                    uri:
                        'https://lh3.googleusercontent.com/blogger_img_proxy/AEn0k_uyWh3jBn3GEzf8AINr-3AoffbUXdml95nPjgjpu-amM4xjOi2L6fi6VmGcMHXLRuGXpklc3lXksPu1NKIOrzhbeHBgGVl3Fxi5f7sr8w5yGF-oTWXx-kJTrD8TTlRi96jPEXq4qzhtJd32hNtQ_F7J=w919-h516-p-k-no-nu',
                    width: 150,
                    height: 300,
                    alignment: Alignment.topCenter,
                    timeAfterResume: const Duration(milliseconds: 2000),
                    color: Colors.green,
                  );
                  setState(() {
                    selection = 2;
                  });
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
              InkWell(
                onTap: () async {
                  _flutterScreenguardPlugin.unregister();
                  setState(() {
                    selection = 3;
                  });
                },
                child: Text(
                  'unregister',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selection == 3 ? Colors.green : Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
