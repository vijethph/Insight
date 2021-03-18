import 'package:flutter/material.dart';
import 'authentication.dart';

void main() {
  runApp(
    MaterialApp(
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: Authentication(),
      title: "Insight",
    ),
  );
}
