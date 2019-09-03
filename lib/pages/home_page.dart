import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../bloc/image_download_bloc.dart';
import '../bloc/prime_bloc.dart';
import '../bloc/timer_bloc.dart';
import 'thread_page.dart';
import 'json_example_page.dart';
import 'stream_example_page.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {


  @override
  Widget build(BuildContext context) {
    ImageDownloadBloc imageDownloadBloc = Provider.of<ImageDownloadBloc>(context);
    PrimeBloc primeBloc = Provider.of<PrimeBloc>(context);
    TimerBloc timerBloc = Provider.of<TimerBloc>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("multi-thread-download"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Text(
              '质数线程状态：${
                  '${primeBloc.result}'
              }',

              style: TextStyle(
                color: Colors.blueAccent,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 20.0,),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Text(
                  '图片线程状态: ',
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 5,),
                Container(
                  height: 100,
                  width: 200,
                  child: Center(
                    child: imageDownloadBloc.path != null ?
                    Image.file(File(imageDownloadBloc.path)) : Text(
                      "占位图",
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          SizedBox(height: 20.0,),
          Center(
            child: Text(
              '时间线程状态：${timerBloc.duration == null ? '时间线程未开启' : '${timerBloc.duration}s'}',
              style: TextStyle(
                color: Colors.blueAccent,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 20.0,),
          Center(
            child: Text(
              'stream图片线程状态：${imageDownloadBloc.percentage}%',
              style: TextStyle(
                color: Colors.blueAccent,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 20.0,),
          Center(
            child: RaisedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => new ThreadPage()),
                );
              },
              child: Text("下载页面"),
            ),
          ),
          SizedBox(height: 20.0,),
          Center(
            child: RaisedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => new JsonExamplePage()),
                );
              },
              child: Text("json页面"),
            ),
          ),
          SizedBox(height: 20.0,),
          Center(
            child: RaisedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => new StreamExamplePage()),
                );
              },
              child: Text("stream页面"),
            ),
          ),
        ],
      ),
    );
  }
}
