import 'dart:math';

class Music {
  static Map pitchCLetters = {
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
    11: 'B'
  };

  static int convertHertzToCStep(double hertz) {
    int pitchStep = -1;
    if (hertz != -1) {
      double a4 = 440.0;
      double c0 = a4 * pow(2, -4.75);

      int steps = (12 * (log(hertz/c0) / log(2))).round();
      pitchStep = steps % 12;
    }
    return pitchStep;
  }
}