import 'package:eager_ear/shared/music.dart';
import 'package:eager_ear/shared/pitch.dart';

class Note {
  Note();

  Note.fromPitch(Pitch pitch, PitchDuration pitchDuration) {
    this.pitch = pitch;
    this.duration = pitchDuration;
  }

  Pitch pitch;
  PitchDuration duration;
}