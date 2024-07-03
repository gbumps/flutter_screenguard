import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_screenguard/flutter_screenguard.dart';

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
  late int selection;

  @override
  void initState() {
    super.initState();
    _flutterScreenguardPlugin = FlutterScreenguard();
    selection = -1; // initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    if (!mounted) return;
  }

  @override
  void dispose() {
    super.dispose();
    _flutterScreenguardPlugin.unregister();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
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
                      radius: 20);
                  setState(() {
                    selection = 1;
                  });
                },
                child: Text(
                  'Activate with blurview: ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selection == 1 ? Colors.green : Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(
                height: 14,
              ),
              InkWell(
                onTap: () async {
                  await _flutterScreenguardPlugin.unregister();
                  setState(() {
                    selection = 2;
                  });
                },
                child: Text(
                  'unregister',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selection == 2 ? Colors.green : Colors.black,
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
