import 'package:Face_recognition/homepage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:local_auth/local_auth.dart';
import 'tts.dart';
import 'homepage.dart';

class Authentication extends StatefulWidget {
  @override
  _AuthenticationState createState() => _AuthenticationState();
}

class _AuthenticationState extends State<Authentication> {
  final LocalAuthentication auth = LocalAuthentication();
  TTS tts = new TTS();
  bool _authorized = false;

  Future<bool> _authenticate() async {
    bool authenticated = false;
    try {
      authenticated = await auth.authenticateWithBiometrics(
          localizedReason: 'Authenticate:',
          useErrorDialogs: true,
          stickyAuth: true);
      print("Authorised");
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return false;

    setState(() {
      _authorized = authenticated ? true : false;
    });
  }

  void _cancelAuthentication() {
    auth.stopAuthentication();
  }

  @override
  void initState() {
    tts.speak("Please authenticate using finger print.");
    _authenticate();
    super.initState();
  }

  @override
  void dispose() {
    _cancelAuthentication();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_authorized)
      return MaterialApp(home: HomePage());
    else
      return MaterialApp(home: Screen());
  }
}

class Screen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
