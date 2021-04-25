import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'utils.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'DetailScreen.dart';

List<CameraDescription> cameras = [];
enum TtsState { playing, stopped }

class OCR extends StatefulWidget {
  @override
  _OCRState createState() => _OCRState();
}

class _OCRState extends State<OCR> {
  FlutterTts flutterTts;
  TtsState ttsState = TtsState.stopped;

  CameraController _controller;
  CameraLensDirection _direction = CameraLensDirection.back;

  @override
  void initState() {
    super.initState();
    initTTS();
    _getVoice("Command Accepted. Performing OCR to read text");
    _initializeCamera();
  }

  initTTS() {
    flutterTts = new FlutterTts();
    flutterTts.setStartHandler(() {
      setState(() {
        print("Playing");
        ttsState = TtsState.playing;
      });
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        print("Complete");
        ttsState = TtsState.stopped;
      });
    });
    flutterTts.setCancelHandler(() {
      setState(() {
        print("Cancel");
        ttsState = TtsState.stopped;
      });
    });
  }

  void _getVoice(String value) async {
    if (value != null && value.isNotEmpty) {
      if (ttsState != TtsState.playing) {
        var result = await flutterTts.speak(value);
        if (result == 1) setState(() => ttsState = TtsState.playing);
      }
    }
  }

  void _initializeCamera() async {
    CameraDescription description = await getCamera(_direction);
    _controller = CameraController(description, ResolutionPreset.medium);
    _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  void _toggleCameraDirection() async {
    if (_direction == CameraLensDirection.back) {
      _direction = CameraLensDirection.front;
    } else {
      _direction = CameraLensDirection.back;
    }
    await _controller.stopImageStream();
    await _controller.dispose();

    setState(() {
      _controller = null;
    });

    _initializeCamera();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
    flutterTts.stop();
  }

  Future<String> _takePicture() async {
    if (!_controller.value.isInitialized) {
      print("Controller is not initialized");
      return null;
    }

    // Formatting Date and Time
    String dateTime = DateFormat.yMMMd()
        .addPattern('-')
        .add_Hms()
        .format(DateTime.now())
        .toString();

    String formattedDateTime = dateTime.replaceAll(' ', '');
    print("Formatted: $formattedDateTime");

    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String visionDir = '${appDocDir.path}/Photos/Vision\ Images';
    await Directory(visionDir).create(recursive: true);
    String imagePath = '$visionDir/image_$formattedDateTime.jpg';

    if (_controller.value.isTakingPicture) {
      print("Processing is progress ...");
      return null;
    }

    try {
      final image = await _controller.takePicture();
      imagePath = image?.path;
    } on CameraException catch (e) {
      print("Camera Exception: $e");
      return null;
    }

    return imagePath;
  }

  Widget _buildImage() {
    if (_controller == null || !_controller.value.isInitialized) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return Container(
      constraints: const BoxConstraints.expand(),
      child: _controller == null
          ? const Center(child: null)
          : Stack(
              fit: StackFit.expand,
              children: <Widget>[
                CameraPreview(_controller),
              ],
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('ML Vision'),
        ),
        body: GestureDetector(
          child: _buildImage(),
          onLongPress: () async {
            await _takePicture().then((String path) {
              if (path != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailScreen(path),
                  ),
                );
              }
            });
          },
          onDoubleTap: _toggleCameraDirection,
        ));
  }
}
