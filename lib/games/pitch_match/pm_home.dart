import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:eager_ear/games/pitch_match/pm_main.dart';
import 'package:eager_ear/games/pitch_match/pm_settings.dart';
import 'package:eager_ear/games/pitch_match/bloc/pm_game.dart';
import 'package:eager_ear/shared/simple_melody.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'bloc/pm_settings.dart';

class PitchMatchHome extends StatelessWidget {
  Future<bool> _getPitchMatchLowerVoiceSetting() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.get('PitchMatchLowerVoice') ?? false;
  }

  Widget _buildMelodyItem(BuildContext context, DocumentSnapshot document) {
    var melody = SimpleMelody.fromJson(document.data);
    return Consumer<PitchMatchSettingsState>(
      builder: (_, pmSettingsState, __) {
        return GestureDetector(
          child: Card(
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.music_note),
                  title: Text(melody.title),
                  trailing: SmoothStarRating(
                    allowHalfRating: true,
                    starCount: 3,
                    color: Colors.yellow,
                    borderColor: Colors.yellow,
                    rating: melody.melodyScore == null
                        ? 0.0
                        : melody.melodyScore.getScore(),
                  ),
                )
              ],
            ),
          ),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => MultiProvider(providers: [
                          ChangeNotifierProvider(
                              create: (_) =>
                                  PitchMatchGame(melody, document.reference)),
                          ChangeNotifierProvider.value(value: pmSettingsState)
                        ], child: PitchMatchMain())));
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getPitchMatchLowerVoiceSetting(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ChangeNotifierProvider(
            create: (context) =>
                PitchMatchSettingsState(lowerVoice: snapshot.data),
            child: Scaffold(
              appBar: AppBar(
                elevation: 0.0,
                backgroundColor: Theme.of(context).primaryColor,
                title: Text("Pitch Match"),
                leading: IconButton(
                    icon: Icon(Icons.home),
                    iconSize: 40,
                    onPressed: () {
                      Navigator.pop(context);
                    }),
                actions: <Widget>[
                  Consumer<PitchMatchSettingsState>(
                    builder: (_, pmSettingsState, __) {
                      return IconButton(
                          icon: Icon(Icons.settings),
                          iconSize: 40,
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ChangeNotifierProvider.value(
                                            value: pmSettingsState,
                                            child: PitchMatchSettings())));
                          });
                    },
                  ),
                ],
              ),
              body: Center(
                child: StreamBuilder(
                    stream:
                        Firestore.instance.collection('melodies').snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData)
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[CircularProgressIndicator()],
                        );
                      return ListView.builder(
                          itemCount: snapshot.data.documents.length,
                          itemBuilder: (context, index) {
                            return _buildMelodyItem(
                                context, snapshot.data.documents[index]);
                          });
                    }),
              ),
            ),
          );
        }
        return Container();
      },
    );
  }
}
