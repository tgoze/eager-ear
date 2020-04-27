import 'package:eager_ear/games/muisc_maker/mm_home.dart';
import 'package:eager_ear/games/pitch_match/pm_home.dart';
import 'package:eager_ear/shared/constants.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eager Ear',
      theme: ThemeData(
          primaryColor: Color(0xFFFF5E00),
          accentColor: Color(0xFFFF6E19),
          buttonColor: Color(0xFF00B3B2),
          focusColor: Color(0xFF00FFFE),
          iconTheme: IconThemeData(color: Colors.white),
          fontFamily: 'ChalkboardSE'),
      initialRoute: 'home/',
      routes: {
        'home/': (context) => EagerEarHome(title: 'Eager Ear'),
        'home/pitchMatchHome': (context) => PitchMatchHome(),
      },
    );
  }
}

class EagerEarHome extends StatefulWidget {
  EagerEarHome({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _EagerEarHomeState createState() => _EagerEarHomeState();
}

class _EagerEarHomeState extends State<EagerEarHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Card(
              color: Theme.of(context).buttonColor.withOpacity(.5),
              child: InkWell(
                splashColor: Theme.of(context).buttonColor,
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PitchMatchHome()));
                },
                child: Container(
                  width: 300,
                  height: MediaQuery.of(context).size.height / 3,
                  child: Center(
                    child: ListTile(
                        leading: Image.asset(noteImagePaths[0]),
                        title: DefaultTextStyle(
                          style: Theme.of(context).textTheme.title,
                          child: Text('Pitch Match'),
                        )),
                  ),
                ),
              ),
              elevation: 20,
              shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(50)),
              ),
            ),
            Card(
              color: Theme.of(context).buttonColor.withOpacity(.5),
              child: InkWell(
                splashColor: Theme.of(context).buttonColor,
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MusicMakerHome()));
                },
                child: Container(
                  width: 300,
                  height: MediaQuery.of(context).size.height / 3,
                  child: Center(
                    child: ListTile(
                        leading: Image.asset(noteImagePaths[2]),
                        title: DefaultTextStyle(
                          style: Theme.of(context).textTheme.title,
                          child: Text('Music Maker'),
                        )),
                  ),
                ),
              ),
              elevation: 20,
              shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(50)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
