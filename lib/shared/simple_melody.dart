import 'package:eager_ear/shared/music.dart';

import 'note.dart';
import 'pitch.dart';

class SimpleMelody {
  List<Note> notes;

  SimpleMelody();

  SimpleMelody.fromNotes(List<Note> notes) {
    this.notes = notes;
  }

  void addNote(Note note) {
    this.notes.add(note);
  }

  void addNoteFromPitch(Pitch pitch, PitchDuration pitchDuration) {
    this.notes.add(new Note.fromPitch(pitch, pitchDuration));
  }
}