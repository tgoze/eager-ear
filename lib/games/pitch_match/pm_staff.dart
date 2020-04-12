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
    pmState.previewNote.addListener(() {
      int newIndex = pmState.previewNote.value;
      if (newIndex < pmState.currentNotes.length && newIndex >= 0) {
        NoteNode noteNode = rootStaffNode.getNotes()[newIndex];
        noteNode.animatePreviewHop();
      }
    });

    // Listener to give feedback on note node
    pmState.correctHeard.addListener(() {
      var index = (pmState.currentNote.value + 1) % pmState.maxStaffNotes;
      NoteNode noteNode = rootStaffNode.getNotes()[index];
      if (pmState.correctHeard.value)
        noteNode.animateShake(30, 1.0);
      else
        noteNode.stopShakeAnimations();
    });

    // Listener to animate success hop
    pmState.currentNote.addListener(() async {
      var index = pmState.currentNote.value % pmState.maxStaffNotes;
      NoteNode noteNode = rootStaffNode.getNotes()[index];
      noteNode.stopShakeAnimations();
      await noteNode.animateSuccessHop();
      if (index == pmState.maxStaffNotes - 1) pmState.nextNotes();
      if (pmState.currentNote.value + 1 == pmState.totalNotes.length)
        pmState.setIsComplete(true);
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
          var index = (pmState.currentNote.value + 1) % pmState.maxStaffNotes;
          double dx = rootStaffNode.getNotes()[index].position.dx;
          _heardHertzSprite.animateToStaffPosition(staffSize, dx, hertzList);
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
    return Container(
      key: staffKey,
      child: Selector<PitchMatchGame, List<Note>>(
          selector: (_, pmState) => pmState.currentNotes,
          builder: (context, notes, child) {
            if (_assetsLoaded && rootStaffNode != null) {
              if (rootStaffNode.getNotes() != null) rootStaffNode.removeNotes();

              ui.Image image;
              for (Note note in notes) {
                image = _noteImages[getImagePathFromNote(note)];
                var noteNode = NoteNode(image, note, widget.staffSize);
                rootStaffNode.addNoteChild(noteNode);
                noteNode.animateHopToStaff(notes);
              }

              // Add heard hertz carrot sprite
              if (!rootStaffNode.hasFeedbackNode()) {
                var heardHertzImage = _noteImages[feedbackImagePath];
                _heardHertzSprite = FeedbackNode(heardHertzImage);
                rootStaffNode.addNoteChild(_heardHertzSprite);
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
