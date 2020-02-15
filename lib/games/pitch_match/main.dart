import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PitchMatchMain extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Pitch Match"),
        ),
        body: PitchMatchStaff()
    );
  }
}

class PitchMatchStaff extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _PitchMatchStaffState();
}

class _PitchMatchStaffState extends State<PitchMatchStaff> {
  ui.Image image;
  bool isImageLoaded = false;

  void initState() {
    super.initState();
    init();
  }

  Future <Null> init() async {
    final ByteData data = await rootBundle.load('assets/images/rabbit.png');
    image = await loadImage(new Uint8List.view(data.buffer));
  }

  Future<ui.Image> loadImage(List<int> img) async {
    final Completer<ui.Image> completer = new Completer();
    ui.decodeImageFromList(img, (ui.Image img) {
      setState(() {
        isImageLoaded = true;
      });
      return completer.complete(img);
    });
    return completer.future;
  }

  Widget _buildImage() {
    if (this.isImageLoaded) {
      return new CustomPaint(
        painter: new StaffPainter(noteImage: image),
          child: Container(height: 200)
      );
    } else {
      return new Center(child: new Text('loading'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding (
              padding: EdgeInsets.all(8.0),
              child: _buildImage()
          )
        ],
      )
    );
  }
}

class StaffPainter extends CustomPainter {

  StaffPainter({
    this.noteImage
  });

  ui.Image noteImage;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();

    paint.color = Colors.teal;
    paint.strokeWidth = 5;

    int lines = 5;
    double spacing = size.height / lines;

    for(int i = 0; i < lines; i++) {
      canvas.drawLine(
        Offset(0, spacing * i),
        Offset(size.width, spacing * i),
        paint,
      );
    }

    canvas.drawImage(noteImage, new Offset(0.0, 0.0), new Paint());
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}