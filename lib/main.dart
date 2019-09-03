import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'bloc/image_download_bloc.dart';
import 'bloc/timer_bloc.dart';
import 'bloc/prime_bloc.dart';
import 'pages/home_page.dart';


void main() => runApp(AppMiddleware());

class AppMiddleware extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      builder: (context) => new ImageDownloadBloc(),
      child: ChangeNotifierProvider(
        builder: (context) => new TimerBloc(),
        child: ChangeNotifierProvider(
          builder: (context) => new PrimeBloc(),
          child: MyApp(),
        ),
      ),
    );
  }
}


class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}


