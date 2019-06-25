import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tictoctoe/tetris/tetrominoType.dart';

// 單位長
const double SquareEdge = 22;
// 區域單位寬高
const int MapHeight = 20;
const int MapWidth = 10;
// 下降時間
const int StepTime = 500;
// 初始方塊出現的 x 位移
const int StartShift = 4;
enum ACTION_TYPE { NEW, STEP, LEFT, RIGHT, DOWN, ROTATE, CLEAN }

class TetrisApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('俄羅斯方塊'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black, Colors.white],
          ),
        ),
        child: Row(children: <Widget>[
          Expanded(
            flex: 1,
            child: Text('1'),
          ),
          Expanded(
            flex: 4,
            child: Area(),
          ),
          Expanded(
            flex: 1,
            child: Text('1'),
          ),
        ]),
      ),
    );
  }
}

class DrawState {
  List<Point> points;
  TetrominoType type;
  Point rotateCenter;
  DrawState(this.points, this.type, this.rotateCenter);
}

class Area extends StatefulWidget {
  @override
  _AreaState createState() => _AreaState();
}

GlobalKey _mapkey = GlobalKey();

class _AreaState extends State<Area> {
  // 已堆疊的方塊
  final List<List<TetrominoType>> stackMap = List.generate(
    MapHeight,
    (_) => List.generate(MapWidth, (_) => null),
  );
  final List<ACTION_TYPE> actionQueue = [];
  final Random random = new Random();
  final DrawState drawState = DrawState([], null, null);
  // repaint by frame(60 fps)
  Timer repaintTimer;
  // add step per 500ms
  Timer stepTimer;
  bool mapLock;
  double tipMoveDistance;
  bool canGoDown;

  @override
  void dispose() {
    repaintTimer.cancel();
    stepTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints.expand(),
      child: Align(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                  border: Border.all(width: 4, color: Colors.white)),
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onPanDown: (_) => canGoDown = true,
                onPanUpdate: (details) => _userMove(details.delta),
                onTap: () {
                  if(drawState.type != null) actionQueue.add(ACTION_TYPE.ROTATE);
                },
                child: SizedBox(
                  key: _mapkey,
                  width: SquareEdge * MapWidth,
                  height: SquareEdge * MapHeight,
                  child: Stack(
                    children: <Widget>[
                      CustomPaint(
                        painter: MapPainter(stackMap, drawState.points, drawState.type),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            RaisedButton(
              onPressed: () => drawState.type == null
                ? _newGame()
                : null,
              child: Text('開始'),
            )
          ],
        ),
      ),
    );
  }

  void _newGame() {
    stackMap.asMap().forEach(
      (i, row) => row.asMap().forEach(
        (j, cell) => stackMap[i][j] = null)
    );
    actionQueue.clear();
    actionQueue.add(ACTION_TYPE.NEW);
    mapLock = false;
    drawState.points = [];
    drawState.rotateCenter = null;
    drawState.type = null;
    if(repaintTimer != null) repaintTimer.cancel();
    repaintTimer = Timer.periodic(
      // 60 fps
      new Duration(milliseconds: 17),
      (Timer t) {
        if (mapLock == true) return;
        if (actionQueue.length != 0) {
          mapLock = true;
          // DO Tetro behaivor
          final curAction = actionQueue.removeAt(0);
          switch (curAction) {
            case ACTION_TYPE.NEW:
              _newTetro();
              break;
            case ACTION_TYPE.STEP:
              _stepDown();
              break;
            case ACTION_TYPE.LEFT:
            case ACTION_TYPE.RIGHT:
            case ACTION_TYPE.DOWN:
              _moveTetro(curAction);
              break;
            case ACTION_TYPE.ROTATE:
              _rotateTetro();
              break;
            case ACTION_TYPE.CLEAN:
              _cleanStack();
              break;
            default:
          }
          mapLock = false;
        }
      },
    );
    if(stepTimer != null) stepTimer.cancel();
    stepTimer = Timer.periodic(new Duration(milliseconds: StepTime),
      (t) {
        if(drawState.type != null) actionQueue.add(ACTION_TYPE.STEP);
      }
    );
    tipMoveDistance = 0;
    setState(() { });
  }

