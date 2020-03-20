import 'dart:math' as math;

import 'package:eager_ear/shared/note.dart';
import 'package:flutter/material.dart';

class PitchMatchGame extends ChangeNotifier {
  List<Note> notes;
  List<Note> currentNotes = [];
  int maxStaffNotes;
  int currentStaff;
  ValueNotifier previewAnimating = ValueNotifier<int>(-1);
  ValueNotifier successAnimating = ValueNotifier<int>(-1);

  PitchMatchGame(this.notes) {
    currentStaff = 0;
  }

  void nextNotes() {
    currentNotes.clear();
    int startIndex = currentStaff * maxStaffNotes;
    if (startIndex < notes.length) {
      int endIndex = math.min(startIndex + maxStaffNotes, notes.length);
      currentNotes.addAll(notes.sublist(startIndex, endIndex));
      currentStaff++;
      notifyListeners();
    }
  }

  void setPreviewAnimating(int newIndex) {
    previewAnimating.value = newIndex;
  }

  void setSuccessAnimating(int newIndex) {
    successAnimating.value = newIndex;
  }
}