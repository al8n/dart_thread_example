import 'dart:isolate';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../bloc/timer_bloc.dart';


class TimerExamplePage extends StatefulWidget {
  @override
  _TimerExamplePageState createState() => _TimerExamplePageState();
}

class _TimerExamplePageState extends State<TimerExamplePage> {
  static int timerDuration = 0;
  int val = 0;

  static isolateEntry(SendPort sendPort) async {
    Timer.periodic(Duration(seconds: 1,), (Timer t) {
      timerDuration++;
      sendPort.send(timerDuration);
    });
  }

  Future timerIsolate(TimerBloc timerBloc, int duration) async {
    ReceivePort receivePort = ReceivePort();

    Isolate isolate = await Isolate.spawn(isolateEntry, receivePort.sendPort);

    receivePort.listen((data){
      timerBloc.duration = data;
      if(data >= duration) {
        receivePort.close();
        isolate.kill(priority: Isolate.immediate);
      }
    }, onDone: () {
      print('done');
    });

  }


  @override
  Widget build(BuildContext context) {
    TimerBloc timerBloc = Provider.of<TimerBloc>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("stream页面"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Container(
            child: Center(
              child: RaisedButton(
                onPressed: (){
                  timerIsolate( timerBloc, 30);
                },
                child: Text("开始计时"),
              ),
            ),
          )
        ],
      ),
    );
  }
}
