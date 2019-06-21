import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tictoctoe/tetris/tetrominoType.dart';

const double SquareEdge = 22;
const int LineHeight = 20;
const int LineWidth = 10;
const int StepTime = 50;
enum ACTION_QUEUE {
  NEW, STEP
}

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
              colors: [Colors.black, Colors.deepPurpleAccent],
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
  int shapeIndex;
  DrawState(this.points, this.type, this.shapeIndex);
}

class Area extends StatefulWidget {
  @override
  _AreaState createState() => _AreaState();
}

class _AreaState extends State<Area> {
  List<List<TetrominoType>> playMap;
  List<ACTION_QUEUE> actionQueue;
  // repaint by frame(60 fps)
  Timer repaintTimer;
  // add step per 500ms
  Timer stepTimer;
  Random random;
  DrawState drawState;
  bool mapLock = false;

  @override
  void initState() {
    playMap = List.generate(LineHeight, (_) =>
      List.generate(LineWidth, (_) => null),
    );
    actionQueue = [];
    random = new Random();
    drawState = DrawState([], null, -1);
    repaintTimer = Timer.periodic(
      new Duration(milliseconds: 17),
      (Timer t) {
        if(mapLock == true) return ;
        if(actionQueue.length != 0) {
          mapLock = true;
          // DO Tetro behaivor
          final curAction = actionQueue.removeAt(0);
          switch (curAction) {
            case ACTION_QUEUE.NEW:
              _newTetro();
              break;
            case ACTION_QUEUE.STEP:
              _stepDown();
              break;
            default:
          }
          mapLock = false;
        }
      },
    );
    stepTimer = Timer.periodic(
      new Duration(milliseconds: StepTime),
      (t) => actionQueue.add(ACTION_QUEUE.STEP)
    );
    super.initState();
  }

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
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                border: Border.all(width: 4, color: Colors.white)
              ),
              child: SizedBox(
                width: SquareEdge * LineWidth,
                height: SquareEdge * LineHeight,
                child: CustomPaint(
                  painter: MapPainter(playMap),
                ),
              ),
            ),
            RaisedButton(
              onPressed: () => actionQueue.add(ACTION_QUEUE.NEW),
              child: Text('按'),
            )
          ],
        ),
      ),
    );
  }

  // 隨機新增一塊方塊
  void _newTetro() {
    final type = TetrominoType.values.elementAt(random.nextInt(tetrominoes.values.length));
    final shapes = tetrominoes[type].shape;
    final shapeIndex = random.nextInt(shapes.length);
    final randomShape = shapes[shapeIndex];
    int yShift = 0;
    bool isValid = false;
    while(isValid == false && yShift <= 3) {
      isValid = true;
      for(var i = 0; i < 4; i++) {
        for(var j = 0; j < 4; j++) {
          if(
            randomShape[i][j] == 1 &&
            i - yShift >= 0 &&
            playMap[i - yShift][j + 3] != null
          ) {
            isValid = false;
            break;
          }
        }
      }
      if(isValid == false) yShift ++;
    }
    if(yShift > 3) return ;
    setState(() {
      drawState.type = type;
      drawState.shapeIndex = shapeIndex;
      for(var i = 0; i < 4; i++) {
        for(var j = 0; j < 4; j++) {
          if(randomShape[i][j] == 1) {
            drawState.points.add(Point(j + 3, i - yShift));
          }
        }
      }
    });
  }

  void _stepDown() {
    if(drawState.type == null) return ;
    // 清空本來的位置
    drawState.points.forEach((point) {
      if(point.y >= 0) playMap[point.y][point.x] = null;
    });
    // 確保每一格都可以往下畫
    bool canStepDown =  drawState.points.every((point) {
      if(point.y + 1 < 0) return true;
      return point.y + 1 < LineHeight && playMap[point.y + 1][point.x] == null;
    });
    if(canStepDown) {
      setState(() {
        // 往下填入新的顏色
        drawState.points.asMap().forEach((i, point) {
          if(point.y + 1 < 0) return ;
          playMap[point.y + 1][point.x] = drawState.type;
          drawState.points[i] = Point(point.x, point.y + 1);
        });
      });
    }
    // 填回本來的顏色，還原基準點並新增一塊方塊
    else {
      drawState.points.forEach((point) {
        if(point.y < 0) return ;
        playMap[point.y][point.x] = drawState.type;
      });
      actionQueue.add(ACTION_QUEUE.NEW);
      drawState.points = [];
      drawState.type = null;
    }
  }
}

class MapPainter extends CustomPainter {
  List<List<TetrominoType>> playMap;
  MapPainter(this.playMap);
  @override
  void paint(Canvas canvas, Size size) {
    playMap.asMap().forEach((y, row) {
        row.asMap().forEach((x, cell) {
          if(cell != null) {
            canvas.drawRect(
              Rect.fromPoints(
                Offset(x * SquareEdge + 1, y * SquareEdge + 1 ),
                Offset((x + 1) * SquareEdge - 1, (y + 1) * SquareEdge - 1),
              ),
              Paint()..color = tetrominoes[cell].color
            );
          }
        });
    });
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

