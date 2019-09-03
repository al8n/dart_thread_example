import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:isolate';
import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker_saver/image_picker_saver.dart';
import '../bloc/image_download_bloc.dart';
import '../bloc/prime_bloc.dart';


class ThreadPage extends StatefulWidget {
  @override
  _ThreadPageState createState() => _ThreadPageState();
}

class _ThreadPageState extends State<ThreadPage> {
  Isolate primeIsolate;
  SendPort primeSendPort;
  ReceivePort primeReceivePort;

  Isolate imageIsolate;
  SendPort imageSendPort;
  ReceivePort imageReceivePort;

  Isolate imageIsolate$;
  SendPort imageSendPort$;
  ReceivePort imageReceivePort$;

  var list;

  /// 质数线程
  // 判断是否是质数
  static bool isPrime(int n) {
    int count = 0;
    for (int i = 1; i <= n; ++i) {
      if (n % i == 0) {
        ++count;
      }
    }
    return count == 2;
  }
  // 返回第n个质数
  static getnthPrime(SendPort sendPort) async {
    // 从主进程中接收信息.
    // 我们接收到用户需要计算第n位的质数.
    ReceivePort receivePort = ReceivePort();
    // 将信息从线程中返回给主进程.
    sendPort.send(receivePort.sendPort);
    var msg = await receivePort.first;

    int n = msg[0];
    SendPort replyPort = msg[1];
    int currentPrimeCount = 0;
    int candidate = 1;
    while (currentPrimeCount < n) {
      ++candidate;
      if (isPrime(candidate)) {
        ++currentPrimeCount;
      }
    }
    replyPort.send(candidate);

  }

  Future sendReceive(SendPort send, message) {
    ReceivePort receivePort = ReceivePort();
    send.send([message, receivePort.sendPort]);
    return receivePort.first;
  }

  void _getPrime(PrimeBloc primeBloc, int nth) async {
    // 开启一个端口接收结果.
    primeReceivePort = ReceivePort();
    primeIsolate = await Isolate.spawn(getnthPrime, primeReceivePort.sendPort);

    // 在这里我们接收第一个值，并且把它存入provider状态池中
    SendPort sendPort = await primeReceivePort.first;
    int ans = await sendReceive(sendPort, nth);

    primeBloc.result = ans;
    primeReceivePort.close();
    primeIsolate.kill(priority: Isolate.immediate);
  }


  /// 使用第一种方法实现并发下载图片
  static void downloadImage(SendPort sendPort) async {
    bool downloadErr = false;

    // 从主进程中接收信息.
    // 我们接收到用户需要计算第n位的质数.
    ReceivePort receivePort = ReceivePort();
    // 将信息从线程中返回给主进程.
    sendPort.send(receivePort.sendPort);
    Map<String, dynamic> data = await receivePort.first;
    SendPort replyPort = data["sendPort"];
    Dio dio = Dio();
    await dio.download(
      data["url"],
      data["path"],
    ).catchError((err) {
      downloadErr = true;
    }).whenComplete(() {
      if (downloadErr) {
        replyPort.send(<String, dynamic>{
          "msg": "download fail",
          "code": -1,
          "finish": true,
        });
        return ;
      }
    });

    replyPort.send(<String, dynamic>{
      "msg": "success",
      "code": 0,
      "finish": true,
    });
  }

  void _downloadImage(ImageDownloadBloc imageDownloadBloc, String url) async {
    String tmpPath;
    bool saveErr = false;
    Directory dir = await getTemporaryDirectory();
    Uuid uuid = new Uuid();
    tmpPath = dir.path + '/${uuid.v1().replaceAll('-', '').substring(0, 16) + path.extension(url)}';
    imageReceivePort = ReceivePort();
    imageIsolate = await Isolate.spawn(downloadImage, imageReceivePort.sendPort);
    SendPort sendPort = await imageReceivePort.first;
    Map<String, dynamic> result = await sendImageReceive(sendPort, url, tmpPath);
    imageDownloadBloc.done = true;
    if (result["code"] == 0) {
      List<int> savedFile = await File.fromUri(Uri.parse(tmpPath)).readAsBytes();

      String saveResult = await ImagePickerSaver.saveFile(
        fileData: savedFile,
      ).catchError((err){
        saveErr = true;
      });

      if (!saveErr) {
        imageDownloadBloc.path = saveResult;
      }
    }



    imageReceivePort.close();
    imageIsolate.kill(priority: Isolate.immediate);
  }

  Future sendImageReceive(SendPort sendPort, String url, String path) {
    ReceivePort receivePort = ReceivePort();
    sendPort.send(<String, dynamic>{
      "url": url,
      "path": path,
      "sendPort": receivePort.sendPort
    });
    return receivePort.first;
  }


  @override
  Widget build(BuildContext context) {
    ImageDownloadBloc imageDownloadBloc = Provider.of<ImageDownloadBloc>(context);
    PrimeBloc primeBloc = Provider.of<PrimeBloc>(context);
    String url = "https://pixabay.com/get/55e8d541495bad14f6da8c7dda79367d1138d7e457586c4870297cd09f4dc658b9_1280.jpg";
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
            child: RaisedButton(
              onPressed: () {
                _getPrime(primeBloc, 5000);
              },
              child: Text("开启质数线程"),
            ),
          ),
          SizedBox(height: 10.0,),
          Center(
            child: RaisedButton(
              onPressed: () {
                _downloadImage(imageDownloadBloc, url);
              },
              child: Text("开启图片下载线程"),
            ),
          ),
          SizedBox(height: 10.0,),
        ],
      ),
    );
  }
}





