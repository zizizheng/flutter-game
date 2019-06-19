import 'package:flutter/material.dart';
import 'package:tictoctoe/tictoctoe.dart';

import 'minesweeper/index.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '遊戲',
      initialRoute: '/',
      routes: {
        '/': (context) => Home(),
        '/tictoctoe': (context) => TicTocToeApp(),
        '/minesweeper': (context) => MinesWeeperLayout(),
      },
    );
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('首頁'),
      ),
      body: Center(
        child: ButtonTheme(
          minWidth: 200,
          buttonColor: Colors.grey[300],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                onPressed: () => Navigator.pushNamed(context, '/tictoctoe'),
                child: Text('井字遊戲'),
              ),
              SizedBox(height: 100),
              RaisedButton(
                onPressed: () => Navigator.pushNamed(context, '/minesweeper'),
                child: Text('踩地雷'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
