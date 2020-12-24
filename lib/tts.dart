import 'package:flutter_tts/flutter_tts.dart';

class TTS {
  FlutterTts flutterTts;

  TTS() {
    flutterTts = FlutterTts();
    flutterTts.setStartHandler(() {
      print("Playing");
    });

    flutterTts.setCompletionHandler(() {
      print("Complete");
    });

    flutterTts.setCancelHandler(() {
      print("Cancel");
    });
  }
  Future speak(String message) async {
    await flutterTts.awaitSpeakCompletion(true);
    await flutterTts.speak(message);
  }

  Future stop() async {
    var result = await flutterTts.stop();
  }

  Future pause() async {
    var result = await flutterTts.pause();
  }
}
