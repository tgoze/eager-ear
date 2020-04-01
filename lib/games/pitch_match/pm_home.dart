import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:eager_ear/shared/note.dart';
import 'package:eager_ear/games/pitch_match/pm_main.dart';

class PitchMatchHome extends StatelessWidget {
  Widget _buildMelodyItem(BuildContext context, DocumentSnapshot document) {
    var notes =
        (document['notes'] as List).map((json) => Note.fromJson(json)).toList();
    return GestureDetector(
      child: Card(
        child: Column(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.music_note),
              title: Text(document['title']),
            )
          ],
        ),
      ),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PitchMatchMain(notes: notes)));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          IconButton(
              icon: Icon(Icons.settings), iconSize: 40, onPressed: () {}),
        ],
      ),
      body: StreamBuilder(
          stream: Firestore.instance.collection('melodies').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return Center(child: CircularProgressIndicator());
            return ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  return _buildMelodyItem(
                      context, snapshot.data.documents[index]);
                });
          }),
    );
  }
}
