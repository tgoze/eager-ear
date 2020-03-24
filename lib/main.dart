import 'package:flutter/material.dart';

import 'package:eager_ear/games/pitch_match/main.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eager Ear',
      theme: ThemeData(
        primarySwatch: Colors.blue,
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
                  MaterialPageRoute(builder: (context) => PitchMatchMain())
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
