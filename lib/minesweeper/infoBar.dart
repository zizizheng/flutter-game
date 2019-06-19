import 'dart:async';
import 'package:flutter/material.dart';
import 'index.dart';

const double IconSize = 32.0;

class InfoBar extends StatelessWidget {
  final num markedFlag;
  final num totalBombs;
  final GAME_STATUS gameStatus;
  InfoBar({
    @required this.markedFlag,
    @required this.gameStatus,
    @required this.totalBombs,
  });

  static int getSeconds(){
    return _ClockState.seconds;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Row(children: <Widget>[
              Padding(
                child: Icon(Icons.flag, color: Colors.red, size: IconSize),
                padding: EdgeInsets.only(right: 4.0),
              ),
              Text('${totalBombs - markedFlag}', style: TextStyle(fontSize: 24.0)),
            ]),
            Clock(gameStatus),
          ],
        ),
      ),
    );
  }
}

class Clock extends StatefulWidget {
  final GAME_STATUS gameStatus;
  Clock(this.gameStatus);
  @override
  _ClockState createState() => _ClockState();
}

class _ClockState extends State<Clock> {
  static int seconds = 0;
  Timer timer;

  @override
  void didUpdateWidget(Widget oldWidget) {
    setState(() {
      if(widget.gameStatus == GAME_STATUS.START && timer == null) {
        seconds = 0;
        timer = Timer.periodic(
          new Duration(seconds: 1),
          (Timer t) => setState(() { seconds = t.tick;}),
        );
      }
      if(widget.gameStatus == GAME_STATUS.STOP) {
        if(timer is Timer) timer.cancel();
      }
      if(widget.gameStatus == GAME_STATUS.READY) {
        seconds = 0;
        if(timer is Timer) timer.cancel();
        timer = null;
      }
    });

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    if(timer != null) timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String _min = (seconds / 60).floor().toString().padLeft(2, '0');
    String _sec = (seconds % 60).toString().padLeft(2, '0');
    return Row(children: <Widget>[
      Padding(
        child: Icon(Icons.alarm, color: Colors.yellow[600], size: IconSize),
        padding: EdgeInsets.only(right: 4.0),
      ),
      Text('$_min:$_sec', style: TextStyle(fontSize: 24.0)),
    ]);
  }
}