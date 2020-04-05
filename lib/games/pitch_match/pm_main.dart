import 'dart:ui';

import 'package:eager_ear/shared/widgets/pm_background_painter.dart';
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
  PitchMatchMain({this.notes}): super();

  final List<Note> notes;

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
  Future<void> _showCompleteDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Good Job!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('You completed the game!')
              ],
            ),
          ),
          shape: BeveledRectangleBorder(
              borderRadius: BorderRadius.all(
                  Radius.circular(5)
              )
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Exit'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    var pmState = Provider.of<PitchMatchGame>(context, listen: false);
    pmState.addListener(() {
      if (pmState.isComplete) {
        _showCompleteDialog();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
            flex: 6,
            child: LayoutBuilder(builder: (context, constraints) {
              var staffSize = Size(constraints.maxWidth, constraints.maxHeight);
              return PitchMatchStaff(staffSize: staffSize);
            }),
        ),
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
