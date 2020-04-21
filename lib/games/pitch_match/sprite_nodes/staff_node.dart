import 'package:eager_ear/games/pitch_match/sprite_nodes/feedback_node.dart';
import 'package:eager_ear/shared/note.dart';
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

  NoteNode getNoteNodeByNote(Note note) {
    var noteChildren = children.where((node) {
      if (node is NoteNode)
        return (node).note == note;
      return false;
    });
    if (noteChildren.isEmpty)
      return null;
    else
      return noteChildren.first;
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
