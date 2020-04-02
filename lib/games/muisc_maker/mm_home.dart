import 'package:eager_ear/games/muisc_maker/mm_main.dart';
import 'package:flutter/material.dart';

class MusicMakerHome extends StatelessWidget {
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
        ],),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              child: Text("Make new melody"),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MusicMakerMain())
                );
              },
            )
          ],
        ),
      ),
    );
  }
}