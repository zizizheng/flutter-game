import 'package:flutter/material.dart';

class ScoreBoard extends StatefulWidget {
  final bool result;
  final int markedFlag;
  final int totalBombs;
  final int spendTime;
  ScoreBoard({this.result, this.markedFlag, this.totalBombs, this.spendTime});

  @override
  _ScoreBoardState createState() => _ScoreBoardState();
}

class _ScoreBoardState extends State<ScoreBoard> {
  bool show;
  @override
  void initState() {
    show = widget.result != null;
    super.initState();
  }

  @override
  void didUpdateWidget(ScoreBoard oldWidget) {
    if(widget.result != oldWidget.result) {
      show = widget.result != null;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    String min = (widget.spendTime / 60).floor().toString().padLeft(2, '0');
    String sec = (widget.spendTime % 60).floor().toString().padLeft(2, '0');
    return AnimatedOpacity(
      opacity: show ? 1.0 : 0.0,
      duration: Duration(milliseconds: 700),
      child: show
        ? Container(
            color: Colors.white70,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Record(icon: Icons.flag, color: Colors.red, text:widget.markedFlag.toString()),
                Record(icon: Icons.whatshot, color: Colors.black, text:  (widget.totalBombs-widget.markedFlag).toString()),
                Record(
                  icon: Icons.alarm,
                  color: Colors.yellow,
                  text: '$min : $sec',
                ),
                RaisedButton(
                  onPressed: () => _close(),
                  color: Colors.lightBlue,
                  child: Text('關閉紀錄', style: TextStyle(fontSize: 20, color: Colors.white)),
                ),
              ],
            ),
          )
        : Container(),
    );
  }

  void _close() {
    setState(() {
     show = false;
    });
  }
}

class Record extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  Record({this.icon, this.color, this.text});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 60.0, left: 40.0, right: 40.0),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              blurRadius: 8.0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Icon(icon, color: color, size: 50),
            Text(text, style: TextStyle(fontSize: 50)),
          ],
        ),
      ),
    );
  }
}