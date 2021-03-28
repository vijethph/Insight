/*
Waits for the user input in the form of audio and navigates
to specific page based on the given input
 */

import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:ripple_animation/ripple_animation.dart';
import 'objectdetection.dart';
import 'tts.dart';
import 'face_recognition.dart';

List<CameraDescription> cameras;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TTS tts = new TTS();

  bool _hasSpeech = false;
  double level = 0.0;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;
  String lastWords = '';
  String lastError = '';
  String lastStatus = '';
  String _currentLocaleId = '';
  int resultListened = 0;
  List<LocaleName> _localeNames = [];
  final SpeechToText speech = SpeechToText();

  Future<void> initSpeechState() async {
    var hasSpeech = await speech.initialize(
        onError: errorListener, onStatus: statusListener, debugLogging: true);
    if (hasSpeech) {
      _localeNames = await speech.locales();

      var systemLocale = await speech.systemLocale();
      _currentLocaleId = systemLocale.localeId;
    }

    if (!mounted) return;

    setState(() {
      _hasSpeech = hasSpeech;
    });
  }

  void startListening() {
    lastWords = '';
    lastError = '';
    speech.listen(
        onResult: resultListener,
        listenFor: Duration(seconds: 5),
        pauseFor: Duration(seconds: 5),
        partialResults: false,
        localeId: _currentLocaleId,
        onSoundLevelChange: soundLevelListener,
        cancelOnError: true,
        listenMode: ListenMode.confirmation);
    setState(() {});
  }

  void stopListening() {
    speech.stop();
    setState(() {
      level = 0.0;
    });
  }

  void cancelListening() {
    speech.cancel();
    setState(() {
      level = 0.0;
    });
  }

  Future<void> resultListener(SpeechRecognitionResult result) async {
    ++resultListened;
    print('Result listener $resultListened');
    setState(() {
      lastWords = '${result.recognizedWords}';
    });
    if (lastWords.compareTo("recognise face") == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => FaceRecognition()),
      );
    }
    else if (lastWords.compareTo("detect objects") == 0) {
      try {
        cameras = await availableCameras();
      } on CameraException catch (e) {
        print('Error: $e.code\nError Message: $e.message');
      }
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ObjectDetection(cameras)),
      );
    }
    else{
      tts.speak("Please provide a valid command");
    }
  }

  void soundLevelListener(double level) {
    minSoundLevel = min(minSoundLevel, level);
    maxSoundLevel = max(maxSoundLevel, level);
    // print("sound level $level: $minSoundLevel - $maxSoundLevel ");
    setState(() {
      this.level = level;
    });
  }

  void errorListener(SpeechRecognitionError error) {
    // print("Received error status: $error, listening: ${speech.isListening}");
    setState(() {
      lastError = '${error.errorMsg} - ${error.permanent}';
    });
  }

  void statusListener(String status) {
    // print('Received listener status: $status, listening: ${speech.isListening}');
    setState(() {
      lastStatus = '$status';
    });
  }

  @override
  void initState() {
    super.initState();
    tts.speak("Welcome to Insight. Please provide the command.");
    if (!_hasSpeech) initSpeechState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    tts.stop();
    if (speech.isListening) stopListening();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: const Text('Insight'),
      ),
      body: Container(
        child: GestureDetector(
          onTap: !_hasSpeech || speech.isListening
              ? stopListening
              : startListening,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RippleAnimation(
                    repeat: true,
                    key: UniqueKey(),
                    color: Colors.lightBlue,
                    minRadius: 100,
                    ripplesCount: 6,
                    child: Icon(
                      Icons.mic,
                      color: Colors.white,
                      size: 250,
                    ),
                ),

                Text(
                  "Tap on screen",
                  style: TextStyle(color: Colors.white, fontSize: 25),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
