import 'package:eager_ear/shared/music.dart';

class Pitch {

  Pitch();

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

  PitchClass pitchClass;
  String pitchClassString;
  int octave;
  double hertz;
}