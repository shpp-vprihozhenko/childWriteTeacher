import 'package:flutter/material.dart';

import 'globals.dart';

class MyPaintWidget extends StatefulWidget {
  MyPaintWidget({Key key}) : super(key: key);

  @override
  MyPaintWidgetState createState() => MyPaintWidgetState();
}

class MyPaintWidgetState extends State<MyPaintWidget> {
  List<List<Offset>> lines = [];

  getLinesList() {
    return lines;
  }

  clearCanvas() {
    lines.forEach((element) {
      element.clear();
    });
    lines = [];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: CustomPaint(
        child: Container(color: Colors.white),
        foregroundPainter: ImagePainter(lines),
      ),
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
    );
  }

  void _onPanStart(DragStartDetails details) {
    print('_onPanStart $details');
    List<Offset> newLine = [];
    RenderBox _rb = (context.findRenderObject() as RenderBox);
    Offset pos = _rb.globalToLocal(details.globalPosition);
    glCanvasSize = _rb.size;
    print('got relative pos $pos');
    newLine.add(pos);
    lines.add(newLine);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    Offset pos = (context.findRenderObject() as RenderBox)
        .globalToLocal(details.globalPosition);
    lines.last.add(pos);
    setState(() {});
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {});
  }
}

class ImagePainter extends CustomPainter {
  List<List<Offset>> lines;

  ImagePainter(this.lines);

  @override
  void paint(Canvas canvas, Size canvasSize) {
    /*
    Size imageSize = new Size(image.width.toDouble(), image.height.toDouble());
    Size targetSize = imageSize * scale;

    paintImage(
      canvas: canvas,
      rect: offset & targetSize,
      image: image,
      fit: BoxFit.fill,
    );
    */

    Paint p = Paint();
    p.color = Colors.black;
    p.strokeWidth = 5;

    lines.forEach((line) {
      if (line.length < 2) {
        return;
      }
      for (int i = 0; i < line.length - 1; i++) {
        Offset startPoint = line[i];
        Offset endPoint = line[i + 1];
        canvas.drawLine(startPoint, endPoint, p);
      }
    });

    glCanvasSize = canvasSize;
    //glLines = lines;
    //glCanvas = canvas;
  }

  @override
  bool shouldRepaint(ImagePainter old) {
    return true;
  }
}
