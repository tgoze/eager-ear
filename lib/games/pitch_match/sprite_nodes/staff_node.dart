import 'package:eager_ear/games/pitch_match/sprite_nodes/note_node.dart';
import 'package:flutter/material.dart';

import 'package:eager_ear/shared/note.dart';
import 'package:spritewidget/spritewidget.dart';

class StaffNode extends NodeWithSize {
  final List<Note> notes;
  final Size staffSize;

  StaffNode(this.notes, this.staffSize) : super(Size(1024, 1024));

  void addNoteChild(Sprite child) {
    double noteDim = staffSize.height / 8;
    child.size = Size.square(noteDim);
    child.visible = false;
    super.addChild(child);
  }
}