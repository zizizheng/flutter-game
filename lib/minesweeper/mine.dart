import 'package:flutter/material.dart';

import 'index.dart';

const double ContentSize = 30.0;

// mine 內的所有狀況
enum MINE_STATUS {
  // 空的
  EMPTY,
  // 炸彈
  BOMB,
  // 代表周圍有一到八顆炸彈
  ONE,
  TWO,
  THREE,
  FOUR,
  FIVE,
  SIX,
  SEVEN,
  EIGHT,
}

// 地圖會顯示的東西
Map<MINE_STATUS, Widget> mineStatus = {
  MINE_STATUS.EMPTY: Text(''),
  MINE_STATUS.BOMB: Icon(Icons.whatshot, color: Colors.white),
  MINE_STATUS.ONE: _numFactory('1', Colors.blue[600]),
  MINE_STATUS.TWO: _numFactory('2', Colors.green[600]),
  MINE_STATUS.THREE: _numFactory('3', Colors.red[600]),
  MINE_STATUS.FOUR: _numFactory('4', Colors.purple[600]),
  MINE_STATUS.FIVE: _numFactory('5', Colors.pink[600]),
  MINE_STATUS.SIX: _numFactory('6', Colors.teal[600]),
  MINE_STATUS.SEVEN: _numFactory('7', Colors.black),
  MINE_STATUS.EIGHT: _numFactory('8', Colors.brown[800]),
};

Widget _numFactory(String value, Color color) {
  return Text(
    value,
    style: TextStyle(
      color: color,
      fontWeight: FontWeight.w700,
      fontSize: ContentSize,
    ),
  );
}

// 一個礦框
class Mine extends StatelessWidget {
  final MineContent content;
  final void Function(int i, int j) onOpenMine;
  final void Function(int i, int j) onFlag;
  final int i;
  final int j;
  const Mine({
    Key key,
    @required this.content,
    @required this.onOpenMine,
    @required this.onFlag,
    @required this.i,
    @required this.j,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color _color;
    bool _deepBG = (i + j) % 2 != 0;
    if(content.isClicked) {
      if(content.display == MINE_STATUS.BOMB) _color = Colors.red;
      else _color = _deepBG == true ? Colors.brown[200] : Colors.brown[100];
    }
    else _color = _deepBG == true ? Colors.green[500] : Colors.green[100];
    return GestureDetector(
      onTap: () {
        onOpenMine(i, j);
      },
      onDoubleTap: () {
        onFlag(i, j);
      },
      child: Container(
        decoration: new BoxDecoration(color: _color),
        child: content.isClicked
          ? FittedBox(child: mineStatus[content.display])
          : content.isFlag
            ? FittedBox(child: Icon(Icons.flag, color: Colors.red))
            : null,
      ),
    );
  }
}
