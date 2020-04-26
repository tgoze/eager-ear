library music;

import 'dart:math' as math;

import 'package:eager_ear/shared/pitch.dart';

const double _a4 = 440.0;
final double _c0 = _a4 * math.pow(2, -4.75);

const Map _cBasedPitchClassNames = {
  0: 'C',
  1: 'CSharp',
  2: 'D',
  3: 'DSharp',
  4: 'E',
  5: 'F',
  6: 'FSharp',
  7: 'G',
  8: 'GSharp',
  9: 'A',
  10: 'ASharp',
  11: 'B',
};

const Map staffPitchClasses = {
  0: PitchClass.B,
  1: PitchClass.A,
  2: PitchClass.G,
  3: PitchClass.F,
  4: PitchClass.E,
  5: PitchClass.D,
  6: PitchClass.C
};

const Map staffSteps = {
  PitchClass.B: 0,
  PitchClass.A: 1,
  PitchClass.ASharp: 1,
  PitchClass.G: 2,
  PitchClass.GSharp: 2,
  PitchClass.F: 3,
  PitchClass.FSharp: 3,
  PitchClass.E: 4,
  PitchClass.D: 5,
  PitchClass.DSharp: 5,
  PitchClass.C: 6,
  PitchClass.CSharp: 6
};

double convertHertzToFloatingStep(double hertz) {
  double pitchStep = -1;
  if (hertz >= 0) {
    pitchStep = (
        12 * (math.log(hertz/_c0) / math.log(2))
    );
  }
  return pitchStep;
}

double convertHertzToStepVariance(double hertz) {
  double pitchStep = convertHertzToFloatingStep(hertz);
  var positiveVariance = pitchStep - pitchStep.floor();
  return positiveVariance >= .5 ? positiveVariance - 1.0 : positiveVariance;
}

int convertHertzToClassStep(double hertz, PitchClass pitchClass) {
  int step = convertHertzToFloatingStep(hertz).round();
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

double getDistance(Pitch truePitch, Pitch pitch) {
  return ((truePitch.pitchClass.index + (truePitch.octave * 12))
      - (pitch.pitchClass.index + (pitch.octave * 12) + pitch.variance)).abs();
}

String convertPitchClassToString(PitchClass pitchClass, int octave) {
  return _cBasedPitchClassNames[pitchClass.index];
}

int getOctaveFromHertz(double hertz) {
  int octave = -1;
  int step = convertHertzToFloatingStep(hertz).round();
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
  Whole, Half, Quarter, Eighth, Unknown
}

const List<PitchClass> accidentals = [
  PitchClass.CSharp,
  PitchClass.DSharp,
  PitchClass.FSharp,
  PitchClass.GSharp,
  PitchClass.ASharp
];

const Map relativeAccidentals = {
  PitchClass.B: PitchClass.ASharp,
  PitchClass.C: PitchClass.CSharp,
  PitchClass.D: PitchClass.DSharp,
  PitchClass.E: PitchClass.DSharp,
  PitchClass.F: PitchClass.FSharp,
  PitchClass.G: PitchClass.GSharp,
  PitchClass.A: PitchClass.ASharp,
};