import 'dart:async';
import 'dart:developer';

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
  static const _hertzChannel =
      EventChannel('com.tgconsulting.eager_ear/stream');
  Stream<double> _hertzStream;
  IconData _micIcon = Icons.mic;

  Future<Stream<double>> getHertzStream() async {
    var audioAccessGranted = await requestAudioPermission();
    Stream<double> hertzStream;
    if (audioAccessGranted) {
      hertzStream = _hertzChannel.receiveBroadcastStream().cast<double>();
    }
    return hertzStream;
  }

  Future<bool> requestAudioPermission() async {
    PermissionStatus permissionStatus =
        await PermissionHandler().checkPermissionStatus(PermissionGroup.speech);

    if (permissionStatus != PermissionStatus.granted) {
      Map<PermissionGroup, PermissionStatus> permission =
          await PermissionHandler()
              .requestPermissions([PermissionGroup.speech]);
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

  // TODO: make this a while loop?
  void _checkStream(
      Pitch testPitch, int noteCounter, PitchMatchGame pmState, Stopwatch sw) {
    sw.start();
    if (_hertzStream != null) {
      _hertzStream
          .takeWhile((hertz) => sw.elapsedMilliseconds < 1000)
          .map((hertz) => Pitch.fromHertz(hertz))
          .toList()
          .then((pitches) async {
        sw.stop();
        sw.reset();

        if (_isCorrect(testPitch, pitches)) {
          pmState.setSuccessAnimating(noteCounter++);
          log("good");
        }
        log("bad");

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
    } else {
      return;
    }
  }

  bool _isCorrect(Pitch testPitch, List<Pitch> pitches) {
    var correctPitches = pitches.where((pitch) => pitch == testPitch);
    var percentCorrect = correctPitches.toList().length / pitches.length;
    return percentCorrect > .5;
  }

  void _toggleListener() async {
    var pmState = Provider.of<PitchMatchGame>(context, listen: false);
    if (_hertzStream == null) {
      _hertzStream = await getHertzStream();

      pmState.setIsListening(true);
      pmState.setIsPlaying(false);
      setState(() {
        _micIcon = Icons.mic_none;
      });

      // Transform heard audio stream
      pmState.setHeardHertzStream(_hertzStream
          .transform(StreamTransformer.fromBind((hzStream) async* {
            while (_hertzStream != null) {
              var hzReadings = await hzStream.take(15).toList();
              yield hzReadings;
            }
          }
      )));

      if (_hertzStream != null) {
        int _noteIndexCounter = 0;
        var testPitch = widget.notes[_noteIndexCounter].pitch;

        var stopwatch = new Stopwatch();

        _checkStream(testPitch, _noteIndexCounter, pmState, stopwatch);
        //createCheckStream(testPitch, _pitchStream, _noteIndexCounter);
      } else {
        // Audio access not granted
      }
    } else {
      _cancelListener();
      pmState.setIsListening(false);
      pmState.setHeardHertzStream(null);
    }
  }

  void _cancelListener() {
    _hertzStream = null;
    //_hertzSubscription.cancel();
    setState(() {
      _micIcon = Icons.mic;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PitchMatchGame>(builder: (context, pmState, child) {
      return IconButton(
        icon: Icon(pmState.isPlaying ? Icons.mic_off : _micIcon),
        iconSize: 40,
        disabledColor: Colors.white70,
        onPressed: pmState.isPlaying ? null : _toggleListener,
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
    _hertzStream = null;
    //_hertzSubscription.cancel();
  }
}
