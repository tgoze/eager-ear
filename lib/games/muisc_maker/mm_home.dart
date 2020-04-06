import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eager_ear/games/muisc_maker/mm_main.dart';
import 'package:eager_ear/shared/note.dart';
import 'package:flutter/material.dart';

class MusicMakerHome extends StatelessWidget {
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
                builder: (context) => MusicMakerMain(
                    notes: notes, documentId: document.documentID)));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text("Music Maker"),
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
      body: Center(
        child: StreamBuilder(
            stream: Firestore.instance.collection('melodies').snapshots(),
            builder: (streamContext, snapshot) {
              if (!snapshot.hasData)
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[CircularProgressIndicator()],
                );
              return ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (listContext, index) {
                    var document =
                        (snapshot.data.documents[index] as DocumentSnapshot);
                    return Dismissible(
                        key: Key(document.documentID),
                        background: Container(
                          color: Colors.red,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('DELETE',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                              )
                            ],
                          ),
                        ),
                        onDismissed: (dismissDirection) {
                          Firestore.instance
                              .runTransaction((transaction) async {
                            DocumentSnapshot freshSnap =
                                await transaction.get(document.reference);
                            await transaction.delete(freshSnap.reference);
                          });
                        },
                        confirmDismiss: (dismissDirection) {
                          return showDialog<bool>(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Delete Melody'),
                                content: SingleChildScrollView(
                                  child: ListBody(
                                    children: <Widget>[
                                      Text(
                                          'Are you sure you want to delete ${document['title']}?')
                                    ],
                                  ),
                                ),
                                shape: BeveledRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5))),
                                actions: <Widget>[
                                  FlatButton(
                                    child: Text('Cancel'),
                                    onPressed: () {
                                      Navigator.of(context).pop(false);
                                    },
                                  ),
                                  FlatButton(
                                    child: Text('Delete'),
                                    textColor: Colors.red,
                                    onPressed: () {
                                      Navigator.of(context).pop(true);
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: _buildMelodyItem(
                            context, snapshot.data.documents[index]));
                  });
            }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      MusicMakerMain(notes: [], documentId: '')));
        },
        backgroundColor: Theme.of(context).buttonColor,
        child: Icon(Icons.add),
      ),
    );
  }
}