  // 隨機新增一塊方塊
  void _newTetro() {
    // print('新增方塊開始');
    final type = TetrominoType.values
        .elementAt(random.nextInt(tetrominoes.values.length));
    final shapes = tetrominoes[type].shape;
    final shapeIndex = random.nextInt(shapes.length);
    final randomShape = shapes[shapeIndex];
    int yShift = 0;
    // 計算剩下空間是否足夠畫方塊，不足則往上推移，推到超出四格代表已滿
    bool isValid = false;
    while (isValid == false && yShift <= 3) {
      isValid = true;
      for (var i = 0; i < 4; i++) {
        for (var j = 0; j < 4; j++) {
          if (
              randomShape[i][j] != 0 &&
              i - yShift >= 0 &&
              stackMap[i - yShift][j + StartShift] != null
            ) {
              isValid = false;
              break;
          }
        }
      }
      if (isValid == false) yShift++;
    }
    if (yShift > 3) return;
    setState(() {
      drawState.type = type;
      drawState.rotateCenter = null;
      for (var i = 0; i < 4; i++) {
        for (var j = 0; j < 4; j++) {
          if (randomShape[i][j] != 0) {
            int newX = j + StartShift;
            int newY = i - yShift;
            Point newPoint = Point(newX, newY);
            drawState.points.add(newPoint);
            // 紀錄旋轉中心
            if(randomShape[i][j] == 2) drawState.rotateCenter = newPoint;
          }
        }
      }
    });
    // print('新增方塊結束');
  }

  // 方塊下降一格
  void _stepDown() {
    // print('下降開始');
    if (drawState.type == null) return;
    // 確保每一格都可以往下畫
    bool canStepDown = drawState.points.every((point) {
      int newY = point.y + 1;
      if(newY >= MapHeight) return false;
      if (newY < 0) return true;
      return newY < MapHeight && stackMap[newY][point.x] == null;
    });
    setState(() {
      if (canStepDown) {
        // 往下填入新的顏色
        drawState.points.asMap().forEach((i, point) {
          if (point.y + 1 < 0) return;
          drawState.points[i] = Point(point.x, point.y + 1);
        });
        // 更新旋轉座標位置
        if(drawState.rotateCenter != null)
          drawState.rotateCenter = Point(drawState.rotateCenter.x, drawState.rotateCenter.y + 1);
      }
      // 將方塊填到 stackMap
      else {
        drawState.points.forEach((point) {
          if (point.y < 0) return;
          stackMap[point.y][point.x] = drawState.type;
        });
        // 如果有可以清空的列則清空
        if(stackMap.any((row) => row.every((cell) => cell != null))) {
          actionQueue.add(ACTION_TYPE.CLEAN);
        }
        actionQueue.add(ACTION_TYPE.NEW);
        drawState.points = [];
        drawState.type = null;
      }
    });
    // print('下降結束');
  }

  void _userMove(Offset delta) {
    // print('移動開始');
    if (drawState.type == null) return;
    final RenderBox renderBoxRed = _mapkey.currentContext.findRenderObject();
    final boxStart = renderBoxRed.localToGlobal(Offset.zero).dx;
    final boxEnd = boxStart + SquareEdge * MapWidth;
    double tetroStart = double.infinity;
    double tetroEnd = double.negativeInfinity;
    // 找出目前方塊最左側與最右側的座標點
    drawState.points.forEach((point) {
      if (boxStart + point.x * SquareEdge < tetroStart)
        tetroStart = boxStart + point.x * SquareEdge;
      if (boxEnd + point.x * SquareEdge > tetroEnd)
        tetroEnd = boxEnd + point.x * SquareEdge;
    });
    tipMoveDistance += delta.dx;
    int offsetUnit = tipMoveDistance ~/ SquareEdge;
    // 往右
    if(offsetUnit >= 1) {
      tipMoveDistance = tipMoveDistance % SquareEdge;
      actionQueue.addAll(List.generate(offsetUnit, (_) => ACTION_TYPE.RIGHT));
    }
    // 往左
    if(offsetUnit <= -1) {
      tipMoveDistance = tipMoveDistance % SquareEdge;
      actionQueue.addAll(List.generate(offsetUnit.abs(), (_) => ACTION_TYPE.LEFT));
    }
    // 往下
    if(delta.dy > 15 && canGoDown == true) {
      canGoDown = false;
      actionQueue.add(ACTION_TYPE.DOWN);
    }
    // print('移動結束');
  }

