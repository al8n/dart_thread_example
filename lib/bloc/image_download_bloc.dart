import 'package:flutter/foundation.dart';

class ImageDownloadBloc extends ChangeNotifier {
  int _percentage = 0;

  int get percentage => _percentage;

  set percentage(int val) {
    _percentage = val;
    notifyListeners();
  }

  String _path;

  String get path => _path;
  set path(String val) {
    _path = val;
    notifyListeners();
  }

  bool _done;

  bool get done => _done;

  set done (bool val) {
    _done = done;
    notifyListeners();
  }
}