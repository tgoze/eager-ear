import 'dart:ui';

import 'package:eager_ear/shared/constants.dart';
import 'package:eager_ear/shared/simple_melody.dart';
import 'package:eager_ear/shared/widgets/pm_background_painter.dart';
import 'package:flutter/material.dart';

import 'package:eager_ear/games/pitch_match/pm_listener.dart';
import 'package:eager_ear/games/pitch_match/pm_player.dart';
import 'package:eager_ear/games/pitch_match/pm_staff.dart';
import 'package:eager_ear/shared/music.dart';
import 'package:eager_ear/shared/note.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

import 'bloc/pm_game.dart';
import 'bloc/pm_settings.dart';

class PitchMatchMain extends StatelessWidget {
  PitchMatchMain({this.notes, this.lowerVoice}) : super();

  final List<Note> notes;
  final bool lowerVoice;

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
        body: Consumer<PitchMatchGame>(
          builder: (_, pmState, child) {
            return AnimatedContainer(
                child: Center(child: child),
                duration: Duration(milliseconds: 500),
                decoration: pmState.isListening
                    ? BoxDecoration(
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
                          ])));
          },
          child: PitchMatchManager(notes: notes),
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
    var pmState = Provider.of<PitchMatchGame>(context, listen: false);
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Good Singing!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Center(
                  child: SmoothStarRating(
                    size: 50,
                    allowHalfRating: true,
                    starCount: 3,
                    color: Colors.yellow,
                    borderColor: Colors.yellow,
                    rating: pmState.melody.melodyScore.getScore(),
                  ),
                )
              ],
            ),
          ),
          shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(50))),
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

  Future<int> _getPitchMatchInstructionCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.get('PitchMatchInstructionCount') ?? 0;
  }

  Future<Null> _setPitchMatchInstructionCount(int count) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('PitchMatchInstructionCount', count);
  }

  Future<void> _showInstructionDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Instructions'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                          child: Image.asset(noteImagePaths[1]
                          )
                      ),
                      Expanded(
                        child: Transform.rotate(
                          angle: 45.0,
                          child: Image.asset(feedbackImagePath,
                            height: 75,
                            width: 75
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: Text('The \"sharp\" animals are picky. Feed them their carrots sideways!'),
                )
              ],
            ),
          ),
          shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(50))),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
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

    var pmSettingsState =
        Provider.of<PitchMatchSettingsState>(context, listen: false);
    var pmState = Provider.of<PitchMatchGame>(context, listen: false);

    //Set octaves from settings state
    pmState.setOctaves(pmSettingsState.lowerVoice);

    // Set listener to complete game
    pmState.addListener(() {
      if (pmState.isComplete) {
        pmState.melodyDocumentReference.get().then((snapshot) {
          var oldMelody = SimpleMelody.fromJson(snapshot.data);
          if (oldMelody.melodyScore != null) {
            // Update score if better than last score
            if (oldMelody.melodyScore.getScore() <
                pmState.melody.melodyScore.getScore()) {
              pmState.melodyDocumentReference.updateData(<String, dynamic>{
                'melodyScore': pmState.melody.melodyScore.toJson()
              }).catchError((error) {
                var snackBar = SnackBar(
                    content: Text('Error saving score'));
                Scaffold.of(context).showSnackBar(snackBar);
              });
            }
          } else {
            pmState.melodyDocumentReference.updateData(<String, dynamic>{
              'melodyScore': pmState.melody.melodyScore.toJson()
            }).catchError((error) {
              var snackBar = SnackBar(
                  content: Text('Error saving score'));
              Scaffold.of(context).showSnackBar(snackBar);
            });
          }
        });
        _showCompleteDialog();
      }
    });

    SchedulerBinding.instance.addPostFrameCallback((_) {
      // Show instructions first two times a melody with accidentals is seen
      if (pmState.melody.notes
          .where((note) => isAccidental(note.pitch.pitchClass)).length > 0)
        _getPitchMatchInstructionCount().then((count) {
          if (count <= 2) {
            _setPitchMatchInstructionCount(count++);
            _showInstructionDialog();
          }
        });
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
                            side: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 3),
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(25),
                                bottomLeft: Radius.circular(25))),
                        color: pmState.isListening || pmState.isComplete
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).accentColor),
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
                            side: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 3),
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(25),
                                bottomRight: Radius.circular(25))),
                        color: pmState.isPlaying || pmState.isComplete
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).accentColor),
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
