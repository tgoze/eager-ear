import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:eager_ear/shared/widgets/staff_painter.dart';
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
  var _noteWidgets = List<Widget>();
  var _noteAnimationControllers = List<AnimationController>();

  void _addNoteToStaff(Note note, int noteIndex) {
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

    var imagePath = '';
    if (note.duration == PitchDuration.Eighth)
      imagePath = 'assets/images/bunny.png';
    else
      imagePath = 'assets/images/turtle.png';

    _noteWidgets.add(
      LayoutId(
        id: note,
        child: AnimatedBuilder(
          animation: _noteAnimationControllers[noteIndex],
          child: Container(
              height: _noteDim,
              width: _noteDim,
              child: Image.asset(imagePath)
          ),
          builder: (BuildContext context, Widget child){
            return SlideTransition(
                position: newNoteAnimation,
                child: child
            );
          },
        ),
      )
    );
  }

  @override
  void initState() {
    super.initState();

    widget.currentNoteIndex.addListener(() {
      if (widget.currentNoteIndex.value < widget.notes.length
          && widget.currentNoteIndex.value >= 0)
        _noteAnimationControllers[widget.currentNoteIndex.value].forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    for(Note note in widget.notes) {
      _addNoteToStaff(note, widget.notes.indexOf(note));
    }

    return Center(
        child: Stack(
          children: <Widget>[
            Padding (
              padding: EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
              child: CustomPaint(
                painter: new StaffPainter(),
                child: Container(
                  height: _staffHeight,
                ),
              )
            ),
            Container(
              child: CustomMultiChildLayout(
                children: _noteWidgets,
                delegate: new NoteLayoutDelegate(notes: widget.notes),
              ),
              constraints: BoxConstraints.expand(
                  width: MediaQuery.of(context).size.width,
                  height: _staffHeight
              ),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent)
              ),
            )
          ],
        ),
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

class NoteLayoutDelegate extends MultiChildLayoutDelegate {
  final List<Note> notes;

  NoteLayoutDelegate({this.notes});

  @override
  void performLayout(Size size) {
    Size noteSize = Size.zero;
    int numAllowedNotes = 0;

    if (notes.length > 0) {
      noteSize = layoutChild(notes[0], BoxConstraints.loose(size));
      numAllowedNotes = (size.width / noteSize.width).floor();
      positionNote(notes[0], size, noteSize, numAllowedNotes);

      for (int i = 1; i < numAllowedNotes && i < notes.length; i++) {
        if (hasChild(notes[i])) {
          noteSize = layoutChild(notes[i], BoxConstraints.loose(size));

          positionNote(notes[i], size, noteSize, numAllowedNotes);
        }
      }
    }
  }

  @override
  bool shouldRelayout(NoteLayoutDelegate oldDelegate) {
    return oldDelegate.notes != notes;
  }

  void positionNote(Note note, Size parentSize, Size noteSize, int numAllowed) {
    double _topOffset = 0;
    double _leftOffset = 0;
    double _noteStep = noteSize.height / 2;

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
    int spaces = math.min(notes.length, numAllowed) + 1;
    _leftOffset = (parentSize.width / spaces);
    _leftOffset *= (notes.indexOf(note) + 1);
    _leftOffset -= (noteSize.width / 2);

    positionChild(note, Offset(_leftOffset, _topOffset));
  }
}