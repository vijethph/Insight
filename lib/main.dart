import 'package:flutter/material.dart';
import 'authentication.dart';

void main() {
  runApp(
    MaterialApp(
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: Authentication(),
      title: "Insight",
    ),
  );
}
