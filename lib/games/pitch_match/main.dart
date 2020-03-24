import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:eager_ear/games/pitch_match/pm_listener.dart';
import 'package:eager_ear/games/pitch_match/pm_player.dart';
import 'package:eager_ear/games/pitch_match/pm_staff.dart';
import 'package:eager_ear/shared/music.dart';
import 'package:eager_ear/shared/note.dart';
import 'package:eager_ear/shared/pitch.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import 'bloc/pm_game.dart';

class PitchMatchMain extends StatelessWidget {
  final List<Note> notes = [
    Note.fromPitch(Pitch.fromClass(PitchClass.F, 3), PitchDuration.Eighth),
    Note.fromPitch(Pitch.fromClass(PitchClass.A, 3), PitchDuration.Eighth),
    Note.fromPitch(Pitch.fromClass(PitchClass.C, 4), PitchDuration.Eighth),
    Note.fromPitch(Pitch.fromClass(PitchClass.A, 3), PitchDuration.Eighth),
    Note.fromPitch(Pitch.fromClass(PitchClass.F, 3), PitchDuration.Eighth),
    Note.fromPitch(Pitch.fromClass(PitchClass.A, 3), PitchDuration.Eighth),
    Note.fromPitch(Pitch.fromClass(PitchClass.C, 4), PitchDuration.Eighth),
    Note.fromPitch(Pitch.fromClass(PitchClass.B, 3), PitchDuration.Eighth),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Color(0xFF60b3e7),
          leading: Ink(
              child: IconButton(
                  icon: Icon(Icons.close, color: Color(0xFF376996)),
                  iconSize: 40,
                  onPressed: () {
                    Navigator.pop(context);
                  })),
        ),
        body: ChangeNotifierProvider(
          create: (context) => PitchMatchGame(notes),
          child: Consumer<PitchMatchGame>(
            builder: (_, pmState, child) {
              return AnimatedContainer(
                child: Center(child: child),
                duration: Duration(milliseconds: 500),
                decoration: pmState.isListening ?
                BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xff60b3e7),
                          Color(0xff6FC0F2),
                          Color(0xff7ec0ee),
                          Color(0xffa1d4f0),
                          Color(0xfffed2a5),
                          Color(0xffd58c69),
                        ]))
                : BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xff60b3e7),
                          Color(0xff7ec0ee),
                          Color(0xff74c1eb),
                          Color(0xffa1d4f0)
                        ]))
              );
            },
            child: PitchMatchManager(notes: notes),
          ),
        ));
  }
}

class PitchMatchManager extends StatefulWidget {
  PitchMatchManager({Key key, this.notes}) : super(key: key);

  final List<Note> notes;

  @override
  _PitchMatchManagerState createState() => _PitchMatchManagerState();
}

class _PitchMatchManagerState extends State<PitchMatchManager> {
  GlobalKey staffContainerKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      var staffSize = staffContainerKey.currentContext.size;
      var noteDim = staffSize.height / 8;
      int numAllowedNotes = (staffSize.width / noteDim).floor();
      var pmState = Provider.of<PitchMatchGame>(context, listen: false);
      pmState.maxStaffNotes = numAllowedNotes;
      if (pmState.currentStaff == 0) pmState.nextNotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
            key: staffContainerKey,
            flex: 6,
            child: Selector<PitchMatchGame, List<Note>>(
              selector: (_, pmState) => pmState.currentNotes,
              builder: (context, notes, child) {
                return PitchMatchStaff(
                  notes: notes,
                );
              },
            )),
        Expanded(
          flex: 1,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Consumer<PitchMatchGame>(builder: (_, pmState, __) {
                  return Container(
                    child: PitchMatchListener(notes: pmState.currentNotes),
                    decoration: ShapeDecoration(
                        shape: ContinuousRectangleBorder(
                            side: BorderSide(color: Colors.amber, width: 3),
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(25),
                                bottomLeft: Radius.circular(25))),
                        color: pmState.isListening
                            ? Theme.of(context).focusColor
                            : Theme.of(context).buttonColor),
                    height: 100,
                    width: 100,
                  );
                }),
                Consumer<PitchMatchGame>(builder: (_, pmState, __) {
                  return Container(
                    child: PitchMatchPlayer(
                      notes: pmState.currentNotes,
                    ),
                    decoration: ShapeDecoration(
                        shape: ContinuousRectangleBorder(
                            side: BorderSide(color: Colors.amber, width: 3),
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(25),
                                bottomRight: Radius.circular(25))),
                        color: pmState.isPlaying
                            ? Theme.of(context).focusColor
                            : Theme.of(context).buttonColor),
                    height: 100,
                    width: 100,
                  );
                }),
              ]),
        ),
        Expanded(
          flex: 1,
          child: CustomPaint(painter: BackgroundPainter(), child: Container()),
        )
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
    path2.lineTo(0, size.height);
    path2.lineTo(size.width, size.height);
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
