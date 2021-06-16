// Copyright (c) 2021 Irian Montón Beltrán
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'package:flutter/material.dart';
import 'dart:math';

class PlayerState with ChangeNotifier {
  static final String _TAG = "PlayerState: ";

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;
  set isPlaying(bool value) {
    this._isPlaying = value;
    if (value) this.isLoading = false;
    notifyListeners();
  }

  double _slider = 0;
  double get slider => _slider;
  set slider(double value) {
    if (value.isNaN || value.isInfinite || value < 0) {
      value = 0;
    }

    this._slider = min(1, max(0, value));
    notifyListeners();
  }

  Duration _trackDuration = Duration(seconds: 0);
  Duration get trackDuration => _trackDuration;
  set trackDuration(Duration value) {
    this._trackDuration = value;
    notifyListeners();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    this._isLoading = value;

    if (value) {
      this.slider = 0;
      this.isReady = false;
    }

    notifyListeners();
  }

  bool _isReady = false;
  bool get isReady => _isReady;
  set isReady(bool value) {
    this._isReady = value;

    if (value) this.isLoading = false;

    notifyListeners();
  }

  void setStoppedState() {
    this.isLoading = false;
    this.isReady = false;
  }
}
