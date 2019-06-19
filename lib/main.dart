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
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('井字遊戲', style: TextStyle(fontSize: 20)),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [BoxShadow(color: Colors.blue, blurRadius: 2)],
                      ),
                      child: GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/tictoctoe'),
                        child: Container(child: Image.asset('assets/images/tictoctoe.png')),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('踩地雷', style: TextStyle(fontSize: 20)),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [BoxShadow(color: Colors.blue, blurRadius: 2)],
                      ),
                      child: GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/minesweeper'),
                        child: Container(child: Image.asset('assets/images/mineweeper.png')),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
