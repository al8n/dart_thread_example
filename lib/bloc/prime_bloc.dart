import 'package:flutter/foundation.dart';

class PrimeBloc extends ChangeNotifier {
  int _result;

  int get result => _result;

  set result(int val) {
    _result = val;
    notifyListeners();
  }

  bool _done;

  bool get done => _done;

  set done (bool val) {
    _done = done;
    notifyListeners();
  }
}