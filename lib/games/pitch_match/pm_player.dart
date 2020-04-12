import 'package:eager_ear/shared/constants.dart';
import 'package:flutter/material.dart';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:provider/provider.dart';

import 'bloc/pm_game.dart';
import 'package:eager_ear/shared/note.dart';

class PitchMatchPlayer extends StatefulWidget {
  PitchMatchPlayer({Key key, this.notes}) : super(key: key);

  final List<Note> notes;

  @override
  _PitchMatchPlayerState createState() => _PitchMatchPlayerState();
}

class _PitchMatchPlayerState extends State<PitchMatchPlayer> {
  AssetsAudioPlayer player = new AssetsAudioPlayer();
  IconData _listenButtonIcon = Icons.play_arrow;
  var _audioPaths = List<String>();

  void _playOrStopMelody() {
    var pmState = Provider.of<PitchMatchGame>(context, listen: false);
    if (player.isPlaying.value) {
      player.stop();
      pmState.setPreviewNote(-1);
      pmState.setIsPlaying(false);
      setState(() { _listenButtonIcon = Icons.play_arrow; });
    } else {
      var currentIndex = (pmState.currentNote.value + 1) % pmState.maxStaffNotes;
      player.openPlaylist(Playlist(assetAudioPaths: _audioPaths));
      player.playlistPlayAtIndex(currentIndex);
      pmState.setIsPlaying(true);
      pmState.setIsListening(false);
      setState(() { _listenButtonIcon = Icons.stop; });
    }
  }

  @override
  void initState() {
    super.initState();

    player.playlistCurrent.listen((playlistPlayingAudio) {
      Provider.of<PitchMatchGame>(context, listen: false)
          .setPreviewNote(playlistPlayingAudio.index);
    });

    player.playlistAudioFinished.listen((playlistAudio) {
      if (playlistAudio.playlist.assetAudioPaths.length ==
            playlistAudio.index + 1) {
        setState(() { _listenButtonIcon = Icons.play_arrow; });
        Provider.of<PitchMatchGame>(context, listen: false)
            .setIsPlaying(false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _audioPaths.clear();

    for (Note note in widget.notes) {
      setState(() {
        _audioPaths.add(getAudioPathFromNote(note));
      });
    }

    return Consumer<PitchMatchGame>(
      builder: (context, pmState, child) {
        return IconButton(
            icon: Icon(_listenButtonIcon),
            iconSize: 36.0,
            onPressed: pmState.isListening ? null: _playOrStopMelody,
            disabledColor: Colors.white70
        );
      }
    );
  }
}