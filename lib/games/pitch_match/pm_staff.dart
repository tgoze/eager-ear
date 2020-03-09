import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:eager_ear/shared/widgets/staff_painter.dart';
import 'package:eager_ear/shared/music.dart';
import 'package:eager_ear/shared/note.dart';
import 'package:flutter/services.dart';

import 'package:spritewidget/spritewidget.dart';

class PitchMatchStaff extends StatefulWidget {
  PitchMatchStaff({
    Key key,
    this.notes,
    this.currentNoteIndex,
    this.backgroundSize }) : super(key: key);

  final List<Note> notes;
  final ValueNotifier currentNoteIndex;
  final Size backgroundSize;

  @override
  State<StatefulWidget> createState() => new _PitchMatchStaffState();
}

class _PitchMatchStaffState extends State<PitchMatchStaff> {

  NodeWithSize rootStaffNode;
  List<Node> noteNodes = new List<Node>();
  GlobalKey staffKey = GlobalKey();

  Future<ImageMap> _loadNoteAssets() async {
    ImageMap noteImages = new ImageMap(rootBundle);
    await noteImages.load(<String>[
      'assets/images/bunny.png',
      'assets/images/turtle.png'
    ]);
    return noteImages;
  }

  Offset _findOffsetOnStaff(Note note, Size parentSize, double noteHeight) {
    double _noteStep = noteHeight / 2;
    double _leftOffset = 0;
    double _topOffset = _noteStep;

    int numAllowed = (parentSize.width / noteHeight).floor();

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

    // Find left offset
    int spaces = math.min(widget.notes.length, numAllowed) + 1;
    _leftOffset = (parentSize.width / spaces);
    _leftOffset *= (widget.notes.indexOf(note) + 1);

     return Offset(_leftOffset, _topOffset);
  }

  Offset _findOffsetOnPath(double percent, Path path) {
    PathMetrics pathMetrics = path.computeMetrics();
    PathMetric pathMetric = pathMetrics.elementAt(0);
    percent = pathMetric.length * percent;
    Tangent pos = pathMetric.getTangentForOffset(percent);
    return pos.position;
  }

  @override
  void initState() {
    super.initState();

    rootStaffNode = NodeWithSize(Size(1024, 1024));

    _loadNoteAssets().then((noteImages) {
      for (Note note in widget.notes) {
        Sprite bunnySprite = Sprite
            .fromImage(noteImages['assets/images/bunny.png']);

        Size staffSize = staffKey.currentContext.size;
        double noteDim = staffSize.height / 8;

        bunnySprite.size = Size.square(noteDim);
        var staffPos = _findOffsetOnStaff(note, staffSize, noteDim);

        var randGen = math.Random();
        double offsetBez = ((200 * randGen.nextDouble()) - 100);
        double startDx = staffPos.dx + offsetBez;
        var startPathPos = Offset(startDx,
            staffSize.height + staffSize.height * .25);
        var endPathPos = Offset(staffPos.dx, staffPos.dy - 25);

        Path path = Path();
        path.moveTo(startPathPos.dx, startPathPos.dy);
        path.quadraticBezierTo(startDx + .5 * -offsetBez, staffPos.dy - 125,
            endPathPos.dx, endPathPos.dy);

        bunnySprite.position = startPathPos;
        noteNodes.add(bunnySprite);
        rootStaffNode.addChild(bunnySprite);
        var enterMotion = MotionSequence([
          new MotionDelay(randGen.nextDouble() * 1.25),
          new MotionTween((a) =>
            bunnySprite.position = _findOffsetOnPath(a, path),
            0.0, 1.0, .5, Curves.linearToEaseOut
          ),
          new MotionTween((a) => bunnySprite.position = a,
            endPathPos, staffPos, .1, Curves.bounceOut
          ),
        ]);
        bunnySprite.motions.run(enterMotion);
      }
    });

    widget.currentNoteIndex.addListener(() {
      if (widget.currentNoteIndex.value < widget.notes.length
          && widget.currentNoteIndex.value >= 0) {
        var sprite = noteNodes[widget.currentNoteIndex.value];
        var startPos = sprite.position;
        MotionSequence previewNoteMotion = new MotionSequence([
          new MotionTween(
            (a) => sprite.position = a,
            startPos,
            startPos + Offset(0, -30),
            0.3,
            Curves.easeOut
          ),
          new MotionTween(
            (a) => sprite.position = a,
            startPos + Offset(0, -30),
            startPos,
            0.3,
            Curves.bounceOut
          ),
        ]);
        sprite.motions.run(previewNoteMotion);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      key: staffKey,
      flex: 3,
      child: Container(
        child: Stack(
          children: <Widget>[
            Padding (
                padding: EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                child: CustomPaint(
                  painter: new StaffPainter(),
                  child: Container(
                    constraints: BoxConstraints.tight(MediaQuery.of(context).size),
                  ),
                )
            ),
            SpriteWidget(
                rootStaffNode,
                SpriteBoxTransformMode.nativePoints
            ),
          ],
        ),
      )
    );
  }
}