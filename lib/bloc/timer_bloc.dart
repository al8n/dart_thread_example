import 'package:flutter/foundation.dart';

class TimerBloc extends ChangeNotifier {
  int _duration;

  int get duration => _duration;

  set duration(int val) {
    _duration = val;
    notifyListeners();
  }

}