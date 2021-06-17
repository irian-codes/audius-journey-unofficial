// Copyright (c) 2021 Irian Montón Beltrán
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'dart:ui';
import 'package:audius_journey/model/states/app_state.dart';
import 'package:audius_journey/services/audius_api.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class UserSettings {
  static final UserSettings _instance = UserSettings._internal();
  SharedPreferences? _prefs;

  UserSettings._internal() {
    this.initialise();
  }

  factory UserSettings() {
    return _instance;
  }

  Future<void> initialise() async {
    if (this._prefs == null) {
      this._prefs = await SharedPreferences.getInstance();
    }
  }

  Future<void> loadSettings(BuildContext context) async {
    await this._getSavedThemeColor(context);
    await this._getSavedTrendingTime(context);
  }

  Future<TrendingTime?> _getSavedTrendingTime(BuildContext context) async {
    await this.initialise();

    late TrendingTime tRtime;

    try {
      tRtime = TrendingTime.fromString(this._prefs?.getString('tr_time') ?? "");
    } catch (e) {
      return null;
    }

    context.read<AppState>().trendingTime = tRtime;

    return tRtime;
  }

  Future<void> saveTrendingTime(BuildContext context, TrendingTime time) async {
    await this.initialise();

    if (this._prefs != null) {
      await this._prefs!.setString('tr_time', time.toString());
      context.read<AppState>().trendingTime = time;
    }
  }

  Future<Color?> _getSavedThemeColor(BuildContext context) async {
    await this.initialise();

    int? colorCode = this._prefs?.getInt('theme_color');

    if (colorCode == null) {
      return null;
    } else {
      Color color = Color(colorCode);
      context.read<AppState>().themeColor = color;

      return color;
    }
  }

  Future<void> saveThemeColor(BuildContext context, Color color) async {
    await this.initialise();

    if (this._prefs != null) {
      await this._prefs!.setInt('theme_color', color.value);
      context.read<AppState>().themeColor = color;
    }
  }

  Future<bool> clearAllPrefs() async {
    await this.initialise();

    return (await this._prefs?.clear()) ?? false;
  }
}
