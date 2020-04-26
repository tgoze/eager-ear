import 'package:eager_ear/shared/melody_score.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:eager_ear/shared/music.dart';

import 'note.dart';
import 'pitch.dart';

part 'simple_melody.g.dart';

@JsonSerializable(explicitToJson: true)
class SimpleMelody {
  String title;
  bool lowerVoice;
  final List<Note> notes;
  MelodyScore melodyScore;

  SimpleMelody({this.title, this.notes, this.lowerVoice, this.melodyScore});

  void addNote(Note note) {
    this.notes.add(note);
  }

  void addNoteFromPitch(Pitch pitch, PitchDuration pitchDuration) {
    this.notes.add(new Note.fromPitch(pitch, pitchDuration));
  }

  factory SimpleMelody.fromJson(Map<String, dynamic> json) =>
      _$SimpleMelodyFromJson(json);

  Map<String, dynamic> toJson() => _$SimpleMelodyToJson(this);
}
