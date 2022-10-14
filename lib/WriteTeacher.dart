import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'globals.dart';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart';
//import 'package:tesseract_ocr/tesseract_ocr.dart';

class WriteTeacher extends StatefulWidget {
  final int mode;

  WriteTeacher(this.mode);

  @override
  _WriteTeacherState createState() => _WriteTeacherState();
}

class _WriteTeacherState extends State<WriteTeacher> {
  Image resImg;

  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
        appBar: AppBar(
          title: Text('Learn ${widget.mode == 1? 'LETTERS':'NUMBERS'}'),
        ),
        body: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('write A', textScaleFactor: 3,),
                resImg == null? SizedBox(): Container(width:60, height: 60, child: resImg),
              ],
            ),
            Expanded(
                child: MyPaintWidget()//Container(color: Colors.lightGreenAccent[100],)
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    color: Colors.lightBlueAccent[100],
                    child: FlatButton(
                      child: Text('OK', textAlign: TextAlign.center, textScaleFactor: 2,),
                      onPressed: _check,
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      );
  }

  _check() async {
    print('check');

    final recorder = new ui.PictureRecorder();
    final canvas = new Canvas(
        recorder,
        new Rect.fromPoints(
            new Offset(0.0, 0.0), new Offset(glCanvasSize.width, glCanvasSize.height)));

    Paint p = Paint();
    p.color = Colors.black;
    p.strokeWidth = 5;

    glLines.forEach((line){
      if (line.length < 2) {
        return;
      }
      for (int i=0; i<line.length-1; i++) {
        Offset startPoint = line[i];
        Offset endPoint = line[i+1];
        canvas.drawLine(startPoint, endPoint, p);
      }
    });

    final picture = recorder.endRecording();
    final img = await picture.toImage(glCanvasSize.width.toInt(), glCanvasSize.height.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);    //return Image.fromBytes(canvas.width, canvas.height, imageData.data);
    Uint8List pngBytes = byteData.buffer.asUint8List();
    print('got pngBytes: ${pngBytes.length}');
    //resImg = Image.memory(pngBytes);
    //setState(() {});


    //String text = await TesseractOcr.extractText(fileName, language: 'rus');
    //String text = await ocrSymbolFromFile(savedFile);
    //print('got ocr text $text');

    //ocrSymbol(pngBytes, glCanvasSize.width, glCanvasSize.height);
  }

}

class MyPaintWidget extends StatefulWidget {
  @override
  _MyPaintWidgetState createState() => _MyPaintWidgetState();
}

class _MyPaintWidgetState extends State<MyPaintWidget> {
  List<List <Offset>> lines = [];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: CustomPaint(
        child: Container(color: Colors.blueGrey),
        foregroundPainter: ImagePainter(lines),
      ),
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
    );
  }

  void _onPanStart(DragStartDetails details) {
    print('_onPanStart $details');
    List <Offset> newLine = [];
    RenderBox _rb = (context.findRenderObject() as RenderBox);
    Offset pos = _rb.globalToLocal(details.globalPosition);
    glCanvasSize = _rb.size;
    print('got relative pos $pos');
    newLine.add(pos);
    lines.add(newLine);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    //print('_onPanUpdate $details');
    Offset pos = (context.findRenderObject() as RenderBox)
        .globalToLocal(details.globalPosition);
    lines.last.add(pos);
    setState((){});
  }

  void _onPanEnd(DragEndDetails details) {
    //print('_onPanEnd $details');
    //print('got line data to draw ${lines.last}');
    setState((){});
  }

}


class ImagePainter extends CustomPainter {
  List<List <Offset>> lines;

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
    p.color = Colors.green;
    p.strokeWidth = 5;

    lines.forEach((line){
      if (line.length < 2) {
        return;
      }
      for (int i=0; i<line.length-1; i++) {
        Offset startPoint = line[i];
        Offset endPoint = line[i+1];
        canvas.drawLine(startPoint, endPoint, p);
      }
    });

    glLines = lines;
  }

  @override
  bool shouldRepaint(ImagePainter old) {
    return true;
  }

}

