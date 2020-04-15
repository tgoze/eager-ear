import 'dart:math' as math;

import 'package:eager_ear/shared/constants.dart';
import 'package:eager_ear/shared/simple_melody.dart';
import 'package:flutter/material.dart';
import 'package:eager_ear/shared/note.dart';

class PitchMatchGame extends ChangeNotifier {
  final SimpleMelody melody;
  final List<Note> _currentNotes = [];
  int maxStaffNotes;
  int currentStaff;
  ValueNotifier previewNote = ValueNotifier<int>(-1);
  ValueNotifier currentNote = ValueNotifier<int>(-1);
  bool isListening;
  bool isPlaying;
  bool isComplete;
  Stream<List<double>> heardHertzStream;
  ValueNotifier correctHeard = ValueNotifier<bool>(false);

  List<Note> get currentNotes => List.from(_currentNotes);

  PitchMatchGame(this.melody) {
    currentStaff = 0;
    isListening = false;
    isPlaying = false;
    isComplete = false;
  }

  void nextNotes() {
    _currentNotes.clear();
    int startIndex = currentStaff * maxStaffNotes;
    if (startIndex < melody.notes.length) {
      int endIndex = math.min(startIndex + maxStaffNotes, melody.notes.length);
      _currentNotes.addAll(melody.notes.sublist(startIndex, endIndex));
      currentStaff++;
    }
    notifyListeners();
  }

  void setOctaves(bool isLowerVoice) {
    if (isLowerVoice != melody.lowerVoice) {
      var newOctaves = getOctaves(isLowerVoice);
      melody.notes.forEach((note) {
        if (note.pitch.octave == getOctaves(melody.lowerVoice)['low']) {
          note.pitch.octave = newOctaves['low'];
        } else {
          note.pitch.octave = newOctaves['high'];
        }
      });
    }
  }

  void setPreviewNote(int newIndex) {
    previewNote.value = newIndex;
  }

  void setCurrentNote(int newIndex) {
    currentNote.value = newIndex;
  }

  void setIsListening(bool isListening) {
    this.isListening = isListening;
    notifyListeners();
  }

  void setIsPlaying(bool isPlaying) {
    this.isPlaying = isPlaying;
    notifyListeners();
  }

  void setIsComplete(bool isComplete) {
    this.isComplete = isComplete;
    notifyListeners();
  }

  void setHeardHertzStream(Stream<List<double>> heardHertzStream) {
    this.heardHertzStream = heardHertzStream;
    notifyListeners();
  }

  void wasCorrectHeard(bool correctHeard) {
    this.correctHeard.value = correctHeard;
  }
}