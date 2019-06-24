import 'package:flutter/material.dart';

enum TetrominoType { I, J, L, O, S, T, Z }

Map<TetrominoType, Tetromino> tetrominoes = {
  TetrominoType.I : tetrominoI,
  TetrominoType.J : tetrominoJ,
  TetrominoType.L : tetrominoL,
  TetrominoType.O : tetrominoO,
  TetrominoType.S : tetrominoS,
  TetrominoType.T : tetrominoT,
  TetrominoType.Z : tetrominoZ,
};

class Tetromino {
  Color color;
  List<List<List<int>>> shape;
  Tetromino(this.color, this.shape);
}

// 1 是方塊佔有，2 是轉軸
Tetromino tetrominoI = Tetromino(
  Colors.lightBlue[200],
  [
    [
      [1, 2, 1, 1],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ],
    [
      [0, 1, 0, 0],
      [0, 2, 0, 0],
      [0, 1, 0, 0],
      [0, 1, 0, 0],
    ],
    [
      [0, 0, 0, 0],
      [1, 1, 2, 1],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ],
    [
      [0, 0, 1, 0],
      [0, 0, 2, 0],
      [0, 0, 1, 0],
      [0, 0, 1, 0],
    ],
  ]
);

Tetromino tetrominoJ = Tetromino(
  Colors.blue[900],
  [
    [
      [1, 2, 1, 0],
      [0, 0, 1, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ],
    [
      [0, 1, 0, 0],
      [0, 2, 0, 0],
      [1, 1, 0, 0],
      [0, 0, 0, 0],
    ],
    [
      [1, 0, 0, 0],
      [1, 2, 1, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ],
    [
      [1, 1, 0, 0],
      [2, 0, 0, 0],
      [1, 0, 0, 0],
      [0, 0, 0, 0],
    ],
  ]
);

Tetromino tetrominoL = Tetromino(
  Colors.orange[700],
  [
    [
      [1, 2, 1, 0],
      [1, 0, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ],
    [
      [1, 1, 0, 0],
      [0, 2, 0, 0],
      [0, 1, 0, 0],
      [0, 0, 0, 0],
    ],
    [
      [0, 0, 1, 0],
      [1, 2, 1, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ],
    [
      [1, 0, 0, 0],
      [2, 0, 0, 0],
      [1, 1, 0, 0],
      [0, 0, 0, 0],
    ],
  ]
);

Tetromino tetrominoO = Tetromino(
  Colors.yellow,
  [
    [
      [1, 1, 0, 0],
      [1, 1, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ],
  ]
);

Tetromino tetrominoS = Tetromino(
  Colors.lightGreenAccent[400],
  [
    [
      [0, 1, 1, 0],
      [1, 2, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ],
    [
      [1, 0, 0, 0],
      [1, 2, 0, 0],
      [0, 1, 0, 0],
      [0, 0, 0, 0],
    ],
  ]
);

Tetromino tetrominoT = Tetromino(
  Colors.purple[700],
  [
    [
      [0, 1, 0, 0],
      [1, 2, 1, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ],
    [
      [1, 0, 0, 0],
      [2, 1, 0, 0],
      [1, 0, 0, 0],
      [0, 0, 0, 0],
    ],
    [
      [1, 2, 1, 0],
      [0, 1, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ],
    [
      [0, 0, 1, 0],
      [0, 1, 2, 0],
      [0, 0, 1, 0],
      [0, 0, 0, 0],
    ],
  ]
);
Tetromino tetrominoZ = Tetromino(
  Colors.red[900],
  [
    [
      [1, 1, 0, 0],
      [0, 2, 1, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ],
    [
      [0, 1, 0, 0],
      [1, 2, 0, 0],
      [1, 0, 0, 0],
      [0, 0, 0, 0],
    ],
  ]
);