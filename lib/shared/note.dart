import 'package:eager_ear/shared/music.dart';
import 'package:eager_ear/shared/pitch.dart';
import 'package:json_annotation/json_annotation.dart';

part 'note.g.dart';

@JsonSerializable(explicitToJson: true)
class Note {
  Note({this.pitch, this.duration});

  Note.fromPitch(Pitch pitch, PitchDuration pitchDuration) {
    this.pitch = pitch;
    this.duration = pitchDuration;
  }

  Note.fromHertz(double hertz, PitchDuration pitchDuration) {
    this.pitch = Pitch.fromHertz(hertz);
    this.duration = pitchDuration;
  }

  Pitch pitch;
  PitchDuration duration;

  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);

  Map<String, dynamic> toJson() => _$NoteToJson(this);
}