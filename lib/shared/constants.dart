library constants;

import 'music.dart';
import 'note.dart';

const noteImagePaths = <String>[
'assets/images/2.0x/bunny.png',
'assets/images/2.0x/bunny_sharp.png',
'assets/images/2.0x/turtle.png',
'assets/images/2.0x/turtle_sharp.png',
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
      if (note.pitch.accidental) return noteImagePaths[3];
      return noteImagePaths[2];
    case PitchDuration.Eighth:
    case PitchDuration.Quarter:
      if (note.pitch.accidental) return noteImagePaths[1];
      return noteImagePaths[0];
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