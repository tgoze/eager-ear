import 'dart:async';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:eager_ear/shared/constants.dart';
import 'package:eager_ear/shared/music.dart';
import 'package:eager_ear/shared/note.dart';
import 'package:flutter/material.dart';
import 'package:spritewidget/spritewidget.dart';

class NoteNode extends Sprite {
  Note note;
  Size staffSize;

  NoteNode(ui.Image image, this.note, this.staffSize) : super.fromImage(image);

  void animateHopToStaff(List<Note> notes, bool isLowerVoice) {
    // Find staff position
    Offset endPosition = _findOffsetOnStaff(notes, isLowerVoice);

    // Path to animate sprite on
    var randGen = math.Random();
    double offsetBez = ((200 * randGen.nextDouble()) - 100);
    double startDx = endPosition.dx + offsetBez;
    var startPathPos =
        Offset(startDx, staffSize.height + staffSize.height * .25);
    var endPathPos = Offset(endPosition.dx, endPosition.dy - 25);
    Path entryPath = Path();
    entryPath.moveTo(startPathPos.dx, startPathPos.dy);
    entryPath.quadraticBezierTo(startDx + .5 * -offsetBez, endPosition.dy - 125,
        endPathPos.dx, endPathPos.dy);

    // Set beginning position
    position = startPathPos;
    visible = true;

    var enterMotion = MotionSequence([
      new MotionDelay(randGen.nextDouble() * 1.25),
      new MotionTween((a) => position = _findOffsetOnPath(a, entryPath), 0.0,
          1.0, .5, Curves.linearToEaseOut),
      new MotionTween(
          (a) => position = a, endPathPos, endPosition, .1, Curves.bounceOut)
    ]);
    motions.run(enterMotion);
  }

  void animatePreviewHop() {
    var startPos = position;
    MotionSequence previewNoteMotion = new MotionSequence([
      new MotionTween((a) => position = a, startPos, startPos + Offset(0, -30),
          0.3, Curves.easeOut),
      new MotionTween((a) => position = a, startPos + Offset(0, -30), startPos,
          0.3, Curves.bounceOut)
    ]);
    motions.run(previewNoteMotion);
  }

  Future<Null> animateSuccessHop() {
    var randGen = math.Random();

    var startPos = position;
    var endPos = Offset(
        startPos.dx +
            (staffSize.width / 4) * randGen.nextDouble() -
            (staffSize.width / 8),
        staffSize.height + staffSize.height * .25);

    double offsetBez = ((200 * randGen.nextDouble()) - 100);

    Path path = Path();
    path.moveTo(startPos.dx, startPos.dy);
    path.quadraticBezierTo(
        startPos.dx + .5 * -offsetBez, startPos.dy - 300, endPos.dx, endPos.dy);

    var completer = new Completer<Null>(); // For notifying the future
    var successNoteAnimation = new MotionSequence([
      new MotionGroup([
        new MotionTween((a) => position = _findOffsetOnPath(a, path), 0.0, 1.0,
            1.0, Curves.easeInOutQuad),
        new MotionRepeat(
            new MotionTween((a) => rotation = a, 0.0, 360.0, 0.2), 3)
      ]),
      new MotionTween((a) => opacity = a, 1.0, 0.0, .5),
      new MotionCallFunction(() {
        completer.complete();
      }),
      //new MotionRemoveNode(this)
    ]);
    motions.run(successNoteAnimation);
    return completer.future;
  }

  void animateShake(double angleInDeg, double duration) {
    var shakeAnimation = new MotionTween(
        (a) => rotation = angleInDeg * math.sin(a),
        0.0,
        2 * math.pi,
        duration,
        Curves.easeIn);
    motions.run(shakeAnimation, "shake");
  }

  void animateToUprightRotation() {
    var shakeAnimation =
        new MotionTween((a) => rotation = a, rotation, 0.0, .3);
    motions.run(shakeAnimation, "shake");
  }

  void stopShakeAnimations() {
    motions.stopWithTag("shake");
  }

  void stopAnimations() {
    motions.stopAll();
  }

  Offset _findOffsetOnStaff(List<Note> notes, bool isLowerVoice) {
    double _noteStep = size.height / 2;
    double _leftOffset = 0;
    double _topOffset = _noteStep;

    // Find bottom offset
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

    // Modify offset based on octave
    if (note.pitch.octave == getOctaves(isLowerVoice)['low']) {
      _topOffset += _noteStep * 7;
    } else if (note.pitch.octave != getOctaves(isLowerVoice)['high']) {
      _topOffset = _noteStep * 14;
      note.pitch.variance = 0;
    }

    // Find left offset
    int spaces = notes.length + 1;
    _leftOffset = ((staffSize.width) / spaces);
    _leftOffset *= (notes.indexOf(note) + 1);

    return Offset(_leftOffset, _topOffset);
  }

  Offset _findOffsetOnPath(double percent, Path path) {
    ui.PathMetrics pathMetrics = path.computeMetrics();
    ui.PathMetric pathMetric = pathMetrics.elementAt(0);
    percent = pathMetric.length * percent;
    ui.Tangent pos = pathMetric.getTangentForOffset(percent);
    return pos.position;
  }
}
