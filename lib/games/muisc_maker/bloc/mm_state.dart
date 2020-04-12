import 'package:cloud_firestore/cloud_firestore.dart';
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

  void setModified(bool wasModified) {
    this.modified = wasModified;
    notifyListeners();
  }
}