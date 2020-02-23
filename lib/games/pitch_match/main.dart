import 'dart:async';

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
        child: PitchMatchManager(notes: notes)
        ),
      );
  }
}

class PitchMatchManager extends StatefulWidget {
  PitchMatchManager({Key key, this.notes}) : super(key: key);

  final List<Note> notes;

  @override
  _PitchMatchManagerState createState() => _PitchMatchManagerState();
}

class _PitchMatchManagerState extends State<PitchMatchManager>
    with SingleTickerProviderStateMixin {

  Stream<Pitch> _pitchStream;
  StreamSubscription _pitchSubscription;
  IconData _listenButtonIcon = Icons.play_arrow;
  int _currentNoteIndex = 0;
  AnimationController _noteAnimationController;

  void _toggleListening() async {
    var pmListener = new PitchMatchListener();

    if (_pitchSubscription == null) {
      _pitchStream = await pmListener.startPitchStream();

      if (_pitchStream != null) {
        int noteIndex = 0;
        _pitchSubscription = _pitchStream.listen((Pitch pitch) {
          if (noteIndex >= widget.notes.length) {
            _cancelListener();
          }
          else if (pitch == widget.notes[noteIndex].pitch) {
            setState(() { _currentNoteIndex = noteIndex; });
            if (noteIndex == 0)
              _noteAnimationController.reset();
            _noteAnimationController.animateTo((noteIndex + 1)
                * (1 / widget.notes.length));
            noteIndex++;
          }
        });

        setState(() { _listenButtonIcon = Icons.stop; });
      } else {
        // Audio access not granted
      }
    } else {
      _cancelListener();
    }
  }

  void _cancelListener() {
    if (_pitchSubscription != null) {
      _pitchSubscription.cancel();
      _pitchSubscription = null;
    }
    setState(() { _listenButtonIcon = Icons.play_arrow; });
  }

  @override
  void initState() {
    super.initState();
    _noteAnimationController = AnimationController(
        duration: Duration(seconds: 2),
        vsync: this
    );
  }

  @override
  void dispose() {
    _noteAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        PitchMatchStaff(
          notes: widget.notes,
          currentNoteIndex: _currentNoteIndex,
          noteAnimationController: _noteAnimationController,
        ),
        Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Ink(
                decoration: const ShapeDecoration(
                  shape: CircleBorder(),
                  color: Colors.lightBlue
                ),
                child: IconButton(
                  icon: Icon(_listenButtonIcon),
                  iconSize: 36.0,
                  onPressed: _toggleListening,
                  color: Colors.white
                )
              )
            )
          ],
        )
      ],
    );
  }
}