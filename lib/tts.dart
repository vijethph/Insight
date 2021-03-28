import 'package:flutter_tts/flutter_tts.dart';

enum TtsState { playing, stopped, paused, continued }

class TTS {
  FlutterTts flutterTts;
  TtsState ttsState = TtsState.stopped;

  TTS() {
    flutterTts = FlutterTts();
    flutterTts.setStartHandler(() {
      print("Playing");
      ttsState = TtsState.playing;
    });

    flutterTts.setCompletionHandler(() {
      print("Complete");
      ttsState = TtsState.stopped;
    });

    flutterTts.setCancelHandler(() {
      print("Cancel");
      ttsState = TtsState.stopped;
    });
  }
  Future speak(String message) async {
    await flutterTts.awaitSpeakCompletion(true);
    if (message != null && message.isNotEmpty) await flutterTts.speak(message);
  }

  Future stop() async {
    var result = await flutterTts.stop();
    if (result == 1) ttsState = TtsState.stopped;
  }

  Future pause() async {
    var result = await flutterTts.pause();
    if (result == 1) ttsState = TtsState.paused;
  }
}
