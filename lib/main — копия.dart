//import 'package:child_draw_letters/widget/text_recognition_widget.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:child_draw_letters/globals.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final String title = 'Text Recognition';

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: title,
        theme: ThemeData(primarySwatch: Colors.deepOrange),
        home: MainPage(title: title),
      );
}

class MainPage extends StatefulWidget {
  final String title;

  const MainPage({
    @required this.title,
  });

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  GlobalKey<MyPaintWidgetState> signatureKey = GlobalKey();
  String fnResultFile;
  bool showRes = false;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              //const SizedBox(height: 2),
              //Image(image: AssetImage('assets/img/base_rus.png')),
              Expanded(
                  child: showRes?
                  Image.file(File(fnResultFile))
                  :MyPaintWidget(key: signatureKey)),
              Row(
                children: [
                  TextButton(
                      onPressed: saveToFile,
                      child: Container(
                          color: Colors.yellow,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'save',
                              textScaleFactor: 2.5,
                            ),
                          ))),
                  TextButton(
                      onPressed: () {
                        signatureKey.currentState.clearCanvas();
                      },
                      child: Container(
                          color: Colors.yellow,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'clear',
                              textScaleFactor: 2,
                            ),
                          ))),
                  TextButton(
                    child: Text('MODE'),
                    onPressed: (){
                      setState(() {
                        showRes =! showRes;
                      });
                    },
                  )
                ],
              ),
              //InputWidget(),
              //const SizedBox(height: 15),
            ],
          ),
        ),
      );

  saveToFile() async {
    print('start saveToFile');

    List<List<Offset>> lines = signatureKey.currentState.getLinesList();
    print('got lines ${lines.length}');
    print('got canvas size $glCanvasSize');

    final userBytes = await formUserImgBytes(lines, glCanvasSize);
    print('got user bytes ${userBytes.length}');

    img.Image userImage = img.decodePng(userBytes);
    img.Image thumbnail = img.copyResize(userImage, width: 100);

    ByteData templateData = await rootBundle.load("assets/base_rus.png");
    List<int> templateBytes = templateData.buffer
        .asUint8List(templateData.offsetInBytes, templateData.lengthInBytes);
    img.Image templateImage = img.decodePng(templateBytes);
    print('got template bytes ${templateBytes.length}');

    img.copyInto(templateImage, thumbnail,
        dstX: 0,
        dstY: 100,
        srcX: 0,
        srcY: 0); //, int srcW, int srcH, bool blend = true

    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;

    String fn = appDocPath + '/result.png';
    print('try file to save $fn');
    fnResultFile = fn;

    File resFile = File(fn);
    await resFile.writeAsBytes(img.encodePng(templateImage));
    print('saved to $fn');
    String s = await ocrSymbolFromFile(resFile);
    print('got s $s');
  }

  Future <String> ocrSymbolFromFile(File savedFile) async {
    final visionImage = FirebaseVisionImage.fromFile(savedFile);
    print('got visionImage $visionImage');
    final textRecognizer = FirebaseVision.instance.textRecognizer();
    print('got textRecognizer $textRecognizer');
    try {
      final visionText = await textRecognizer.processImage(visionImage);
      print('st1 ********************************************* $visionText');
      await textRecognizer.close();
      print('st2 *********************************************');
      final text = extractText(visionText);
      //print('st3 ********************************************* $text');
      return text.isEmpty ? 'No text found in the image' : text;
    } catch (error) {
      return error.toString();
    }
  }

  extractText(VisionText visionText) {
    String text = '';
    print ('vt ${visionText.blocks}');
    for (TextBlock block in visionText.blocks) {
      for (TextLine line in block.lines) {
        for (TextElement word in line.elements) {
          text = text + word.text + ' ';
        }
        text = text + '\n';
      }
    }
    print('got text $text');
    return text;
  }

  formUserImgBytes(List<List<Offset>> lines, Size size) async {
    final recorder = new ui.PictureRecorder();
    final canvas = new Canvas(
        recorder,
        new Rect.fromPoints(
            new Offset(0.0, 0.0), new Offset(size.width, size.height)));

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

    final picture = recorder.endRecording();
    final img = await picture.toImage(size.width.toInt(), size.height.toInt());
    final byteData = await img.toByteData(
        format: ui.ImageByteFormat
            .png); //return Image.fromBytes(canvas.width, canvas.height, imageData.data);
    Uint8List pngBytes = byteData.buffer.asUint8List();
    print('got pngBytes: ${pngBytes.length}');

    return pngBytes;
  }
}

class InputWidget extends StatefulWidget {
  @override
  _InputWidgetState createState() => _InputWidgetState();
}

class _InputWidgetState extends State<InputWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue[100],
      child: Column(children: [
        Text(
          '123',
          textScaleFactor: 3,
        ),
        FlatButton(
          child: Text(
            'go',
            textScaleFactor: 2,
          ),
          color: Colors.green,
          onPressed: _generatePng,
        )
      ]),
    );
  }

  _generatePng() async {
    img.Image image = img.Image(320, 240);
    img.fill(image, img.getColor(0, 0, 0));
    img.drawString(image, img.arial_24, 0, 0, 'Привет!');
    img.drawLine(image, 0, 24, 320, 240, img.getColor(255, 0, 0), thickness: 3);
    //gaussianBlur(image, 10);
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    String fn = appDocPath + '/test.png';
    print('try write to $fn');
    File(fn).writeAsBytesSync(img.encodePng(image));
    print('ready2');
  }
}
