import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'package:eager_ear/shared/note.dart';
import 'package:eager_ear/shared/pitch.dart';
import 'bloc/pm_game.dart';

class PitchMatchListener extends StatefulWidget {
  PitchMatchListener({Key key, this.notes}) : super(key: key);
  final List<Note> notes;

  @override
  State<StatefulWidget> createState() => _PitchMatchListenerState();
}

class _PitchMatchListenerState extends State<PitchMatchListener> {
  static const _hertzStream = EventChannel('com.tgconsulting.eager_ear/stream');
  Stream<Pitch> _pitchStream;
  StreamSubscription _pitchSubscription;
  Color _micColor = Colors.white;

  Future<Stream<Pitch>> startPitchStream() async {
    var audioAccessGranted = await requestAudioPermission();
    Stream<Pitch> pitchStream;
    if (audioAccessGranted) {
      pitchStream = _hertzStream.receiveBroadcastStream()
          .map((hertz) => Pitch.fromHertz(hertz));
    }
    return pitchStream;
  }

  Future<bool> requestAudioPermission() async {
    PermissionStatus permissionStatus = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.speech);

    if (permissionStatus != PermissionStatus.granted) {
      Map<PermissionGroup, PermissionStatus> permission =
      await PermissionHandler().requestPermissions([PermissionGroup.speech]);
      permissionStatus = permission[PermissionGroup.speech];
    }

    return permissionStatus == PermissionStatus.granted;
  }

//  // Timeout method
//  void createCheckStream(Pitch testPitch, Stream<Pitch> stream, int noteCounter) async {
//    var pmState = Provider.of<PitchMatchGame>(context, listen: false);
//
//    if (stream != null) {
//      _pitchSubscription = stream.where((pitch) => pitch != testPitch)
//        .timeout(Duration(seconds: 1), onTimeout: (timedOut) {
//          timedOut.add(testPitch);
//        })
//        .listen((Pitch pitch) async {
//          log(pitch.toString());
//          if (pitch == testPitch) {
//            log(pitch.toString());
//
//            pmState.setSuccessAnimating(noteCounter++);
//
//            if (noteCounter == widget.notes.length) {
//              pmState.nextNotes();
//              await SchedulerBinding.instance.endOfFrame;
//              noteCounter = 0;
//            }
//
//            if (widget.notes.isEmpty) {
//              _pitchSubscription.cancel();
//              _cancelListener();
//              return;
//            }
//
//            testPitch = widget.notes[noteCounter].pitch;
//            await _pitchSubscription.cancel();
//            createCheckStream(testPitch, stream, noteCounter);
//          }
//        });
//    } else {
//      return null;
//    }
//  }

  void _checkStream(Pitch testPitch, int noteCounter, PitchMatchGame pmState,
      Stopwatch sw) {
    sw.start();
    _pitchStream
      .takeWhile((pitch) => sw.elapsedMilliseconds < 1000)
      .toList().then((pitches) async {
        sw.stop();
        sw.reset();

        if (_isCorrect(testPitch, pitches)) {
          pmState.setSuccessAnimating(noteCounter++);
        }

        if (noteCounter == widget.notes.length) {
          pmState.nextNotes();
          await SchedulerBinding.instance.endOfFrame;
          noteCounter = 0;
        }

        if (widget.notes.isEmpty) {
          _cancelListener();
          return;
        }

        _checkStream(widget.notes[noteCounter].pitch, noteCounter, pmState, sw);
      });
  }

  bool _isCorrect(Pitch testPitch, List<Pitch> pitches) {
    var correctPitches = pitches.where((pitch) => pitch == testPitch);
    var percentCorrect = correctPitches.toList().length / pitches.length;
    return percentCorrect > .5;
  }

  void _toggleListener() async {
    if (_pitchSubscription == null && _pitchStream == null) {
      _pitchStream = await startPitchStream();
      setState(() { _micColor = Colors.white70; });

      if (_pitchStream != null) {
        int _noteIndexCounter = 0;
        var testPitch = widget.notes[_noteIndexCounter].pitch;
        PitchMatchGame pmState =
            Provider.of<PitchMatchGame>(context, listen: false);
        var stopwatch = new Stopwatch();

        _checkStream(testPitch, _noteIndexCounter, pmState, stopwatch);
        //createCheckStream(testPitch, _pitchStream, _noteIndexCounter);
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
      _pitchStream = null;
    }
    setState(() { _micColor = Colors.white; });
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.mic),
      iconSize: 40,
      color: _micColor,
      onPressed: _toggleListener,
    );
  }
}