import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eager_ear/shared/constants.dart';
import 'package:flutter/material.dart';

import 'package:eager_ear/shared/simple_melody.dart';
import 'package:eager_ear/shared/note.dart';

class MusicMakerState extends ChangeNotifier {
  final SimpleMelody melody;
  DocumentReference documentReference;
  bool modified = false;

  MusicMakerState({this.melody, this.documentReference, this.modified});

  void addNote(Note note) {
    if (!modified) modified = true;
    this.melody.addNote(note);
    notifyListeners();
  }

  void editNote(Note newNote, int indexOfOldNote) {
    if (!modified) modified = true;
    this.melody.notes[indexOfOldNote] = newNote;
    notifyListeners();
  }

  void removeNote(Note note) {
    if (!modified) modified = true;
    this.melody.notes.remove(note);
    notifyListeners();
  }

  void setTitle(String title) {
    if (!modified) modified = true;
    this.melody.title = title;
    notifyListeners();
  }

  void setIsLowerVoice(bool isLowerVoice) {
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
    this.melody.lowerVoice = isLowerVoice;
    notifyListeners();
  }

  void setModified(bool wasModified) {
    this.modified = wasModified;
    notifyListeners();
  }
}