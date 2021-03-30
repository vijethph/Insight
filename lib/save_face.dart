/*
On tap accepts the name from the user and saves the recognised face with the name
as mentioned by the user.
 */
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SaveFace extends StatefulWidget {
  final List el;
  final File jsonFile;
  final dynamic data;
  SaveFace(this.el, this.data, this.jsonFile);
  @override
  _SaveFaceState createState() => _SaveFaceState();
}

class _SaveFaceState extends State<SaveFace> {
  //Speech to text
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

  //Speech to text
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

  void resultListener(SpeechRecognitionResult result) {
    ++resultListened;
    print('Result listener $resultListened');
    setState(() {
      lastWords = '${result.recognizedWords}';
    });
    //print(lastWords);
    widget.data[lastWords] = widget.el;
    widget.jsonFile.writeAsStringSync(json.encode(widget.data));
    Navigator.pop(context);
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
    if (!_hasSpeech) initSpeechState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: const Text('Add Face'),
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
                Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 250,
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
      backgroundColor: Colors.blueGrey,
    );
  }
}
