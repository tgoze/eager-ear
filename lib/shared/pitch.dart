import 'package:eager_ear/shared/music.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pitch.g.dart';

@JsonSerializable()
class Pitch {
  PitchClass pitchClass;
  String pitchClassString;
  int octave;
  double hertz;
  double variance;
  bool accidental;

  Pitch(
      {this.pitchClass,
      this.pitchClassString,
      this.octave,
      this.hertz,
      this.variance,
      this.accidental});

  Pitch.fromClass(PitchClass pitchClass, int octave) {
    this.pitchClass = pitchClass;
    this.octave = octave;
    this.pitchClassString = convertPitchClassToString(pitchClass, octave);
    this.accidental = isAccidental(pitchClass);
  }

  Pitch.fromHertz(double hertz) {
    this.pitchClass = convertHertzToPitchClass(hertz);
    this.pitchClassString = convertHertzToPitchClassString(hertz);
    this.octave = getOctaveFromHertz(hertz);
    this.hertz = hertz;
    this.variance = convertHertzToStepVariance(hertz);
    this.accidental = isAccidental(this.pitchClass);
  }

  @override
  String toString() {
    return pitchClassString + octave.toString();
  }

  @override
  bool operator ==(covariant Pitch other) => pitchClass == other.pitchClass;

  @override
  int get hashCode => pitchClass.hashCode;

  factory Pitch.fromJson(Map<String, dynamic> json) => _$PitchFromJson(json);

  Map<String, dynamic> toJson() => _$PitchToJson(this);
}
