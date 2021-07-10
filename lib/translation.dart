import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ibm_watson/services/textToSpeech.dart';
import 'package:flutter_ibm_watson/utils/IamOptions.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:translator/translator.dart';

enum TtsState { playing, stopped }

class TranslateText extends StatefulWidget {
  final String sentence;
  TranslateText(this.sentence);

  @override
  _TranslateTextState createState() => _TranslateTextState(sentence);
}

class _TranslateTextState extends State<TranslateText> {
  final String sentence;
  String resultText = "nothing";
  String bodyTranslate = "nothing";
  String transLang = "Kannada";
  _TranslateTextState(this.sentence);

  FlutterTts flutterTts;
  TtsState ttsState = TtsState.stopped;

  IamOptions options;
  AudioPlayer audioPlayer;
  TextToSpeech service;
  List<Voice> availableVoices;

  Future<Null> _getOptions() async {
    this.options = await IamOptions(
            iamApiKey: "IBM_API_KEY",
            url:
                "IBM_WATSON_URL")
        .build();
    print(this.options.accessToken);
  }

  Future<void> _getIBMSpeech(String translatedText, Voice desiredVoice) async {
    if (translatedText != null && translatedText.isNotEmpty) {
      print(translatedText +
          " " +
          desiredVoice.name +
          " " +
          desiredVoice.description);
      service.setVoice(desiredVoice.name);
      Uint8List voiceResult = await service.toSpeech(translatedText);

      if (voiceResult != null) {
        int outcome = await audioPlayer.playBytes(voiceResult);
        print("IBM Result:" + outcome.toString());
      } else {
        print("oh no.. no result");
      }
    }
  }

  Future<void> _initIBMVoice() async {
    await _getOptions();
    service = new TextToSpeech(iamOptions: this.options);

    availableVoices = await service.getListVoices();
    print(availableVoices);

    // for(Voice voiced in listVoice){
    //   print(voiced.name + " " + voiced.description + " " + voiced.gender + " " + voiced.language);
    //   print("------------");
    // }
  }

  @override
  void initState() {
    super.initState();
    initTTS();

    audioPlayer = AudioPlayer();

    List<String> words = sentence.split(" ");
    String lang = words[words.length - 1];
    final startIndex = sentence.indexOf("translate");
    final endIndex = sentence.lastIndexOf("to");
    setState(() {
      bodyTranslate = sentence.substring(startIndex + 10, endIndex);
      transLang = lang;
    });
    _getVoice("Command Accepted. Translating");
    performTranslation(bodyTranslate, transLang);
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

  void performTranslation(String content, String language) async {
    String langcode;
    String voiceName;
    switch (language) {
      case 'French':
        {
          langcode = "fr";
          voiceName = "fr-FR_NicolasV3Voice";
        }
        break;
      case 'Spanish':
        {
          langcode = "es";
          voiceName = "es-ES_EnriqueV3Voice";
        }
        break;
      case 'Italian':
        {
          langcode = "it";
          voiceName = "it-IT_FrancescaV3Voice";
        }
        break;
      case 'Japanese':
        {
          langcode = "ja";
          voiceName = "ja-JP_EmiV3Voice";
        }
        break;
      case 'Hindi':
        {
          langcode = "hi";
          voiceName = "en-US_AllisonV3Voice";
        }
        break;
      case 'Kannada':
        {
          langcode = "kn";
          voiceName = "en-US_AllisonV3Voice";
        }
        break;
      default:
        {
          langcode = "kn";
          voiceName = "en-US_AllisonV3Voice";
        }
        break;
    }
    try {
      final translator = GoogleTranslator();
      final input = content;
      var translation =
          await translator.translate(input, from: 'en', to: langcode);
      print(translation);
      print(translation.text);

      setState(() {
        resultText = translation.text;
      });

      await _initIBMVoice();
      Voice desiredVoice =
          availableVoices.singleWhere((voice) => voice.name == voiceName);

      Future.delayed(const Duration(seconds: 3), () {
        //_getVoice(translation.text);
        _getIBMSpeech(translation.text, desiredVoice);
      });
    } catch (e) {
      print(e);
      _getVoice("Translation not possible");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        title: Text('Translation Results'),
        backgroundColor: Colors.indigo,
      ), //AppBar
      body: Center(
        /** Card Widget **/
        child: SingleChildScrollView(
          child: Card(
            elevation: 50,
            shadowColor: Colors.black,
            color: Colors.blueAccent[100],
            child: SizedBox(
              width: 300,
              height: 500,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      child: Container(
                        color: Colors.teal,
                        child: Image.asset(
                          "assets/language.png",
                          height: 120,
                          width: 120,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 4),
                      ),
                      width: double.infinity,
                      child: Text(
                        "From: English\n" + bodyTranslate,
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ), //Text
                    SizedBox(
                      height: 20,
                    ), //SizedBox
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 4),
                      ),
                      child: Text(
                        "To: " + transLang + "\n" + resultText,
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                      width: double.infinity,
                    ), //Text
                  ],
                ), //Column
              ), //Padding
            ), //SizedBox
          ),
        ), //Card
      ), //Center
      //Scaffold
    );
  }
}
