import 'package:flutter/material.dart';

import 'package:eager_ear/shared/music.dart';
import 'package:eager_ear/shared/pitch.dart';
import 'package:eager_ear/shared/note.dart';
import 'package:eager_ear/shared/widgets/staff_painter.dart';

class MusicMakerMain extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(child: MusicMakerManager()),
    );
  }
}

class MusicMakerManager extends StatefulWidget {
  MusicMakerManager({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _MusicMakerManagerState();
}

class _MusicMakerManagerState extends State<MusicMakerManager> {
  GlobalKey staffKey = new GlobalKey();
  List<Note> _notes = new List<Note>();
  List<Note> _initialNoteTypes = new List<Note>();
  ScrollController _scrollController = new ScrollController();

  Widget _fadeInImage(BuildContext context, Widget child, int frame,
      bool wasSynchronouslyLoaded) {
    if (wasSynchronouslyLoaded) {
      return child;
    }
    return AnimatedOpacity(
      child: child,
      opacity: frame == null ? 0 : 1,
      duration: const Duration(seconds: 1),
      curve: Curves.easeOut,
    );
  }

  Widget _createDraggableNoteWidget(Note note, {BoxConstraints constraints}) {
    String imagePath = _imagePathFromNote(note);
    return Draggable(
      maxSimultaneousDrags: 1,
      feedback: Image(
        image: AssetImage(imagePath),
        height: 60,
        width: 60,
      ),
      child: _notes.contains(note)
          ? Image(
              image: AssetImage(_imagePathFromNote(note)),
              height: constraints.maxHeight / 8,
              width: constraints.maxHeight / 8)
          : Image.asset(imagePath, frameBuilder: _fadeInImage),
      data: note,
      childWhenDragging: _notes.contains(note)
          ? Container(
              height: constraints.maxHeight / 8,
              width: constraints.maxHeight / 8)
          : Image.asset(imagePath, frameBuilder: _fadeInImage),
      onDragStarted: () =>
          _notes.contains(note) ? null : _scrollToEndOfMelody(),
      onDragCompleted: () =>
          _notes.contains(note) ? null : _scrollToEndOfMelody(),
      onDragEnd: (DraggableDetails dragDetails) {
        if (dragDetails.wasAccepted) {
          Size localSize = staffKey.currentContext.size;
          RenderBox renderBox = staffKey.currentContext.findRenderObject();
          Offset localOffset = renderBox.globalToLocal(dragDetails.offset);
          var percent = ((localOffset.dy + 30) / localSize.height);
          var newNote =
              _noteFromDrag(percent, note.pitch.accidental, note.duration);
          if (_notes.contains(note)) {
            _notes[_notes.indexOf(note)] = newNote;
          } else {
            _notes.add(newNote);
          }
          setState(() {});
        }
      },
    );
  }

  String _imagePathFromNote(Note note) {
    switch (note.duration) {
      case PitchDuration.Whole:
      case PitchDuration.Half:
        if (note.pitch.accidental) return 'assets/images/turtle_sharp.png';
        return 'assets/images/turtle.png';
      case PitchDuration.Eighth:
      case PitchDuration.Quarter:
        if (note.pitch.accidental) return 'assets/images/bunny_sharp.png';
        return 'assets/images/bunny.png';
      default:
        return '';
    }
  }

  Note _noteFromDrag(
      double percentOffset, bool isAccidental, PitchDuration duration) {
    Pitch pitch = new Pitch(accidental: isAccidental);
    int noteStep = (percentOffset * 15).round();
    if (noteStep > 6) {
      pitch.octave = 3;
    } else {
      pitch.octave = 4;
    }
    pitch.pitchClass = staffPitchClasses[noteStep % 7];
    if (pitch.accidental)
      pitch.pitchClass = relativeAccidentals[pitch.pitchClass];
    return Note.fromPitch(pitch, duration);
  }

  Offset _alignmentFromNote(Note note, BoxConstraints constraints) {
    var step = staffSteps[note.pitch.pitchClass];
    if (note.pitch.octave == 3) {
      step += 7;
    }
    double verticalOffset = (constraints.maxHeight / 16) * step;
    return Offset(0.0, verticalOffset);
  }

  void _scrollToEndOfMelody() {
    var staffSize = staffKey.currentContext.size;
    var noteWidth = staffSize.height / 8;
    _scrollController.animateTo(
        (_notes.length * noteWidth) + (staffSize.width / 2),
        duration: Duration(milliseconds: 500),
        curve: Curves.easeIn);
  }

  @override
  void initState() {
    super.initState();
    _initialNoteTypes = [
      Note.fromPitch(Pitch(accidental: false), PitchDuration.Quarter),
      Note.fromPitch(Pitch(accidental: true), PitchDuration.Quarter),
      Note.fromPitch(Pitch(accidental: false), PitchDuration.Half),
      Note.fromPitch(Pitch(accidental: true), PitchDuration.Half),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
            flex: 8,
            key: staffKey,
            child: Stack(children: <Widget>[
              LayoutBuilder(builder: (context, constraints) {
                return CustomPaint(
                  painter: new StaffPainter(),
                  child: GestureDetector(
                    onVerticalDragUpdate: (DragUpdateDetails dragDetails) {
                      print(dragDetails.localPosition);
                    },
                    child: ListView.builder(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        itemCount: _notes.length,
                        itemBuilder: (context, index) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Transform.translate(
                                child: _createDraggableNoteWidget(_notes[index],
                                    constraints: constraints),
                                offset: _alignmentFromNote(
                                    _notes[index], constraints),
                              )
                            ],
                          );
                        }),
                  ),
                );
              }),
              DragTarget<Note>(
                builder: (BuildContext context, List<Note> candidateData,
                    List rejectedCandidateData) {
                  return Container();
                },
                onWillAccept: (data) => true,
              ),
            ])),
        Expanded(
          flex: 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(child: _createDraggableNoteWidget(_initialNoteTypes[0])),
              Expanded(child: _createDraggableNoteWidget(_initialNoteTypes[1])),
              Expanded(child: _createDraggableNoteWidget(_initialNoteTypes[2])),
              Expanded(child: _createDraggableNoteWidget(_initialNoteTypes[3])),
            ],
          ),
        )
      ],
    );
  }
}
