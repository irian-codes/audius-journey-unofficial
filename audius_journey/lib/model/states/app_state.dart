// Copyright (c) 2021 Irian Montón Beltrán
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'dart:collection';
import 'package:audius_journey/services/audius_api.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:audius_journey/model/api/track_info.dart';
import 'package:flutter/material.dart';

class AppState with ChangeNotifier {
  static final String _TAG = "AppState: ";

  Color _themeColor = Colors.blue;
  Color get themeColor => _themeColor;
  set themeColor(Color value) {
    // We only save a color if it's a MaterialColor. Well, the shade 500, which is the reference (the base value) for every MaterialColor.
    if (value != _themeColor && this._isMaterialColor(value)) {
      _themeColor =
          Colors.primaries.firstWhere((mColor) => mColor.value == value.value);

      notifyListeners();
    }
  }

  TrendingTime _trendingTime = TrendingTime.MONTH;
  TrendingTime get trendingTime => _trendingTime;
  set trendingTime(TrendingTime value) {
    if (value != _trendingTime) {
      _trendingTime = value;
      this.tracksListRefreshPending = true;

      notifyListeners();
    }
  }

  bool _tracksListRefreshPending = true;
  bool get tracksListRefreshPending => _tracksListRefreshPending;
  set tracksListRefreshPending(bool value) {
    if (value != _tracksListRefreshPending) {
      this._tracksListRefreshPending = value;
      notifyListeners();
    }
  }

  List<TrackInfo> _trendingTracks = [];
  List<TrackInfo> get trendingTracks => _trendingTracks;
  set trendingTracks(List<TrackInfo> tracksList) {
    if (tracksList.length > 0 && this._trendingTracks != tracksList) {
      this._trendingTracks = tracksList;
      notifyListeners();
    }
  }

  // This is to have a centralised way to know about exceptions and notify the user if needed.
  final Queue<Exception> _errorsList = Queue();
  Exception? get lastError {
    try {
      return _errorsList.first;
    } catch (e) {
      return null;
    }
  }

  void addException({required Exception error, String? toastMessage}) {
    this._errorsList.addFirst(error);

    if (toastMessage != null && toastMessage.trim().isNotEmpty) {
      // Show error to the user.
      Fluttertoast.showToast(
        msg: toastMessage,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red[200],
        textColor: Colors.black,
        fontSize: 16.0,
      );
    }
  }

  bool _isMaterialColor(Color color) {
    return Colors.primaries.map((mColor) => mColor.value).contains(color.value);
  }
}
