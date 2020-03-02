import 'package:flutter/material.dart';

import 'package:eager_ear/shared/note.dart';

import 'package:assets_audio_player/assets_audio_player.dart';

class PitchMatchPlayer extends StatefulWidget {
  PitchMatchPlayer({Key key,
    this.notes,
    this.player,
    this.currentNoteIndex}) : super(key: key);

  final List<Note> notes;
  final AssetsAudioPlayer player;
  final ValueNotifier currentNoteIndex;

  @override
  _PitchMatchPlayerState createState() => _PitchMatchPlayerState();
}

class _PitchMatchPlayerState extends State<PitchMatchPlayer> {

  IconData _listenButtonIcon = Icons.play_arrow;
  var _audioPaths = List<String>();

  void _playOrStopMelody() {
    if(widget.player.isPlaying.value) {
      widget.player.stop();
      widget.currentNoteIndex.value = -1;
    } else {
      widget.player.openPlaylist(Playlist(assetAudioPaths: _audioPaths));
    }
  }

  @override
  void initState() {
    super.initState();

    for (Note note in widget.notes) {
      _audioPaths.add("assets/audio/" + note.pitch.toString() + ".wav");
    }

    widget.player.isPlaying.listen((isPlaying) {
      isPlaying ? _listenButtonIcon = Icons.stop
          : _listenButtonIcon = Icons.play_arrow;
      setState(() {});
    });
  }

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
              onPressed: _playOrStopMelody,
              color: Colors.white
          )
      )
    );
  }

}