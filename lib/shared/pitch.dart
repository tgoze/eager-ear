import 'package:eager_ear/shared/music.dart';

class Pitch {
  PitchClass pitchClass;
  String pitchClassString;
  int octave;
  double hertz;

  Pitch();

  Pitch.fromClass(PitchClass pitchClass, int octave) {
    this.pitchClass = pitchClass;
    this.octave = octave;
  }

  Pitch.fromHertz(double hertz) {
    this.pitchClass = convertHertzToPitchClass(hertz);
    this.pitchClassString = convertHertzToPitchClassString(hertz);
    this.octave = getOctaveFromHertz(hertz);
    this.hertz = hertz;
  }

  @override
  String toString(){
    return pitchClassString + octave.toString();
  }

  @override
  bool operator ==(covariant Pitch other) =>
    octave == other.octave && pitchClass == other.pitchClass;

  @override
  int get hashCode => pitchClass.hashCode;
}