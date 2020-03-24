import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:spritewidget/spritewidget.dart';

import 'package:eager_ear/shared/music.dart';
import 'package:eager_ear/shared/note.dart';

class CarrotNode extends Sprite {
  CarrotNode(ui.Image image) : super.fromImage(image);

  void animateToStaffPosition(Size staffSize, Note note) {
    var floatAnimation = MotionTween(
        (a) => position = a, position, _findOffsetOnStaff(staffSize, note), 1);
    motions.run(floatAnimation);
  }

  Offset _findOffsetOnStaff(Size staffSize, Note note) {
    double _noteStep = size.height / 2;
    double _leftOffset = 0;
    double _topOffset = _noteStep;

    // Find bottom offset
    if (note.pitch.octave == 4 || note.pitch.octave == 5) {
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
      if (note.pitch.octave == 4) {
        _topOffset += _noteStep * 7;
      }
    }

    // TODO: Find left offset
    return Offset(_leftOffset, _topOffset);
  }
}
