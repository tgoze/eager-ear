import 'package:flutter/material.dart';

import 'package:eager_ear/shared/music.dart';
import 'package:eager_ear/shared/note.dart';

class PitchMatchStaff extends StatefulWidget {
  PitchMatchStaff({
    Key key,
    this.notes,
    this.currentNoteIndex}) : super(key: key);

  final List<Note> notes;
  final ValueNotifier currentNoteIndex;

  @override
  State<StatefulWidget> createState() => new _PitchMatchStaffState();
}

class _PitchMatchStaffState extends State<PitchMatchStaff>
    with TickerProviderStateMixin {
  double _staffHeight = 400;
  double _noteDim = 50;
  double _noteStep;
  var _staffWidgets = List<Widget>();
  var _noteAnimationControllers = List<AnimationController>();

  void _addNoteToStaff(Note note, int noteIndex) {
    double _bottomOffset = 0.0;
    double _leftOffset = 0.0;

    _leftOffset += noteIndex * _noteDim;

    if (note.pitch.octave == 4 || note.pitch.octave == 5) {
      switch (note.pitch.pitchClass) {
        case PitchClass.C:
        case PitchClass.CSharp:
          _bottomOffset += _noteStep;
          break;
        case PitchClass.D:
        case PitchClass.DSharp:
          _bottomOffset += _noteStep * 2;
          break;
        case PitchClass.E:
          _bottomOffset += _noteStep * 3;
          break;
        case PitchClass.F:
        case PitchClass.FSharp:
          _bottomOffset += _noteStep * 4;
          break;
        case PitchClass.G:
        case PitchClass.GSharp:
          _bottomOffset += _noteStep * 5;
          break;
        case PitchClass.A:
        case PitchClass.ASharp:
          _bottomOffset += _noteStep * 6;
          break;
        case PitchClass.B:
          _bottomOffset += _noteStep * 7;
          break;
        case PitchClass.Unknown:
        // nothing
          break;
      }
      if (note.pitch.octave == 5) {
        _bottomOffset += _noteStep * 7;
      }
    }

    _noteAnimationControllers.add(AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this
    ));

    Animation<Offset> newNoteAnimation = Tween<Offset>(
        begin: Offset.zero,
        end: const Offset(0.0, -0.3),
      ).animate(
        CurvedAnimation(
          parent: _noteAnimationControllers[noteIndex],
          curve: Curves.easeOut,
          reverseCurve: Curves.bounceIn
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            _noteAnimationControllers[noteIndex].reverse();
          } else if (status == AnimationStatus.dismissed) {
            _noteAnimationControllers[noteIndex].stop();
          }
        })
      );

    _staffWidgets.add(
        Positioned(
          child: AnimatedBuilder(
            animation: _noteAnimationControllers[noteIndex],
            child: Container(
              height: _noteDim,
              width: _noteDim,
              child: Image.asset('assets/images/rabbit.png')
            ),
            builder: (BuildContext context, Widget child){
              return SlideTransition(
                position: newNoteAnimation,
                child: child
              );
            },
          ),
          left: _leftOffset,
          bottom: _bottomOffset,
        )
    );
  }

  @override
  void initState() {
    super.initState();
    _noteStep = _noteDim / 2.0;
    _staffWidgets.add(
        Padding (
            padding: EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
            child: CustomPaint(
                painter: new StaffPainter(),
                child: Container(height: _staffHeight)
            )
        )
    );

    for(Note note in widget.notes) {
      _addNoteToStaff(note, widget.notes.indexOf(note));
    }

    widget.currentNoteIndex.addListener(() {
      _noteAnimationControllers[widget.currentNoteIndex.value].forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Stack(
            children: _staffWidgets
        )
    );
  }

  @override
  void dispose() {
    super.dispose();
    for (AnimationController ctrl in _noteAnimationControllers) {
      ctrl.dispose();
    }
  }
}

class StaffPainter extends CustomPainter {

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();

    paint.color = Colors.teal;
    paint.strokeWidth = 5;

    int spaces = 8;
    int lines = 5;
    double spacing = size.height / spaces;

    double startY = 2 * spacing;

    for(int i = 0; i < lines; i++) {
      canvas.drawLine(
        Offset(0, startY + (spacing * i)),
        Offset(size.width, startY + (spacing * i)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}