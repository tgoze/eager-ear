import 'dart:async';
import 'dart:ui' as ui;

import 'package:eager_ear/games/pitch_match/sprite_nodes/feedback_node.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
  PitchMatchStaff({
    Key key,
    this.notes,
    this.previewIndex,
    this.successIndex,
    this.backgroundSize,
  }) : super(key: key);

  final List<Note> notes;
  final ValueNotifier previewIndex;
  final ValueNotifier successIndex;
  final Size backgroundSize;

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
    await noteImages.load(<String>[
      'assets/images/bunny.png',
      'assets/images/turtle.png',
      'assets/images/carrot.png'
    ]);
    _noteImages = noteImages;
  }

  @override
  void initState() {
    super.initState();

    rootStaffNode = StaffNode(null, null);

    _loadNoteAssets().then((_) {
      setState(() {
        _assetsLoaded = true;
      });
    });

    var pmState = Provider.of<PitchMatchGame>(context, listen: false);

    pmState.previewAnimating.addListener(() {
      int newIndex = pmState.previewAnimating.value;
      if (newIndex < widget.notes.length && newIndex >= 0) {
        NoteNode noteNode = rootStaffNode.children[newIndex];
        noteNode.animatePreviewHop();
      }
    });

    pmState.successAnimating.addListener(() {
      NoteNode noteNode =
          rootStaffNode.children[pmState.successAnimating.value];
      noteNode.animateSuccessHop(staffKey.currentContext.size);
    });

    pmState.addListener(() {
      if (pmState.heardHertzStream != null && _heardHertzSubscription == null) {
        _heardHertzSubscription = pmState.heardHertzStream.listen((hertzList) {
          _heardHertzSprite.visible = true;
          _heardHertzSprite.animateToStaffPosition(
              staffKey.currentContext.size, hertzList);
        });
      } else if (_heardHertzSubscription != null) {
        _heardHertzSubscription.cancel();
        _heardHertzSubscription = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (rootStaffNode.children.isNotEmpty) rootStaffNode.removeAllChildren();

    return Container(
      child: Stack(
        key: staffKey,
        children: <Widget>[
          Padding(
              padding: EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
              child: CustomPaint(
                painter: new StaffPainter(),
                child: Container(
                  constraints:
                      BoxConstraints.tight(MediaQuery.of(context).size),
                ),
              )),
          LayoutBuilder(builder: (context, constraints) {
            if (_assetsLoaded) {
              var staffSize = Size(constraints.maxWidth, constraints.maxHeight);
              rootStaffNode = StaffNode(widget.notes, staffSize);
              ui.Image image;
              for (Note note in widget.notes) {
                switch (note.duration) {
                  case PitchDuration.Eighth:
                    image = _noteImages['assets/images/bunny.png'];
                    break;
                  default:
                    image = _noteImages['assets/images/bunny.png'];
                    break;
                }
                var noteNode = NoteNode(image, note);
                rootStaffNode.addNoteChild(noteNode);
                noteNode.animateHopToStaff(staffSize, widget.notes);
              }

              // Add heard hertz carrot sprite
              var heardHertzImage = _noteImages['assets/images/carrot.png'];
              _heardHertzSprite = FeedbackNode(heardHertzImage);
              rootStaffNode.addNoteChild(_heardHertzSprite);
            }
            return SpriteWidget(
                rootStaffNode, SpriteBoxTransformMode.nativePoints);
          })
        ],
      ),
    );
  }
}
