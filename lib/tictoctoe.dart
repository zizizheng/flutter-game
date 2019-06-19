import 'package:flutter/material.dart';

const _row = 3;
const _column = 3;
// 填入的內容
enum CHECKED_TYPE {
  cross,
  nought,
  blank,
}

class TicTocToeApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('井字遊戲'),
      ),
      body: _TicTocToe(),
    );
  }
}

class _TicTocToe extends StatefulWidget {
  _TicTocToe({Key key}) : super(key: key);

  _TicTocToeState createState() => _TicTocToeState();
}

class _TicTocToeState extends State<_TicTocToe> {
  List<List<CHECKED_TYPE>> playMap;
  CHECKED_TYPE curPlayer;

  @override
  void initState() {
    playMap = List.generate(_row, (i) =>
      List.generate( _column, (j) => CHECKED_TYPE.blank),
    );
    curPlayer = CHECKED_TYPE.nought;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Field> fields = [];
    for (var i = 0; i < _row; i++) {
      for (var j = 0; j < _column; j++) {
        fields.add(Field(i: i, j: j, display: playMap[i][j], check: _check));
      }
    }

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Column(
          children: <Widget>[
            Container(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.count(
                  crossAxisCount: _column,
                  children: fields,
                  shrinkWrap: true,
                ),
              ),
            ),
            RaisedButton(
              onPressed: () {
                _restart();
              },
              child: Text("重新開始"),
            ),
            Container(
              child: WinCover(
                result: _findWinner(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _check(num i, num j) {
    if (playMap[i][j] != CHECKED_TYPE.blank || _findWinner() != CHECKED_TYPE.blank)
      return;
    this.setState(() {
      playMap[i][j] = curPlayer;
      curPlayer = curPlayer == CHECKED_TYPE.cross
          ? CHECKED_TYPE.nought
          : CHECKED_TYPE.cross;
    });
  }

  void _restart() {
    this.setState(() {
      curPlayer = CHECKED_TYPE.nought;
      playMap = List.generate(_row, (i) {
        return List.generate(
          _column,
          (j) {
            return CHECKED_TYPE.blank;
          },
        );
      });
    });
  }

  CHECKED_TYPE _findWinner() {
    // 橫線檢查
    for (var i = 0; i < _row; i++) {
      if (playMap[i][0] == playMap[i][1] &&
          playMap[i][1] == playMap[i][2] &&
          playMap[i][0] != CHECKED_TYPE.blank) {
        return playMap[i][0];
      }
    }
    // 直線檢查
    for (var i = 0; i < _column; i++) {
      if (playMap[0][i] == playMap[1][i] &&
          playMap[1][i] == playMap[2][i] &&
          playMap[0][i] != CHECKED_TYPE.blank) {
        return playMap[0][i];
      }
    }
    // 正向對角線檢查
    if (playMap[0][0] == playMap[1][1] &&
        playMap[1][1] == playMap[2][2] &&
        playMap[0][0] != CHECKED_TYPE.blank) {
      return playMap[0][0];
    }
    // 反向對角線檢查
    if (playMap[0][2] == playMap[1][1] &&
        playMap[1][1] == playMap[2][0] &&
        playMap[0][2] != CHECKED_TYPE.blank) {
      return playMap[0][2];
    }
    return CHECKED_TYPE.blank;
  }
}

class Field extends StatelessWidget {
  final num i;
  final num j;
  final CHECKED_TYPE display;
  final Function check;
  const Field({Key key, this.i, this.j, this.display, this.check})
      : super(key: key);

  Widget _buildChild(CHECKED_TYPE display) {
    if (display == CHECKED_TYPE.cross) return Cross();
    if (display == CHECKED_TYPE.nought) return Nought();
    return null;
  }

  @override
  Widget build(BuildContext context) {
    Color color = Colors.grey[400];
    return GestureDetector(
      onTap: () {
        check(i, j);
      },
      child: Container(
        decoration: new BoxDecoration(
          border: Border(
              left: BorderSide(color: color, width: j % 3 == 0 ? 0 : 3.0),
              top: BorderSide(color: color, width: i == 0 ? 0 : 3.0)),
        ),
        child: Center(child: _buildChild(display)),
      ),
    );
  }
}

// 叉
class Cross extends StatelessWidget {
  final double adjustSize;
  Cross({Key key, this.adjustSize}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double size = adjustSize is double ? adjustSize : 100;
    return Container(
      child: Icon(
        Icons.clear,
        color: Colors.red,
        size: size,
      ),
    );
  }
}

// 圈
class Nought extends StatelessWidget {
  final double adjustSize;
  const Nought({Key key, this.adjustSize}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double size = adjustSize is double ? adjustSize : 100;
    return Container(
      child: Icon(
        Icons.panorama_fish_eye,
        color: Colors.green,
        size: size,
      ),
    );
  }
}

class WinCover extends StatelessWidget {
  final CHECKED_TYPE result;
  const WinCover({
    Key key,
    @required this.result,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: result == CHECKED_TYPE.blank ? 0.0 : 1.0,
      duration: Duration(milliseconds: 500),
      child: result == CHECKED_TYPE.blank
          ? Container(width: 0, height: 0)
          : Container(
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: result == CHECKED_TYPE.nought
                          ? Nought(adjustSize: 150)
                          : Cross(adjustSize: 150),
                    ),
                  ),
                  Text(
                    '獲勝',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 50.0),
                  ),
                ],
              ),
            ),
    );
  }
}