  void _moveTetro(ACTION_TYPE action) {
    List<Point> newPoints;
    if(action == ACTION_TYPE.LEFT || action == ACTION_TYPE.RIGHT) {
      int xShift = action == ACTION_TYPE.LEFT ? -1 : 1;
      if(drawState.points.any((point) => point.x + xShift < 0 || point.x + xShift >= MapWidth)) return ;
      newPoints = drawState.points.map((point) => Point(point.x + xShift, point.y)).toList();
      if(drawState.rotateCenter != null) {
        drawState.rotateCenter = Point(drawState.rotateCenter.x + xShift, drawState.rotateCenter.y);
      }
      // 檢查地圖合法性
      if(newPoints.any((point) => stackMap[point.y][point.x]!= null)) return ;
    }
    else if(action == ACTION_TYPE.DOWN) {
      int downShift = 0;
      while(
        drawState.points.every((point) =>
          point.y + downShift + 1 < MapHeight &&
          stackMap[point.y + downShift + 1][point.x] == null)
      ) {
        downShift++;
      }
      newPoints = drawState.points.map((point) => Point(point.x, point.y + downShift)).toList();
      if(drawState.rotateCenter != null)
        drawState.rotateCenter = Point(drawState.rotateCenter.x, drawState.rotateCenter.y + downShift);
    }
    else return;
    setState(() {
      drawState.points = newPoints;
    });
  }

  /// 座標向右旋轉 90 度
  /// 先將所有座標以旋轉中心做座標軸標準化
  /// 再以 (x, y) => (-y, x) 的方式使座標點全部旋轉 90 度
  /// 最後還原(加上)旋轉中心座標
  void _rotateTetro() {
    if(drawState.rotateCenter == null) return ;
    List<Point> newPoints = drawState.points
      // 排除中心點
      .where((point) => point.distanceTo(drawState.rotateCenter) != 0)
      // 轉換座標
      .map((point) => Point(
        -(point.y - drawState.rotateCenter.y) + drawState.rotateCenter.x,
        (point.x - drawState.rotateCenter.x) + drawState.rotateCenter.y,
      )).toList();
    newPoints.add(drawState.rotateCenter);
    // 左側超過則右移
    while(newPoints.any((point) => point.x < 0)) {
      newPoints = newPoints.map((point) => Point(point.x + 1, point.y)).toList();
    }
    // 右側超過則左移
    while(newPoints.any((point) => point.x >= MapWidth)) {
      newPoints = newPoints.map((point) => Point(point.x - 1, point.y)).toList();
    }
    // 上側超過則下移
    while(newPoints.any((point) => point.y < 0)) {
      newPoints = newPoints.map((point) => Point(point.x, point.y + 1)).toList();
    }
    // 下策超過則上移
    while(newPoints.any((point) => point.y >= MapHeight)) {
      newPoints = newPoints.map((point) => Point(point.x, point.y - 1)).toList();
    }
    // 有卡到目前的方塊就不給轉
    if(newPoints.any((point) => stackMap[point.y][point.x] != null)) {
      return ;
    }
    setState(() {
      drawState.points = newPoints;
    });
  }

  void _cleanStack() {
    final List<int> clearableLine = [];
    setState(() {
      stackMap.forEach((row) {
        if(row.every((cell) => cell != null)) clearableLine.add(stackMap.indexOf(row));
      });
      clearableLine.forEach((index) {
        stackMap.removeAt(index);
        stackMap.insert(0, List.generate(MapWidth, (_) => null));
      });
    });
  }
}

class MapPainter extends CustomPainter {
  List<List<TetrominoType>> map;
  List<Point> drawPoint;
  TetrominoType drawType;
  MapPainter(this.map, this.drawPoint, this.drawType);
  @override
  void paint(Canvas canvas, Size size) {
    map.asMap().forEach((y, row) {
      row.asMap().forEach((x, cell) {
        if (cell != null) {
          _drawPoint(canvas, Point(x, y), tetrominoes[cell].color);
        }
      });
      drawPoint.forEach((point) {
        if(point.x >= 0 && point.x < MapWidth && point.y >= 0 && point.y < MapHeight) {
          _drawPoint(canvas, point, tetrominoes[drawType].color);
        }
      });
    });
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  void _drawPoint(Canvas canvas, Point point, Color color) {
    canvas.drawRect(
      Rect.fromPoints(
        Offset(point.x * SquareEdge + 1, point.y * SquareEdge + 1),
        Offset((point.x + 1) * SquareEdge - 1, (point.y + 1) * SquareEdge - 1),
      ),
      Paint()..color = color,
    );
  }
}
