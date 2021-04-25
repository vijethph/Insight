import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';

enum TtsState { playing, stopped }

class SummarizeText extends StatefulWidget {
  final String _sharedText;
  SummarizeText(this._sharedText);

  @override
  _SummarizeTextState createState() => _SummarizeTextState(_sharedText);
}

class _SummarizeTextState extends State<SummarizeText> {
  _SummarizeTextState(this._sharedText);

  final String _sharedText;
  String resultText = "nothing";

  FlutterTts flutterTts;
  TtsState ttsState = TtsState.stopped;

  @override
  void initState() {
    super.initState();
    initTTS();
    summarize();
  }

  void summarize() async {
    if (_sharedText.startsWith("http")) {
      _getVoice("Summarizing Article in URL");
      Map<String, String> postData = {'url': _sharedText, 'length': '0.1'};
      var url = Uri.parse('https://insightbackend.herokuapp.com/url/');
      var response = await http.post(url,
          body: postData,
          headers: {
            "Accept": "*/*",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          encoding: Encoding.getByName("utf-8"));
      if (response.statusCode == 200) {
        //print(response.body);
        setState(() {
          resultText = response.body;
        });
        _getVoice(resultText);
      } else {
        _getVoice("Request failed for URL. Please try again.");
      }
    } else {
      _getVoice("Summarizing Text.");
      Map<String, String> postData = {'text': _sharedText, 'length': '0.1'};
      var url = Uri.parse('https://insightbackend.herokuapp.com/url/');
      var response = await http.post(url,
          body: postData,
          headers: {
            "Accept": "*/*",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          encoding: Encoding.getByName("utf-8"));
      if (response.statusCode == 200) {
        //print(response.body);
        setState(() {
          resultText = response.body;
        });
        _getVoice(resultText);
      } else {
        _getVoice("Request failed for text. Please try again.");
      }
    }
  }

  void _getVoice(String value) async {
    if (value != null && value.isNotEmpty) {
      if (ttsState != TtsState.playing) {
        var result = await flutterTts.speak(value);
        if (result == 1) setState(() => ttsState = TtsState.playing);
      }
    }
  }

  @override
  void dispose() {
    super.dispose();

    flutterTts.stop();
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Summarize Text Results")),
      body: SafeArea(
        child: Center(
          child: resultText == "nothing"
              ? CircularProgressIndicator()
              : SingleChildScrollView(
                  reverse: true,
                  child: Container(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      resultText,
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
