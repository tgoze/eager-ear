import 'dart:developer';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:spritewidget/spritewidget.dart';

import 'package:eager_ear/shared/pitch.dart';
import 'package:eager_ear/shared/music.dart';
import 'package:eager_ear/shared/note.dart';

class FeedbackNode extends Sprite {
  FeedbackNode(ui.Image image) : super.fromImage(image);

  void animateToStaffPosition(Size staffSize, List<double> hertzList) {
    // TODO: get average pitch with variance and animate

    // Get most common pitch
    var pitches = hertzList.map<Pitch>((hertz) => Pitch.fromHertz(hertz));
    var mostCommonPitch = pitches.reduce((prev, next) {
      if (prev != next) {
        return pitches
            .where((pitch) => pitch == next)
            .length
            > pitches
                .where((pitch) => prev == next)
                .length
            ? next
            : prev;
      } else {
        return prev;
      }
    });

    // Animate to staff
    var note = Note.fromPitch(mostCommonPitch, PitchDuration.Unknown);
    var endPos = _findOffsetOnStaff(staffSize, note);
    var floatAnimation = new MotionTween(
        (a) => position = a, position, endPos, .5, Curves.fastOutSlowIn);
    motions.run(floatAnimation);
  }

  Offset _findOffsetOnStaff(Size staffSize, Note note) {
    double _noteStep = size.height / 2;
    double _leftOffset = size.height / 2;
    double _topOffset = _noteStep;

    // Find bottom offset
    if (note.pitch.octave == 3 || note.pitch.octave == 4) {
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
          // nothing
          break;
      }
      if (note.pitch.octave == 3) {
        _topOffset += _noteStep * 7;
      }
    }

    // TODO: Find left offset
    return Offset(_leftOffset, _topOffset);
  }
}
