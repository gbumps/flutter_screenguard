// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:path/path.dart' as path;
import 'dart:typed_data';

class FlutterScreenguardHelper {
  static Future<String?> captureAsUiImage(
      {double? pixelRatio = 1,
     required GlobalKey globalKey,
      Duration delay = const Duration(milliseconds: 40)}) {
    return Future.delayed(delay, () async {
      try {
        var findRenderObject = globalKey.currentContext?.findRenderObject();
        if (findRenderObject == null) {
          return null;
        }
        RenderRepaintBoundary boundary =
            findRenderObject as RenderRepaintBoundary;
        BuildContext? context = globalKey.currentContext;
        if (pixelRatio == null) {
          if (context != null) {
            // ignore: use_build_context_synchronously
            pixelRatio = pixelRatio ?? MediaQuery.of(context).devicePixelRatio;
          }
        }
        ui.Image image = await boundary.toImage(pixelRatio: pixelRatio ?? 1);
        ByteData? byteData =
            await image.toByteData(format: ui.ImageByteFormat.png);
        image.dispose();

        Uint8List? pngBytes = byteData?.buffer.asUint8List();
        if (pngBytes != null) {
          final Directory cacheDir = await Directory.systemTemp.createTemp();
          final String filePath = path.join(cacheDir.path,
              'screenguard_${DateTime.now().millisecondsSinceEpoch}.png');

          final File file = File(filePath);
          await file.writeAsBytes(pngBytes);

          return filePath;
        }
        return null;
      } catch (e) {
        return null;
      }
    });
  }
}