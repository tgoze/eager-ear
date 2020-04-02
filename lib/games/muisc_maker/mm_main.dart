import 'package:eager_ear/shared/widgets/staff_painter.dart';
import 'package:flutter/material.dart';

class MusicMakerMain extends StatelessWidget {
  Widget _fadeInImage(BuildContext context, Widget child, int frame,
      bool wasSynchronouslyLoaded) {
    if (wasSynchronouslyLoaded) {
      return child;
    }
    return AnimatedOpacity(
      child: child,
      opacity: frame == null ? 0 : 1,
      duration: const Duration(seconds: 1),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: <Widget>[
            Expanded(
                flex: 8,
                child: Padding(
                    padding: EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                    child: CustomPaint(
                      painter: new StaffPainter(),
                      child: Container(
                        constraints:
                            BoxConstraints.tight(MediaQuery.of(context).size),
                        child: Container(),
                      ),
                    ))),
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Image.asset('assets/images/bunny.png',
                        frameBuilder: _fadeInImage),
                  ),
                  Expanded(
                    flex: 1,
                    child: Image.asset('assets/images/bunny_sharp.png',
                        frameBuilder: _fadeInImage),
                  ),
                  Expanded(
                    flex: 1,
                    child: Image.asset('assets/images/turtle.png',
                        frameBuilder: _fadeInImage),
                  ),
                  Expanded(
                    flex: 1,
                    child: Image.asset('assets/images/turtle_sharp.png',
                        frameBuilder: _fadeInImage),
                  ),
                ],
              ),
            )
          ],
      )),
    );
  }
}
