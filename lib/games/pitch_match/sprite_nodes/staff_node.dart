import 'package:eager_ear/games/pitch_match/sprite_nodes/feedback_node.dart';
import 'package:flutter/material.dart';

import 'package:spritewidget/spritewidget.dart';

import 'note_node.dart';

class StaffNode extends NodeWithSize {
  final Size staffSize;

  StaffNode(this.staffSize) : super(Size(1024, 1024));

  void addNoteChild(Sprite child) {
    double noteDim = staffSize.height / 8;
    child.size = Size.square(noteDim);
    child.visible = false;
    super.addChild(child);
  }

  List<Node> getNotes() {
    return children.where((node) => node is NoteNode).toList();
  }

  void removeNotes() {
    getNotes().forEach((noteNode) => this.removeChild(noteNode));
  }

  bool hasFeedbackNode() {
    bool hasFeedbackNode = false;
    if (children != null)
      hasFeedbackNode =
          children.where((node) => node is FeedbackNode).length > 0;
    return hasFeedbackNode;
  }
}
