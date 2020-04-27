import 'dart:async';
import 'dart:ui' as ui;

import 'package:eager_ear/games/pitch_match/sprite_nodes/feedback_node.dart';
import 'package:eager_ear/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:spritewidget/spritewidget.dart';

import 'bloc/pm_game.dart';
import 'package:eager_ear/shared/music.dart';
import 'package:eager_ear/shared/note.dart';
import 'package:eager_ear/shared/widgets/staff_painter.dart';
import 'package:eager_ear/games/pitch_match/sprite_nodes/note_node.dart';
import 'package:eager_ear/games/pitch_match/sprite_nodes/staff_node.dart';
import 'package:provider/provider.dart';

import 'bloc/pm_settings.dart';

class PitchMatchStaff extends StatefulWidget {
  PitchMatchStaff({Key key, this.staffSize}) : super(key: key);

  final Size staffSize;

  @override
  State<StatefulWidget> createState() => new _PitchMatchStaffState();
}

class _PitchMatchStaffState extends State<PitchMatchStaff> {
  StaffNode rootStaffNode;
  GlobalKey staffKey = GlobalKey();
  bool _assetsLoaded = false;
  ImageMap _noteImages;
  FeedbackNode _heardHertzSprite;
  StreamSubscription _heardHertzSubscription;

  Future<Null> _loadNoteAssets() async {
    ImageMap noteImages = new ImageMap(rootBundle);
    await noteImages.load(noteImagePaths);
    _noteImages = noteImages;
  }

  @override
  void initState() {
    super.initState();

    var pmState = Provider.of<PitchMatchGame>(context, listen: false);
    var pmSettings = Provider.of<PitchMatchSettingsState>(context, listen: false);
    var noteDim = widget.staffSize.height / 8;
    int numAllowedNotes = (widget.staffSize.width / noteDim).floor();
    pmState.maxStaffNotes = numAllowedNotes;

    _loadNoteAssets().then((_) {
      setState(() {
        _assetsLoaded = true;
      });
    });

    rootStaffNode = StaffNode(widget.staffSize);

    // Listener to animate preview hop
    pmState.audioIndex.addListener(() {
      if (pmState.audioIndex.value != -1) {
        int playingIndex = pmState.audioIndex.value +
            (pmState.currentStaff - 1) * pmState.maxStaffNotes;
        var nextNote = pmState.melody.notes[playingIndex];
        NoteNode noteNode = rootStaffNode.getNoteNodeByNote(nextNote);
        noteNode?.animatePreviewHop();
      }
    });

    // Listener to give feedback on note node
    pmState.correctHeard.addListener(() {
      var nextNote = pmState.melody.notes[pmState.lastSangIndex.value + 1];
      NoteNode noteNode = rootStaffNode.getNoteNodeByNote(nextNote);
      if (pmState.correctHeard.value)
        noteNode.animateShake(30, 1.0);
      else
        noteNode.stopShakeAnimations();
    });

    // Listener to animate success hop
    pmState.lastSangIndex.addListener(() {
      var currentNote = pmState.melody.notes[pmState.lastSangIndex.value];
      NoteNode noteNode = rootStaffNode.getNoteNodeByNote(currentNote);
      noteNode.stopShakeAnimations();
      if (currentNote == pmState.currentNotes.last) pmState.nextNotes();
      noteNode.animateSuccessHop().whenComplete(() {
        if (pmState.lastSangIndex.value + 1 == pmState.melody.notes.length
            && !pmState.isComplete)
          pmState.setIsComplete(true);
      });
    });

    // Listener for feedback node
    pmState.addListener(() {
      var staffSize = staffKey.currentContext.size;
      if (pmState.heardHertzStream != null && _heardHertzSubscription == null) {
        _heardHertzSubscription = pmState.heardHertzStream.listen((hertzList) {
          if (_heardHertzSprite.hidden) {
            Sprite firstNoteSprite = rootStaffNode.getNotes()[0];
            _heardHertzSprite.animateEntryToStaff(
                staffSize, firstNoteSprite.position.dx);
          }
          var nextNote = pmState.melody.notes[pmState.lastSangIndex.value + 1];
          NoteNode noteNode = rootStaffNode.getNoteNodeByNote(nextNote);
          double dx = noteNode.position.dx;
          _heardHertzSprite.animateToStaffPosition(staffSize, dx, hertzList,
              pmSettings.lowerVoice);
        });
      }
      if (!pmState.isListening && _heardHertzSubscription != null) {
        _heardHertzSubscription?.cancel();
        _heardHertzSubscription = null;
        _heardHertzSprite?.animateExit(staffSize);
      }
    });

    SchedulerBinding.instance.addPostFrameCallback((_) {
      pmState.nextNotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    var lowerVoice = Provider.of<PitchMatchSettingsState>(context).lowerVoice;
    return Container(
      key: staffKey,
      child: Consumer<PitchMatchGame>(
          builder: (context, pmState, child) {
            if (pmState.lastSangIndex.value + 1 < pmState.melody.notes.length) {
              var nextNote =
                  pmState.melody.notes[pmState.lastSangIndex.value + 1];
              if (_assetsLoaded &&
                  rootStaffNode != null &&
                  rootStaffNode.getNoteNodeByNote(nextNote) == null) {
                ui.Image image;
                for (Note note in pmState.currentNotes) {
                  image = _noteImages[getImagePathFromNote(note)];
                  var noteNode = NoteNode(image, note, widget.staffSize);
                  rootStaffNode.addNoteChild(noteNode);
                  noteNode.animateHopToStaff(pmState.currentNotes, lowerVoice);
                }

                // Add heard hertz carrot sprite
                if (!rootStaffNode.hasFeedbackNode()) {
                  var heardHertzImage = _noteImages[feedbackImagePath];
                  _heardHertzSprite = FeedbackNode(heardHertzImage);
                  rootStaffNode.addNoteChild(_heardHertzSprite);
                }
              }
            }
            return CustomPaint(
              painter: new StaffPainter(),
              child: Container(
                constraints: BoxConstraints.tight(MediaQuery.of(context).size),
                child: child,
              ),
            );
          },
          child:
              SpriteWidget(rootStaffNode, SpriteBoxTransformMode.nativePoints)),
    );
  }
}
