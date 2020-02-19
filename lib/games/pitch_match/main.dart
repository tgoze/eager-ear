import 'dart:developer';

import 'package:eager_ear/games/pitch_match/pm_listener.dart';
import 'package:flutter/material.dart';

import 'package:eager_ear/games/pitch_match/pm_staff.dart';
import 'package:eager_ear/shared/music.dart';
import 'package:eager_ear/shared/note.dart';
import 'package:eager_ear/shared/pitch.dart';

class PitchMatchMain extends StatelessWidget {
  final List<Note> notes = [
    Note.fromPitch(Pitch.fromClass(PitchClass.F, 4), PitchDuration.Eighth),
    Note.fromPitch(Pitch.fromClass(PitchClass.A, 4), PitchDuration.Eighth),
    Note.fromPitch(Pitch.fromClass(PitchClass.C, 5), PitchDuration.Eighth),
  ];

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
              notes: notes
            ),
            PitchMatchManager(
              notes: notes
            )
          ],
        ),
      )
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

  String _feedback = '';

  void _start() async {
    bool isCorrect = false;
    PitchMatchListener pmListener = new PitchMatchListener();

    for(Note note in widget.notes) {
      do {
        isCorrect = await pmListener.listenForPitch(note.pitch);
        if (isCorrect) {
          setState(() {
            _feedback = "Got a " + note.pitch.pitchClass.toString();
          });
        }
      } while(!isCorrect);
    }

    setState(() {
      _feedback = "Fuck ya!";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Ink(
            decoration: const ShapeDecoration(
              shape: CircleBorder(),
              color: Colors.teal
            ),
            child: IconButton(
              icon: Icon(Icons.play_arrow),
              iconSize: 36.0,
              onPressed: _start,
              color: Colors.white
            )
          )
        ),
        Expanded(
          flex: 1,
          child: Ink(
            decoration: const ShapeDecoration(
                shape: CircleBorder(),
                color: Colors.teal
            ),
            child: IconButton(
                icon: Icon(Icons.stop),
                iconSize: 36.0,
                onPressed: ()=>log('stop'),
                color: Colors.white
            )
          )
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 102.0),
          child: Center(
            child: Text(
              _feedback,
              style: TextStyle(
                  color: Colors.teal,
                  fontWeight: FontWeight.w500,
                  fontSize: 23.0),
            ),
          ),
        )
      ],
    );
  }
}