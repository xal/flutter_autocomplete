import 'package:flutter/material.dart';
import 'material_app.dart';
import 'cupertino_app.dart';
import 'dart:io' show Platform;


void main() {
  if (Platform.isAndroid) {
    runApp(MyMaterialApp());
  } else if (Platform.isIOS) {
    runApp(MyCupertinoApp());
  }

}
