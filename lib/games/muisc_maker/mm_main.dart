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

  Widget _createDraggableNoteWidget(Note noteTemplate) {
    var imagePath = _imagePathFromNote(noteTemplate);
    return Draggable(
      feedback: Image(
        image: AssetImage(imagePath),
        height: 60,
        width: 60,
      ),
      child: Image.asset(imagePath, frameBuilder: _fadeInImage),
      data: noteTemplate,
      onDragStarted: () => _scrollToEndOfMelody(),
      onDragCompleted: () => _scrollToEndOfMelody(),
      onDragEnd: (DraggableDetails dragDetails) {
        if (dragDetails.wasAccepted) {
          Size localSize = staffKey.currentContext.size;
          RenderBox renderBox = staffKey.currentContext.findRenderObject();
          Offset localOffset = renderBox.globalToLocal(dragDetails.offset);
          var percent = ((localOffset.dy + 30) / localSize.height);
          var newNote = _noteFromDrag(
              percent, noteTemplate.pitch.accidental, noteTemplate.duration);
          print(newNote.pitch.pitchClass);
          _notes.add(newNote);
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

  Alignment _alignmentFromNote(Note note) {
    var step = staffSteps[note.pitch.pitchClass];
    if (note.pitch.octave == 3) {
      step += 7;
    }
    var verticalAlignment = (step - 7) / 7;
    return Alignment(0.0, verticalAlignment);
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
                  child: Container(
                    child: ListView.builder(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        itemCount: _notes.length,
                        itemBuilder: (context, index) {
                          return Image(
                            image:
                                AssetImage(_imagePathFromNote(_notes[index])),
                            height: constraints.maxHeight / 8,
                            width: constraints.maxHeight / 8,
                            alignment: _alignmentFromNote(_notes[index]),
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
                onWillAccept: (data) {
                  return true;
                },
                onAccept: (data) {
                  //print(data);
                },
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
