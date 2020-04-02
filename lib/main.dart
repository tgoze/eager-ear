import 'package:eager_ear/games/muisc_maker/mm_home.dart';
import 'package:eager_ear/games/pitch_match/pm_home.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eager Ear',
      theme: ThemeData(
        primaryColor: Colors.amber,
        accentColor: Colors.lightBlue,
        buttonColor: Colors.amber[600],
        focusColor: Colors.amber[700],
        iconTheme: IconThemeData(
          color: Colors.white
        )
      ),
      home: MyHomePage(title: 'Eager Ear Home'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              child: Text("Pitch Match Game"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PitchMatchHome())
                );
              },
            ),
            RaisedButton(
              child: Text("Music Maker"),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MusicMakerHome())
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
