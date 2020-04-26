import 'dart:async';
import 'dart:math' as math;

import 'package:eager_ear/shared/music.dart';
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

  bool _scoreHertz(Pitch testPitch, List<double> heardHertz, List<double> initialHertz) {
    var pmState = Provider.of<PitchMatchGame>(context, listen: false);

    // Max score
    double maxNoteScore = 3 / pmState.melody.notes.length;

    // Aggregate into incorrect and correct
    var correctHertz = heardHertz
        .where((hertz) => Pitch.fromHertz(hertz) == testPitch).toList();
    var incorrectHertz = heardHertz
        .where((hertz) => Pitch.fromHertz(hertz) != testPitch).toList();
    incorrectHertz.addAll(initialHertz.where((hertz) => hertz != -1));

    // Determine if correct
    var percentCorrect = correctHertz.length / heardHertz.length;
    if (percentCorrect > .5) {
      // Calculate penalties
      double totalIncorrectVariance = 0.0;
      incorrectHertz.forEach((hertz) => totalIncorrectVariance
          += math.min(getDistance(testPitch, Pitch.fromHertz(hertz)), 5));
      var correctnessPenalty = (1 - percentCorrect) * maxNoteScore;
      var timePenalty = (initialHertz.length * maxNoteScore / 300);
      var accuracyPenalty = ((totalIncorrectVariance)
          / (incorrectHertz.length * 5) * maxNoteScore / 3);
      print(correctnessPenalty.toString() + ' ' + timePenalty.toString() + ' ' + accuracyPenalty.toString());
      pmState.reduceNoteScore(correctnessPenalty
          + timePenalty
          + accuracyPenalty);
    } else {
      pmState.reduceNoteScore(maxNoteScore / 10);
    }
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
        // Set heard audio stream
        var bufferedStream = _hertzStream.transform<List<double>>(
            StreamTransformer.fromBind((hzStream) async* {
          while (_hertzStream != null) {
            var hzReadings = await hzStream.take(10).toList();
            yield hzReadings;
          }
        }));
        pmState.setHeardHertzStream(bufferedStream);

        // Listen
        int _noteIndexCounter = pmState.lastSangIndex.value + 1;
        Pitch currentPitch;
        var sw = new Stopwatch();
        bool initialCorrectHeard = false;
        var heardHertzBuffer = List<double>();
        var initialHertzBuffer = List<double>();
        _hertzSubscription = _hertzStream.listen((hertz) {
          currentPitch = pmState.melody.notes[_noteIndexCounter].pitch;
          // If correct pitch hasn't been detected yet
          if (!initialCorrectHeard) {
            initialCorrectHeard = Pitch.fromHertz(hertz) == currentPitch;
            pmState.wasCorrectHeard(initialCorrectHeard);
            if (initialCorrectHeard) {
              sw.start();
            }
            else {
              sw.stop();
              sw.reset();
            }
            // If correct was heard, add to list for checking
          } else if (initialCorrectHeard && sw.elapsedMilliseconds <= 1000) {
            heardHertzBuffer.add(hertz);
            // If collection is over, score, and move to next if correct
          } else if (sw.elapsedMilliseconds > 1000) {
            if (_scoreHertz(currentPitch, heardHertzBuffer, initialHertzBuffer)) {
              pmState.setCurrentNote(_noteIndexCounter++);
              if (_noteIndexCounter == pmState.melody.notes.length) {
                _cancelListener(pmState);
              }
            }
            heardHertzBuffer.clear();
            initialHertzBuffer.clear();
            initialCorrectHeard = false;
            sw.stop();
            sw.reset();
          }

          // Add to initial list if still waiting for correct pitch
          if (!initialCorrectHeard && !sw.isRunning) {
            initialHertzBuffer.add(hertz);
          }

          // Prevent out of memory errors
          if (initialHertzBuffer.length > 100) initialHertzBuffer.clear();
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
        onPressed: pmState.isPlaying || pmState.isComplete
            ? null : _toggleListener,
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
