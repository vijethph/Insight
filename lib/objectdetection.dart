import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;
import 'package:flutter_tts/flutter_tts.dart';

import 'camera.dart';
import 'bndbox.dart';
import 'models.dart';

enum TtsState { playing, stopped }

/*
class ObjectDetection extends StatefulWidget{
  WidgetsFlutterBinding.ensureInitialized();


}

*/

class ObjectDetection extends StatefulWidget {
  final List<CameraDescription> cameras;

  ObjectDetection(this.cameras);

  @override
  _ObjectDetectionState createState() => new _ObjectDetectionState();
}

class _ObjectDetectionState extends State<ObjectDetection> {
  FlutterTts flutterTts;
  TtsState ttsState = TtsState.stopped;

  List<dynamic> _recognitions;
  int _imageHeight = 0;
  int _imageWidth = 0;
  String _model = "";

  @override
  void initState() {
    super.initState();
    initTTS();
    _getVoice("Command Accepted. Detecting Objects");
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

  @override
  void dispose() {
    super.dispose();
    flutterTts.stop();
  }

  void _getVoice(String value) async {
    if (value != null && value.isNotEmpty) {
      if (ttsState != TtsState.playing) {
        var result = await flutterTts.speak(value);
        if (result == 1) setState(() => ttsState = TtsState.playing);
      }
    }
  }

  loadModel() async {
    String res;
    switch (_model) {
      case yolo:
        res = await Tflite.loadModel(
            model: "assets/yolov2_tiny.tflite",
            labels: "assets/yolov2_tiny.txt",
            useGpuDelegate: true);
        break;

      default:
        res = await Tflite.loadModel(
            model: "assets/ssd_mobilenet.tflite",
            labels: "assets/ssd_mobilenet.txt",
            useGpuDelegate: true);
    }
    print(res);
  }

  onSelect(model) {
    setState(() {
      _model = model;
    });
    loadModel();
  }

  setRecognitions(recognitions, imageHeight, imageWidth) {
    if (this.mounted) {
      setState(() {
        _recognitions = recognitions;
        _imageHeight = imageHeight;
        _imageWidth = imageWidth;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    onSelect(ssd);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: const Text('Object Detection'),
      ),
      body: Stack(
        children: [
          Camera(
            widget.cameras,
            _model,
            setRecognitions,
          ),
          BndBox(
              _recognitions == null ? [] : _recognitions,
              math.max(_imageHeight, _imageWidth),
              math.min(_imageHeight, _imageWidth),
              screen.height,
              screen.width,
              _model),
        ],
      ),
    );
  }
}
