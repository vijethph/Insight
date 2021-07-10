/*
Waits for the user input in the form of audio and navigates
to specific page based on the given input
 */

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'OCR.dart';
import 'about_page.dart';
import 'textsummarize.dart';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:ripple_animation/ripple_animation.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';

import 'VideoCall.dart';
import 'translation.dart';
import 'objectdetection.dart';
import 'tts.dart';
import 'face_recognition.dart';

List<CameraDescription> cameras;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Position userLocation;

  StreamSubscription _intentDataStreamSubscription;
  String _sharedText = "";

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

  ClientRole _role = ClientRole.Broadcaster;

  Future<Position> _getLocation() async {
    var currentLocation;
    try {
      currentLocation = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
    } catch (e) {
      currentLocation = null;
    }
    return currentLocation;
  }

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
    } else if (lastWords.compareTo("detect objects") == 0) {
      try {
        cameras = await availableCameras();
      } on CameraException catch (e) {
        print('Error: $e.code\nError Message: $e.message');
      }
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ObjectDetection(cameras)),
      );
    } else if (lastWords.compareTo("read text") == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => OCR()),
      );
    } else if (lastWords.compareTo("send my location") == 0) {
      Map<String, String> postData = {
        'latitude': userLocation.latitude.toString(),
        'longitude': userLocation.longitude.toString()
      };
      var url = Uri.parse('https://insightbackend.herokuapp.com/');
      var response = await http.post(url,
          body: postData,
          headers: {
            "Accept": "*/*",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          encoding: Encoding.getByName("utf-8"));
      if (response.statusCode == 200) {
        tts.speak("Your location co-ordinates are sent successfully.");
      } else {
        tts.speak("Sorry. Could not send your location.");
      }
    } else if (lastWords.startsWith("translate")) {
      String sentence = lastWords;

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TranslateText(sentence)),
      );
    } else if (lastWords.compareTo("video call") == 0) {
      var url = Uri.parse('https://insightbackend.herokuapp.com/token');
      var response = await http.get(
        url,
        headers: {
          'Authorization':
              "Token APP_AUTH_TOKEN"  
          },
      );
      if (response.statusCode == 200) {
        String token = response.body;
        // await for camera and mic permissions before pushing video page
        await _handleCameraAndMic(Permission.camera);
        await _handleCameraAndMic(Permission.microphone);
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  VideoCall(channelName: "insight", role: _role, token: token)),
        );
      } else {
        tts.speak("Sorry. Could not make a video call.");
      }
    } else {
      tts.speak("Please provide a valid command");
    }
  }

  Future<void> _handleCameraAndMic(Permission permission) async {
    final status = await permission.request();
    print(status);
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

    _getLocation().then((position) {
      setState(() {
        userLocation = position;
        final snackBar1 = SnackBar(
            content: Text(
          "Location:" +
              userLocation.latitude.toString() +
              " " +
              userLocation.longitude.toString(),
          style: TextStyle(color: Colors.amber),
        ));
        ScaffoldMessenger.of(context).showSnackBar(snackBar1);
      });
    });

    // For sharing or opening urls/text coming from outside the app while the app is in the memory
    _intentDataStreamSubscription =
        ReceiveSharingIntent.getTextStream().listen((String value) {
      if (value?.isNotEmpty ?? false) {
        setState(() {
          _sharedText = value;
          print("Shared: $_sharedText");
        });
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SummarizeText(_sharedText)),
        );
      }
    }, onError: (err) {
      print("getLinkStream error: $err");
    });

    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText().then((String value) {
      if (value?.isNotEmpty ?? false) {
        setState(() {
          _sharedText = value;
          print("Shared: $_sharedText");
        });
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SummarizeText(_sharedText)),
        );
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _intentDataStreamSubscription.cancel();
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
        actions: [
          IconButton(
            icon: Icon(
              Icons.info_outline,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AboutPage()));
            },
          ),
        ],
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
                  child: CircleAvatar(
                    backgroundColor: Colors.blueAccent[700],
                    radius: 120,
                    child: CircleAvatar(
                      backgroundColor: Colors.indigo[900],
                      //foregroundColor: Colors.green,
                      radius: 100,
                      child: Icon(
                        Icons.mic,
                        color: Colors.white,
                        size: 190,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Text(
                  "Tap on screen",
                  style: TextStyle(color: Colors.white, fontSize: 25),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
