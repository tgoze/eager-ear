import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:assets_audio_player/assets_audio_player.dart';

import 'package:eager_ear/games/pitch_match/pm_listener.dart';
import 'package:eager_ear/games/pitch_match/pm_player.dart';
import 'package:eager_ear/games/pitch_match/pm_staff.dart';
import 'package:eager_ear/shared/music.dart';
import 'package:eager_ear/shared/note.dart';
import 'package:eager_ear/shared/pitch.dart';

class PitchMatchMain extends StatelessWidget {
  final List<Note> notes = [
    Note.fromPitch(Pitch.fromClass(PitchClass.F, 4), PitchDuration.Eighth),
    Note.fromPitch(Pitch.fromClass(PitchClass.A, 4), PitchDuration.Eighth),
    Note.fromPitch(Pitch.fromClass(PitchClass.C, 5), PitchDuration.Eighth),
    Note.fromPitch(Pitch.fromClass(PitchClass.B, 4), PitchDuration.Eighth),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pitch Match"),
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: PitchMatchManager(notes: notes)
      ),
      backgroundColor: Color(0xFF7EC0EE),
    );
  }
}

class PitchMatchManager extends StatefulWidget {
  PitchMatchManager({Key key, this.notes}) : super(key: key);

  final List<Note> notes;

  @override
  _PitchMatchManagerState createState() => _PitchMatchManagerState();
}

class _PitchMatchManagerState extends State<PitchMatchManager> {
  Stream<Pitch> _pitchStream;
  StreamSubscription _pitchSubscription;
  ValueNotifier<int> _currentNoteIndex = new ValueNotifier(-1);
  int _noteIndexCounter = 0;

  AssetsAudioPlayer _player = new AssetsAudioPlayer();

  void _startListener() async {
    var pmListener = new PitchMatchListener();

    if (_pitchSubscription == null && _pitchStream == null) {
      _pitchStream = await pmListener.startPitchStream();

      if (_pitchStream != null) {
        _noteIndexCounter = 0;
        _pitchSubscription = _pitchStream.listen((Pitch pitch) {
          if (_noteIndexCounter >= widget.notes.length) {
            _cancelListener();
          }
          else if (pitch == widget.notes[_noteIndexCounter].pitch) {
            _currentNoteIndex.value = _noteIndexCounter++;
          }
        });
      } else {
        // Audio access not granted
      }
    }
  }

  void _cancelListener() {
    if (_pitchSubscription != null) {
      _pitchSubscription.cancel();
      _pitchSubscription = null;
      _pitchStream = null;
    }
  }

  @override
  void initState() {
    super.initState();
    _player.playlistCurrent.listen((playlistPlayingAudio) {
      _currentNoteIndex.value = playlistPlayingAudio.index;
    }); // animates correct note
  }

  @override
  void dispose() {
    super.dispose();
    _player.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          flex: 6,
          child: PitchMatchStaff(
            notes: widget.notes,
            currentNoteIndex: _currentNoteIndex
          ),
        ),
        Expanded(
          flex: 1,
          child: Ink(
              decoration: const ShapeDecoration(
                  shape: CircleBorder(),
                  color: Color(0xFFFFAD05)
              ),
              child: IconButton(
                  icon: Icon(Icons.mic, color: Colors.white,),
                  iconSize: 36.0,
                  color: Colors.white
              )
          ),
        ),
        Expanded(
          flex: 1,
          child:  CustomPaint(
            painter: BackgroundPainter(),
          ),
        )
//        Expanded(
//          flex: 1,
//          child: Stack(
//            children: <Widget>[
//              Positioned.fill(
//                child: CustomPaint(
//                  painter: BackgroundPainter(),
//                ),
//              ),
//              Positioned.directional(
//                textDirection: TextDirection.rtl,
//                child: Ink(
//                  decoration: const ShapeDecoration(
//                  shape: CircleBorder(),
//                  color: Color(0xFFFFAD05)
//                  ),
//                  child: IconButton(
//                    icon: Icon(Icons.mic),
//                    iconSize: 36.0,
//                    color: Colors.white
//                  )
//                ),
//                top: 1,
//                bottom: 1,
//                start: 2,
//                end: 100,
//              ),
//              Positioned.directional(
//                child: PitchMatchPlayer(
//                  notes: widget.notes,
//                  currentNoteIndex: _currentNoteIndex,
//                  player: _player,
//                ),
//                textDirection: TextDirection.rtl,
//                top: 1,
//                bottom: 1,
//                start: 1,
//                end: 1,
//              ),
//            ],
//          )
//        )
      ],
    );
  }
}

class BackgroundPainter extends CustomPainter {

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    Path path = Path();

    paint.color = Color(0xFF55AE00);
    paint.style = PaintingStyle.fill;

    path.moveTo(0, size.height * 0.6);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.575,
        size.width * 0.5, size.height * 0.9167);
    path.quadraticBezierTo(size.width * 0.75, size.height * 0.9584,
        size.width * 1.0, size.height * 0.9167);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    canvas.drawPath(path, paint);

    Path path2 = Path();
    paint.color = Colors.green;
    path2.moveTo(size.width, size.height * 0.67);
    path2.quadraticBezierTo(size.width * 0.8, size.height * 0.50,
        size.width * 0.43, size.height * 0.8);
//    path2.quadraticBezierTo(size.width * 0.75, size.height * 0.9584,
//        size.width * 1.0, size.height * 0.9167);
    path2.lineTo(0, size.height);
    path2.lineTo(size.width, size.height);
    canvas.drawPath(path2, paint);

  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}