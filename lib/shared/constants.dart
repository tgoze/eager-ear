library constants;

import 'music.dart';
import 'note.dart';

const noteImagePaths = <String>[
'assets/images/bunny.png',
'assets/images/bunny_sharp.png',
'assets/images/turtle.png',
'assets/images/turtle_sharp.png',
'assets/images/carrot.png'
];

const feedbackImagePath = 'assets/images/carrot.png';

Map getOctaves(bool isLowerVoice) {
  if (isLowerVoice) {
    return {
      'low': 3,
      'high': 4
    };
  } else {
    return {
      'low': 4,
      'high': 5
    };
  }
}

String getImagePathFromNote(Note note) {
  switch (note.duration) {
    case PitchDuration.Whole:
    case PitchDuration.Half:
      if (note.pitch.accidental) return 'assets/images/turtle_sharp.png';
      return 'assets/images/turtle.png';
    case PitchDuration.Eighth:
    case PitchDuration.Quarter:
      if (note.pitch.accidental) return 'assets/images/bunny_sharp.png';
      return 'assets/images/bunny.png';
    default:
      return '';
  }
}

String getAudioPathFromNote(Note note) {
  switch (note.duration) {
    case PitchDuration.Whole:
    case PitchDuration.Half:
    case PitchDuration.Eighth:
    case PitchDuration.Quarter:
      return 'assets/audio/bunny/' + note.pitch.toString() + '.wav';
    default:
      return '';
  }
}