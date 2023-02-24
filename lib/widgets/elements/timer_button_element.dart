import 'dart:async';
import 'package:flutter/material.dart';

import '../../bloc/turbo_go_bloc.dart';

class TimerButtonElement extends StatefulWidget {
  //final int now;
  final int start;
  final int duration;
  final VoidCallback? onPressed;
  final VoidCallback? onEnd;
  final IconData icon;
  /*Color iconColor = Colors.white;
  Color buttonColor = Colors.black38;
  Color textColor = Colors.white;
  Color progressBarColor = Colors.white;*/
  final Color iconColor;
  final Color buttonColor;
  final String? text;
  final Color textColor;
  final Color barColor;

  const TimerButtonElement({
    Key? key,
    //required this.now,
    required this.start,
    required this.duration,
    required this.icon,
    required this.text,
    required this.iconColor,
    required this.buttonColor,
    required this.textColor,
    required this.barColor,
    this.onPressed,
    this.onEnd
  }) : super(key: key);

  @override
  _TimerButtonElementState createState() => _TimerButtonElementState();
}

class _TimerButtonElementState extends State<TimerButtonElement> {
  Timer? _timer;
  double _timerValue = 0.0;

  int _timeLeft (int start, int duration) {
    return (start + duration) - TurboGoBloc.timestampController.create().millisecondsSinceEpoch;
  }

  @override
  void dispose() {
    if (_timer != null) {
      _timer!.cancel();
    }

    super.dispose();
  }

  @override
  void initState() {
    int timeLeft = _timeLeft(widget.start, widget.duration);

    if (timeLeft > 0) {
      if (widget.onEnd != null) {
        _timer = Timer(Duration(milliseconds: timeLeft), () {
          widget.onEnd!();
        });
      }
      Timer.periodic(const Duration(milliseconds: 100), (_) {
        timeLeft = _timeLeft(widget.start, widget.duration);
        if (mounted) {
          setState(() {
            _timerValue = ((timeLeft / widget.duration) * 100) * 0.01;
          });
        }
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      //key: UniqueKey(),
      //margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: widget.onPressed ?? () {},
            child: Stack(
              alignment: AlignmentDirectional.center,
              children: [
                Icon(
                  widget.icon,
                  color: widget.iconColor,
                ),
                SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(
                      value: _timerValue,
                      color: widget.barColor,
                      strokeWidth: 3,
                    )
                )
              ],
            ),
            style: ElevatedButton.styleFrom(
              primary: widget.buttonColor,
              shape: const CircleBorder(),
              //padding: const EdgeInsets.all(1),
            ),
          ),
          Container(
              child: widget.text != null ? Text(
                widget.text!,
                style: TextStyle(
                    color: widget.textColor
                ),
              ) : null
          )
        ],
      ),
    );
  }
}