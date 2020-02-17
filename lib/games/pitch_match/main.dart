import 'package:eager_ear/shared/music.dart';
import 'package:eager_ear/shared/note.dart';
import 'package:eager_ear/shared/pitch.dart';
import 'package:flutter/material.dart';

class PitchMatchMain extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pitch Match"),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            PitchMatchStaff(
              notes: <Note> [
                Note.fromHertz(440.0, PitchDuration.Eighth),
                Note.fromPitch(Pitch.fromClass(PitchClass.G, 5)
                  , PitchDuration.Eighth)
              ],
            )
          ],
        ),
      )
    );
  }
}

class PitchMatchStaff extends StatefulWidget {
  PitchMatchStaff({Key key, this.notes}) : super(key: key);

  final List<Note> notes;

  @override
  State<StatefulWidget> createState() => new _PitchMatchStaffState();
}

class _PitchMatchStaffState extends State<PitchMatchStaff> {
  double _staffHeight = 400;
  double _noteDim = 50;
  double _noteStep;
  var _staffWidgets = List<Widget>();

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

    _staffWidgets.add(
      Positioned(
        child: Container(
          height: _noteDim,
          width: _noteDim,
//          decoration: BoxDecoration(
//              border: Border.all(color: Colors.blueAccent)
//          ),
          child: Image.asset('assets/images/rabbit.png')
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
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: _staffWidgets
      )
    );
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