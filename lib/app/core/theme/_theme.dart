import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

ThemeData getTheme() {
    return ThemeData(
        fontFamily: 'Poppins',
        colorScheme: ColorScheme(
          brightness: Brightness.dark,
          primary: CupertinoColors.activeBlue,
          onPrimary: Colors.white,
          secondary: CupertinoColors.activeOrange,
          tertiary: CupertinoColors.activeGreen,
          onTertiary: Colors.black,
          onSecondary: Colors.white,
          error: Colors.red,
          onError: Colors.white,
          surface: Colors.white,
          onSurface: Colors.black,
          surfaceContainer: Colors.grey.shade200,
          onSurfaceVariant: Colors.black,
        ));
  }