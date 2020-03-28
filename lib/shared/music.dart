library music;

import 'dart:math';

const double _a4 = 440.0;
final double _c0 = _a4 * pow(2, -4.75);

const Map _cBasedPitchClassNames = {
  0: 'C',
  1: 'C#',
  2: 'D',
  3: 'D#',
  4: 'E',
  5: 'F',
  6: 'F#',
  7: 'G',
  8: 'G#',
  9: 'A',
  10: 'A#',
  11: 'B',
};

int convertHertzToStep(double hertz) {
  int pitchStep = -1;
  if (hertz >= 0) {
    pitchStep = (
        12 * (log(hertz/_c0) / log(2))
    ).round();
  }
  return pitchStep;
}

double convertHertzToStepVariance(double hertz) {
  double pitchStep = -1;
  if (hertz >= 0) {
    pitchStep = (
        12 * (log(hertz/_c0) / log(2))
    );
  }
  var variance = pitchStep - pitchStep.floor();
  return variance >= .5 ? 1 - variance : variance;
}

int convertHertzToClassStep(double hertz, PitchClass pitchClass) {
  int step = convertHertzToStep(hertz);
  if (step >= 0)
    step = (step - pitchClass.index) % 12;
  return step;
}

PitchClass convertHertzToPitchClass(double hertz) {
  switch (convertHertzToClassStep(hertz, PitchClass.C)) {
    case 0:
      return PitchClass.C;
    case 1:
      return PitchClass.CSharp;
    case 2:
      return PitchClass.D;
    case 3:
      return PitchClass.DSharp;
    case 4:
      return PitchClass.E;
    case 5:
      return PitchClass.F;
    case 6:
      return PitchClass.FSharp;
    case 7:
      return PitchClass.G;
    case 8:
      return PitchClass.GSharp;
    case 9:
      return PitchClass.A;
    case 10:
      return PitchClass.ASharp;
    case 11:
      return PitchClass.B;
    default:
      return PitchClass.Unknown;
  }
}

String convertHertzToPitchClassString(double hertz) {
  String pitchClassString = '';
  int step = convertHertzToClassStep(hertz, PitchClass.C);
  if (step >= 0 && step <= 11)
    pitchClassString = _cBasedPitchClassNames[step];
  else
    pitchClassString = 'No pitch found';
  return pitchClassString;
}

String convertPitchClassToString(PitchClass pitchClass, int octave) {
  return _cBasedPitchClassNames[pitchClass.index];
}

int getOctaveFromHertz(double hertz) {
  int octave = -1;
  int step = convertHertzToStep(hertz);
  if (step >= 0)
    octave = (step / 12).floor();
  return octave;
}

bool isAccidental(PitchClass pitchClass) {
  return accidentals.contains(pitchClass);
}

enum PitchClass {
  C, CSharp, D, DSharp, E, F, FSharp, G, GSharp, A, ASharp, B, Unknown
}

enum PitchDuration {
  Whole, Quarter, Eighth, Unknown
}

List<PitchClass> accidentals = [
  PitchClass.CSharp,
  PitchClass.DSharp,
  PitchClass.FSharp,
  PitchClass.GSharp,
  PitchClass.ASharp
];