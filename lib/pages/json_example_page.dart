import 'dart:isolate';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class JsonExamplePage extends StatefulWidget {
  @override
  _JsonExamplePageState createState() => _JsonExamplePageState();
}

class _JsonExamplePageState extends State<JsonExamplePage> {
  List list = [];

  @override
  void initState() {
    super.initState();
    jsonIsolate();
  }

  static void jsonEntry(SendPort sendPort) async {
    ReceivePort receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    await for(var msg in receivePort) {
      String data = msg[0];
      SendPort replyPort = msg[1];
      String url = data;

      http.Response response = await http.get(url);
      replyPort.send(json.decode(response.body));
    }
  }

  Future jsonIsolate() async {
    ReceivePort receivePort = ReceivePort();
    await Isolate.spawn(jsonEntry, receivePort.sendPort);

    SendPort sendPort = await receivePort.first;

    List message = await jsonSendReceive(
        sendPort, "https://jsonplaceholder.typicode.com/comments");

    setState(() {
      list = message;
    });
  }

  Future jsonSendReceive(SendPort sendPort, message) async {
    ReceivePort responsePort = ReceivePort();
    sendPort.send([message, responsePort.sendPort]);
    return responsePort.first;
  }

  Widget loadData() {
    if ( list.length == 0) {
      return Center(child: CircularProgressIndicator(),);
    } else {
      return ListView.builder(
        itemCount: list.length,
        itemBuilder: (BuildContext buildContext, int index){
          return Container(
            padding: EdgeInsets.all(5.0),
            child: Text("Item: ${list[index]["body"]}"),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("json example"),
      ),
      body: loadData(),
    );
  }
}
