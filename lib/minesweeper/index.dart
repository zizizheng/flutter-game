import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tictoctoe/minesweeper/mine.dart';
import 'package:tictoctoe/minesweeper/scoreboard.dart';
import 'infoBar.dart';

// 遊戲難度
enum GAME_LEVEL { EASY, NORMAL, HARD }
enum GAME_STATUS { READY, START, STOP }

// 遊戲難度炸彈與邊長設定
class LevelSetting {
  String label;
  num bombs;
  num edge;
  LevelSetting(this.label, this.bombs, this.edge);
}

// 一個 mine 的狀態
class MineContent {
  // 顯示的東西
  MINE_STATUS display;
  // 是否已經被點擊
  bool isClicked;
  // 是否被做上旗幟記號
  bool isFlag;
  MineContent({this.isClicked = false, this.isFlag = false});
}

// 遊戲模式
Map<GAME_LEVEL, LevelSetting> gameMode = {
  GAME_LEVEL.EASY: LevelSetting('簡單', 10, 8),
  GAME_LEVEL.NORMAL: LevelSetting('一般', 40, 16),
  GAME_LEVEL.HARD: LevelSetting('困難', 80, 20),
};

class MinesWeeperLayout extends StatefulWidget {
  @override
  _MinesWeeperLayoutState createState() => _MinesWeeperLayoutState();
}

class _MinesWeeperLayoutState extends State<MinesWeeperLayout> {
  GAME_LEVEL gameLevel;
  @override
  void initState() {
    gameLevel = GAME_LEVEL.EASY;
    super.initState();
  }

