import 'dart:async';

import 'package:flutter/material.dart';
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
  StreamSubscription _hertzSubscription;
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

      if (_hertzStream != null) {
        var bufferedStream = _hertzStream.transform<List<double>>(
            StreamTransformer.fromBind((hzStream) async* {
          while (_hertzStream != null) {
            var hzReadings = await hzStream.take(10).toList();
            yield hzReadings;
          }
        })).asBroadcastStream();

        // Set heard audio stream
        pmState.setHeardHertzStream(bufferedStream);

        int _noteIndexCounter = 0;
        Pitch currentPitch;
        var sw = new Stopwatch();
        bool correctHeard = false;
        var heardHertzBuffer = List<double>();
        _hertzSubscription = _hertzStream.listen((hertz) {
          currentPitch = pmState.totalNotes[_noteIndexCounter].pitch;
          var heardPitch = Pitch.fromHertz(hertz);
          if (correctHeard && sw.elapsedMilliseconds <= 1000) {
            heardHertzBuffer.add(hertz);
          } else if (sw.elapsedMilliseconds > 1000) {
            var heardPitches = heardHertzBuffer
                .map<Pitch>((hertz) => Pitch.fromHertz(hertz))
                .toList();
            if (_isCorrect(currentPitch, heardPitches)) {
              pmState.setCurrentNote(_noteIndexCounter++);
              if (_noteIndexCounter == pmState.totalNotes.length) {
                _cancelListener(pmState);
              }
            }
            heardHertzBuffer.clear();
            correctHeard = false;
            sw.stop();
            sw.reset();
          } else {
            correctHeard = heardPitch == currentPitch;
            pmState.wasCorrectHeard(correctHeard);
            if (correctHeard) {
              sw.start();
            }
            else {
              sw.stop();
              sw.reset();
            }
          }
        });
      } else {
        // Audio access not granted
      }
    } else {
      _cancelListener(pmState);
    }
  }

  void _cancelListener(PitchMatchGame pmState) {
    _hertzStream = null;
    _hertzSubscription.cancel();
    pmState.setIsListening(false);
    pmState.setHeardHertzStream(null);
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
    _hertzSubscription?.cancel();
  }
}
