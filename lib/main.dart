/* Задачи
2 - ru ukr * other + base - eng
опред яз системы - ru / ukr
gl - msgs
+ автоперевод на язык...
tts

Настр:
choose lang to learn
основа паттерн / без
цифры / буквы / микс / слоги

 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'letters_trainer.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.deepOrange),
        home: MainPage(),
      );
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  _changeSettings() async {
    //TODO
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: _changeSettings,
            icon: Icon(Icons.settings),
          ),
          title: Text('Учимся писать'),
        ),
        body: SafeArea(
          minimum: const EdgeInsets.all(8),
          child: Column(
            children: [
              Expanded(child: LettersTrainer())
            ],
          ),
        ),
        bottomNavigationBar: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_forward_ios_outlined),
              onPressed: (){},
            )
          ],
        ),
      );
}