  void onChangeLevel(GAME_LEVEL newLevel) {
    setState(() {
      gameLevel = newLevel;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('踩地雷'),
        ),
        body: _MineWeeperContent(gameLevel: gameLevel),
        drawer: Drawer(
          child: Column(children: [
            Container(
              child:
                  ListTile(title: Text('難度設置', style: TextStyle(fontSize: 18))),
              decoration:
                  BoxDecoration(border: Border(bottom: BorderSide(width: 1.5))),
            ),
            Container(
              child: ListView(
                shrinkWrap: true,
                children: gameMode.keys
                    .map(
                      (key) => ListTile(
                            selected: key == gameLevel,
                            onTap: () => onChangeLevel(key),
                            title: ListTileTheme(
                              textColor: key == gameLevel ? Colors.white : null,
                              child: Text(
                                gameMode[key].label,
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                    )
                    .toList(),
              ),
            ),
          ]),
        ));
  }
}

class _MineWeeperContent extends StatefulWidget {
  final GAME_LEVEL gameLevel;
  _MineWeeperContent({@required this.gameLevel});
  @override
  _MineWeeperContentState createState() => _MineWeeperContentState();
}

class _MineWeeperContentState extends State<_MineWeeperContent> {
  List<List<MineContent>> mineMap;
  List<List<bool>> exploreMap;
  int markedFlag;
  bool result;
  int edgeLength;
  int totalBombs;
  GAME_STATUS gameStatus;

  @override
  void initState() {
    _restartGame();
    super.initState();
  }

  @override
  void didUpdateWidget(_MineWeeperContent oldWidget) {
    if (widget.gameLevel != oldWidget.gameLevel) {
      setState(() => _restartGame());
    }

    // 判斷是否勝利
    if (markedFlag == totalBombs &&
        mineMap.every(
          (row) => row.every((mine) =>
              mine.display != MINE_STATUS.BOMB ||
              (mine.display == MINE_STATUS.BOMB && mine.isFlag)),
        )) {
      setState(() => result = true);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    List<Mine> mines = [];
    for (var i = 0; i < edgeLength; i++) {
      for (var j = 0; j < edgeLength; j++) {
        mines.add(Mine(
          i: i,
          j: j,
          content: mineMap[i][j],
          onOpenMine: _onOpenMine,
          onFlag: _onFlagMine,
        ));
      }
    }
    return Stack(
      children: <Widget>[
        Column(children: <Widget>[
          InfoBar(
            markedFlag: markedFlag,
            gameStatus: gameStatus,
            totalBombs: totalBombs,
          ),
          Container(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  GridView.count(
                    crossAxisCount: edgeLength,
                    children: mines,
                    shrinkWrap: true,
                  ),
                ],
              ),
            ),
          ),
          Center(
            child: RaisedButton(
              child: Text(
                '重新開始',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
              color: Colors.lightBlue,
              onPressed: () => setState(() => _restartGame()),
            ),
          ),
        ]),

        ScoreBoard(
          result: result,
          markedFlag: markedFlag,
          totalBombs: totalBombs,
          spendTime: InfoBar.getSeconds(),
        ),
      ],
    );
  }

  // 重開遊戲
  void _restartGame() {
    final mode = gameMode[widget.gameLevel];
    edgeLength = mode.edge;
    totalBombs = mode.bombs;
    result = null;
    markedFlag = 0;
    gameStatus = GAME_STATUS.READY;
    _refreshMap();
  }

  // 刷新地圖
  void _refreshMap() {
    // 建出空地圖
    mineMap = List.generate(
      edgeLength,
      (row) => List.generate(edgeLength, (column) => MineContent()),
    );
    final random = Random();
    int bombCount = 0;
    // 隨機安插炸彈
    while (bombCount < totalBombs) {
      int i = random.nextInt(edgeLength);
      int j = random.nextInt(edgeLength);
      if (mineMap[i][j].display != MINE_STATUS.BOMB) {
        mineMap[i][j].display = MINE_STATUS.BOMB;
        bombCount += 1;
      }
    }
    // 跑過一次算出數字
    mineMap.asMap().forEach((i, row) {
      row.asMap().forEach((j, content) {
        if (content.display != MINE_STATUS.BOMB) {
          int bombs = _countBombs(mineMap, i, j, edgeLength);
          content.display = _findMineStatus(bombs);
        }
      });
    });
  }

  // 單一個 mine 點擊
  void _onOpenMine(int i, int j) {
    MineContent _curMine = mineMap[i][j];
    if (_curMine.isClicked || _curMine.isFlag) return;
    setState(() {
      if (gameStatus != GAME_STATUS.START) gameStatus = GAME_STATUS.START;
      // 踩到炸彈
      if (_curMine.display == MINE_STATUS.BOMB) {
        _curMine.isClicked = true;
        result = false;
        mineMap.asMap().forEach((i, row) {
          row.asMap().forEach((j, mine) {
            if (mineMap[i][j].display == MINE_STATUS.BOMB)
              mineMap[i][j].isClicked = true;
          });
        });
        return;
      }
      exploreMap = List.generate(
        edgeLength,
        (row) => List.generate(edgeLength, (t) => false),
      );
      _exploreMine(i, j);
    });
  }

  // 標記旗幟
  void _onFlagMine(int i, int j) {
    if (markedFlag == totalBombs) return;
    setState(() {
      mineMap[i][j].isFlag = !mineMap[i][j].isFlag;
      mineMap[i][j].isFlag ? markedFlag += 1 : markedFlag -= 1;
    });
  }

  // 如果目前 mine 是空的，則試著拓展周圍的 mine
  void _exploreMine(int i, int j) {
    if (!isValidMine(i, j, edgeLength) ||
        exploreMap[i][j] ||
        mineMap[i][j].isFlag) return;
    mineMap[i][j].isClicked = true;
    exploreMap[i][j] = true;
    if (mineMap[i][j].display != MINE_STATUS.EMPTY) return;
    _exploreMine(i - 1, j);
    _exploreMine(i - 1, j - 1);
    _exploreMine(i - 1, j + 1);
    _exploreMine(i, j - 1);
    _exploreMine(i, j + 1);
    _exploreMine(i + 1, j - 1);
    _exploreMine(i + 1, j);
    _exploreMine(i + 1, j + 1);
  }

  // 找出炸彈數對應的 status
  MINE_STATUS _findMineStatus(int bombs) {
    switch (bombs) {
      case 0:
        return MINE_STATUS.EMPTY;
      case 1:
        return MINE_STATUS.ONE;
      case 2:
        return MINE_STATUS.TWO;
      case 3:
        return MINE_STATUS.THREE;
      case 4:
        return MINE_STATUS.FOUR;
      case 5:
        return MINE_STATUS.FIVE;
      case 6:
        return MINE_STATUS.SIX;
      case 7:
        return MINE_STATUS.SEVEN;
      case 8:
        return MINE_STATUS.EIGHT;
      default:
        return MINE_STATUS.EMPTY;
    }
  }

  // 計算目前這格應該顯示多少數字
  int _countBombs(
    List<List<MineContent>> map,
    int rowIndex,
    int columnIndex,
    int edgeLength,
  ) {
    int _count = 0;
    void _checkBomb(int i, int j) {
      if (isValidMine(i, j, edgeLength) &&
          map[i][j].display == MINE_STATUS.BOMB) {
        _count++;
      }
    }

    // 左上
    _checkBomb(rowIndex - 1, columnIndex - 1);
    // 上
    _checkBomb(rowIndex - 1, columnIndex);
    // 右上
    _checkBomb(rowIndex - 1, columnIndex + 1);
    // 左
    _checkBomb(rowIndex, columnIndex - 1);
    // 右
    _checkBomb(rowIndex, columnIndex + 1);
    // 左下
    _checkBomb(rowIndex + 1, columnIndex - 1);
    // 下
    _checkBomb(rowIndex + 1, columnIndex);
    // 右下
    _checkBomb(rowIndex + 1, columnIndex + 1);

    return _count;
  }
}

// 依照 index 與邊長判斷目前的格數是否合法
bool isValidMine(int i, int j, int edgeLength) =>
    (i >= 0 && i < edgeLength && j >= 0 && j < edgeLength);
