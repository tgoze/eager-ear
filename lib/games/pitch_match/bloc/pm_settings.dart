import 'package:flutter/material.dart';

class PitchMatchSettingsState extends ChangeNotifier {
  bool lowerVoice = false;

  PitchMatchSettingsState({this.lowerVoice});

  void setLowerVoice(bool isLowerVoice) async {
    lowerVoice = isLowerVoice;
    notifyListeners();
  }
}