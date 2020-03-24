import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:eager_ear/shared/note.dart';

class PitchMatchGame extends ChangeNotifier {
  final List<Note> totalNotes;
  final List<Note> _currentNotes = [];
  int maxStaffNotes;
  int currentStaff;
  ValueNotifier previewAnimating = ValueNotifier<int>(-1);
  ValueNotifier successAnimating = ValueNotifier<int>(-1);
  bool isListening;
  bool isPlaying;
  Stream<List<double>> heardHertzStream;

  List<Note> get currentNotes => List.from(_currentNotes);

  PitchMatchGame(this.totalNotes) {
    currentStaff = 0;
    isListening = false;
    isPlaying = false;
  }

  void nextNotes() {
    _currentNotes.clear();
    int startIndex = currentStaff * maxStaffNotes;
    if (startIndex < totalNotes.length) {
      int endIndex = math.min(startIndex + maxStaffNotes, totalNotes.length);
      _currentNotes.addAll(totalNotes.sublist(startIndex, endIndex));
      currentStaff++;
    }
    notifyListeners();
  }

  void setPreviewAnimating(int newIndex) {
    previewAnimating.value = newIndex;
  }

  void setSuccessAnimating(int newIndex) {
    successAnimating.value = newIndex;
  }

  void setIsListening(bool isListening) {
    this.isListening = isListening;
    notifyListeners();
  }

  void setIsPlaying(bool isPlaying) {
    this.isPlaying = isPlaying;
    notifyListeners();
  }

  void setHeardHertzStream(Stream<List<double>> heardHertzStream) {
    this.heardHertzStream = heardHertzStream;
    notifyListeners();
  }
}