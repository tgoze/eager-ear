import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:eager_ear/games/muisc_maker/bloc/mm_state.dart';
import 'package:eager_ear/games/muisc_maker/mm_action_bar.dart';
import 'package:eager_ear/shared/simple_melody.dart';
import 'package:eager_ear/shared/music.dart';
import 'package:eager_ear/shared/pitch.dart';
import 'package:eager_ear/shared/note.dart';
import 'package:eager_ear/shared/widgets/staff_painter.dart';
import 'package:eager_ear/shared/constants.dart';

class MusicMakerMain extends StatelessWidget {
  MusicMakerMain({this.melody, this.documentReference}) : super();

  final SimpleMelody melody;
  final DocumentReference documentReference;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MusicMakerState(
          melody: melody,
          documentReference: documentReference,
          modified: false
      ),
      child: Scaffold(
          appBar: MusicMakerActionBar(),
          resizeToAvoidBottomPadding: false,
          body: Center(
            child: Container(
              child: MusicMakerManager(melody: melody),
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                      Color(0xff60b3e7),
                      Color(0xff7ec0ee),
                      Color(0xff74c1eb),
                      Color(0xffa1d4f0)
                    ])),
          ))),
    );
  }
}

class MusicMakerManager extends StatefulWidget {
  MusicMakerManager({Key key, this.melody, this.documentId}) : super(key: key);

  final SimpleMelody melody;
  final String documentId;

  @override
  State<StatefulWidget> createState() => new _MusicMakerManagerState();
}

class _MusicMakerManagerState extends State<MusicMakerManager> {
  GlobalKey staffKey = new GlobalKey();
  List<Note> _notes;
  List<Note> _initialNoteTypes = new List<Note>();
  ScrollController _scrollController = new ScrollController();
  bool _isDragging = false;
  bool _isOverTrash = false;

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
    String imagePath = getImagePathFromNote(note);
    return Draggable(
      maxSimultaneousDrags: 1,
      feedback: Image(
        image: AssetImage(imagePath),
        height: 60,
        width: 60,
      ),
      child: _notes.contains(note)
          ? Image(
              image: AssetImage(getImagePathFromNote(note)),
              height: constraints.maxHeight / 8,
              width: constraints.maxHeight / 8)
          : Image.asset(imagePath, frameBuilder: _fadeInImage),
      data: note,
      childWhenDragging: _notes.contains(note)
          ? Container(
              height: constraints.maxHeight / 8,
              width: constraints.maxHeight / 8)
          : Image.asset(imagePath, frameBuilder: _fadeInImage),
      onDragStarted: () {
        if (!_notes.contains(note)) _scrollToEndOfMelody();
        setState(() {
          _isDragging = true;
        });
      },
      onDragEnd: (DraggableDetails dragDetails) {
        setState(() {
          _isDragging = false;
        });
        if (dragDetails.wasAccepted &&
            staffKey.currentContext.size.contains(dragDetails.offset)) {
          Size localSize = staffKey.currentContext.size;
          RenderBox renderBox = staffKey.currentContext.findRenderObject();
          Offset localOffset = renderBox.globalToLocal(dragDetails.offset);
          var percent = ((localOffset.dy + 30) / localSize.height);
          var newNote =
              _noteFromDrag(percent, note.pitch.accidental, note.duration);
          if (_notes.contains(note)) {
            updateMelody(newNote, _notes.indexOf(note));
          } else {
            addToMelody(newNote);
          }
          setState(() {});
        }
      },
    );
  }

  void addToMelody(Note note) {
    var mmState = Provider.of<MusicMakerState>(context, listen: false);
    mmState.addNote(note);
    _scrollToEndOfMelody();
  }

  void updateMelody(Note newNote, int indexOfOldNote) {
    var mmState = Provider.of<MusicMakerState>(context, listen: false);
    mmState.editNote(newNote, indexOfOldNote);
  }

  void deleteFromMelody(Note note) {
    var mmState = Provider.of<MusicMakerState>(context, listen: false);
    if (_notes.contains(note)) {
      mmState.removeNote(note);
    }
  }

  Note _noteFromDrag(
      double percentOffset, bool isAccidental, PitchDuration duration) {
    PitchClass pitchClass;
    int octave;
    int noteStep = (percentOffset * 15).round();
    if (noteStep > 6) {
      octave = 3;
    } else {
      octave = 4;
    }
    pitchClass = staffPitchClasses[noteStep % 7];
    if (isAccidental)
      pitchClass = relativeAccidentals[pitchClass];
    var pitch = Pitch.fromClass(pitchClass, octave);
    pitch.accidental = isAccidental;
    return Note.fromPitch(pitch, duration);
  }

  Offset _offsetFromNote(Note note, BoxConstraints constraints) {
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
    _notes = widget.melody.notes;
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
            flex: 6,
            key: staffKey,
            child: Stack(children: <Widget>[
              LayoutBuilder(builder: (context, constraints) {
                return CustomPaint(
                  painter: new StaffPainter(),
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
                              offset:
                                  _offsetFromNote(_notes[index], constraints),
                            )
                          ],
                        );
                      }),
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
          flex: 1,
          child: LayoutBuilder(builder: (context, constraints) {
            double deleteIconHeight = constraints.biggest.height * .75;
            double feedBackCircleRadius = constraints.biggest.height * .5;
            return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  AnimatedOpacity(
                    duration: Duration(milliseconds: 500),
                    opacity: _isDragging ? 1.0 : 0.0,
                    child: DragTarget<Note>(
                      builder: (BuildContext context, List<Note> candidateData,
                          List rejectedCandidateData) {
                        return AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.elasticInOut,
                            decoration: ShapeDecoration(
                                shape: CircleBorder(),
                                shadows: [
                                  BoxShadow(
                                      color: Colors.red[600],
                                      spreadRadius: _isOverTrash
                                          ? feedBackCircleRadius
                                          : 0.0),
                                ]),
                            child: Icon(Icons.delete, size: deleteIconHeight));
                      },
                      onWillAccept: (note) {
                        _isOverTrash = true;
                        setState(() {});
                        return true;
                      },
                      onAccept: (note) {
                        _isOverTrash = false;
                        deleteFromMelody(note);
                        setState(() {});
                      },
                      onLeave: (note) {
                        _isOverTrash = false;
                      },
                    ),
                  ),
                ]);
          }),
        ),
        Expanded(
          flex: 1,
          child: Container(
            padding: EdgeInsets.all(5),
            decoration: ShapeDecoration(
              shape: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(50),
                      topLeft: Radius.circular(50)),
                  side: BorderSide(
                      width: 5.0, color: Theme.of(context).buttonColor)),
              color: Theme.of(context).buttonColor.withOpacity(.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                    child: _createDraggableNoteWidget(_initialNoteTypes[0])),
                Expanded(
                    child: _createDraggableNoteWidget(_initialNoteTypes[1])),
                Expanded(
                    child: _createDraggableNoteWidget(_initialNoteTypes[2])),
                Expanded(
                    child: _createDraggableNoteWidget(_initialNoteTypes[3])),
              ],
            ),
          ),
        )
      ],
    );
  }
}
