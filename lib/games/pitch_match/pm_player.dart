import 'package:flutter/material.dart';

import 'package:eager_ear/shared/note.dart';

import 'package:assets_audio_player/assets_audio_player.dart';

class PitchMatchPlayer extends StatefulWidget {
  PitchMatchPlayer({Key key, this.notes}) : super(key: key);

  final List<Note> notes;
  final player = AssetsAudioPlayer();

  @override
  _PitchMatchPlayerState createState() => _PitchMatchPlayerState();
}

class _PitchMatchPlayerState extends State<PitchMatchPlayer> {

  IconData _listenButtonIcon = Icons.play_arrow;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Ink(
          decoration: const ShapeDecoration(
              shape: CircleBorder(),
              color: Colors.lightBlue
          ),
          child: IconButton(
              icon: Icon(_listenButtonIcon),
              iconSize: 36.0,
              onPressed: null,
              color: Colors.white
          )
      )
    );
  }

}