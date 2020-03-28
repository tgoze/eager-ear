import 'dart:developer';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:spritewidget/spritewidget.dart';

import 'package:eager_ear/shared/pitch.dart';
import 'package:eager_ear/shared/music.dart';
import 'package:eager_ear/shared/note.dart';

class FeedbackNode extends Sprite {
  FeedbackNode(ui.Image image) : super.fromImage(image);

  bool hidden = true;

  void animateEntryToStaff(Size staffSize, double startDx) {
    // Calculate start and end positions
    var startPos = Offset(startDx, staffSize.height + staffSize.height * .25);
    var endPos = _findOffsetOnStaff(
        staffSize, startDx, Note.fromHertz(-1, PitchDuration.Unknown), false);

    // Animate
    position = startPos;
    visible = true;
    opacity = 1.0;
    hidden = false;
    var entryMotion = new MotionTween(
        (a) => position = a, position, endPos, .5, Curves.fastOutSlowIn);
    motions.run(entryMotion);
  }

  void animateExit(Size staffSize) {
    // Calculate start and end positions
    var endPos = Offset(position.dx, staffSize.height + staffSize.height * .25);
    var exitMotion = new MotionGroup([
      new MotionTween(
          (a) => position = a, position, endPos, .5, Curves.fastOutSlowIn),
      new MotionTween((a) => opacity = a, 1.0, 0.0, .5)
    ]);
    motions.run(exitMotion);
    hidden = true;
  }

  void animateToStaffPosition(
      Size staffSize, double dx, List<double> hertzList) {
    // Get most common pitch
    var pitches = hertzList.map<Pitch>((hertz) => Pitch.fromHertz(hertz));
    var mostCommonPitch = pitches.reduce((prev, next) {
      if (prev != next) {
        return pitches.where((pitch) => pitch == next).length >
                pitches.where((pitch) => prev == next).length
            ? next
            : prev;
      } else {
        return prev;
      }
    });

    // Get average variance
    mostCommonPitch.variance = 0;
    var mostCommonPitches = pitches.where((pitch) => pitch == mostCommonPitch);
    mostCommonPitches.forEach((pitch) {
      mostCommonPitch.variance += pitch.variance;
    });
    mostCommonPitch.variance /= mostCommonPitches.length;

    // Animate to staff
    var note = Note.fromPitch(mostCommonPitch, PitchDuration.Unknown);
    var endPos = _findOffsetOnStaff(staffSize, dx, note, false);
    var newRotation = note.pitch.accidental ? 45.0 : 0.0;
    var floatAnimation = new MotionGroup([
      new MotionTween(
          (a) => position = a, position, endPos, .5, Curves.fastOutSlowIn),
      new MotionTween((a) => rotation = a, rotation, newRotation, .3)
    ]);
    motions.run(floatAnimation);
  }

  Offset _findOffsetOnStaff(Size staffSize, double dx, Note note, bool isHigh) {
    double _noteStep = size.height / 2;
    double _topOffset = _noteStep;

    // Set staff octaves
    int lowOctave = isHigh ? 4 : 3;
    int highOctave = isHigh ? 5 : 4;

    // Find top offset
    switch (note.pitch.pitchClass) {
      case PitchClass.C:
      case PitchClass.CSharp:
        _topOffset += _noteStep * 6;
        break;
      case PitchClass.D:
      case PitchClass.DSharp:
        _topOffset += _noteStep * 5;
        break;
      case PitchClass.E:
        _topOffset += _noteStep * 4;
        break;
      case PitchClass.F:
      case PitchClass.FSharp:
        _topOffset += _noteStep * 3;
        break;
      case PitchClass.G:
      case PitchClass.GSharp:
        _topOffset += _noteStep * 2;
        break;
      case PitchClass.A:
      case PitchClass.ASharp:
        _topOffset += _noteStep * 1;
        break;
      case PitchClass.B:
        _topOffset += _noteStep * 0;
        break;
      case PitchClass.Unknown:
        _topOffset = _noteStep * 14;
        note.pitch.variance = 0;
        break;
    }

    if (note.pitch.octave == lowOctave) {
      _topOffset += _noteStep * 7;
    } else if (note.pitch.octave != highOctave) {
      _topOffset = _noteStep * 14;
      note.pitch.variance = 0;
      note.pitch.accidental = false;
    }

    return Offset(dx, _topOffset + note.pitch.variance * _noteStep);
  }
}
