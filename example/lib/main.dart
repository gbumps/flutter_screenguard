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

  @override
  void initState() {
    super.initState();
    _flutterScreenguardPlugin = FlutterScreenguard();
    // initPlatformState();
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
        body: Column(
          children: [
            InkWell(
              onTap: () async {
                await _flutterScreenguardPlugin.register(color: Colors.green);
              },
              child: const Text('Activate with color: '),
            ),
            const SizedBox(
              height: 14,
            ),
            InkWell(
              onTap: () async {
                await _flutterScreenguardPlugin.registerWithBlurView(
                    radius: 20);
              },
              child: const Text('Activate with blur : '),
            ),
            const SizedBox(
              height: 14,
            ),
            InkWell(
              onTap: () async {
                await _flutterScreenguardPlugin.unregister();
              },
              child: Text('unregister'),
            ),
          ],
        ),
      ),
    );
  }
}
