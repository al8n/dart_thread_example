import 'dart:isolate';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker_saver/image_picker_saver.dart';
import 'package:provider/provider.dart';
import '../bloc/image_download_bloc.dart';


class StreamExamplePage extends StatefulWidget {
  @override
  _StreamExamplePageState createState() => _StreamExamplePageState();
}

class _StreamExamplePageState extends State<StreamExamplePage> {

  static imageIsolateEntry(Map<String, dynamic> data) async {
    Dio dio = Dio();
    dio.download(
      data["url"],
      data["path"],
      onReceiveProgress: (int count, int total) {
        int tmp = ((count / total) * 100).toInt();
        data["sendPort"].send(tmp);
      }
    );
  }

  Future downloadImage(ImageDownloadBloc imageDownloadBloc, String url) async {
    String tmpPath;
    bool saveErr = false;
    Uuid uuid = Uuid();
    Directory dir = await getTemporaryDirectory();
    tmpPath = dir.path + '/${uuid.v1().replaceAll('-', '').substring(0, 16) + path.extension(url)}';



    ReceivePort receivePort = ReceivePort();
    Isolate isolate = await Isolate.spawn(imageIsolateEntry, <String, dynamic>{
      "sendPort": receivePort.sendPort,
      "url": url,
      "path": tmpPath,
    });

    receivePort.listen((dynamic data) async {
      if(data == 100) {
        imageDownloadBloc.percentage = data;

        List<int> savedFile = await File.fromUri(Uri.parse(tmpPath)).readAsBytes();
        String saveResult = await ImagePickerSaver.saveFile(
          fileData: savedFile,
        ).catchError((err){
          saveErr = true;
        });

        if (!saveErr) {
          imageDownloadBloc.path = saveResult;
        }
        receivePort.close();
        isolate.kill(priority: Isolate.immediate);

      } else {
        print(data);
        imageDownloadBloc.percentage = data;
      }
    }, onDone: () {
      print('done');
    });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ImageDownloadBloc imageDownloadBloc = Provider.of<ImageDownloadBloc>(context);
    String url = "https://pixabay.com/get/55e8d541495bad14f6da8c7dda79367d1138d7e457586c4870297cd09f4dc658b9_1280.jpg";
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
                  downloadImage(imageDownloadBloc, url);
                },
                child: Text("开始表演"),
              ),
            ),
          )
        ],
      ),
    );
  }
}
