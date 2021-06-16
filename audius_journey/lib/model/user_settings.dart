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

  UserSettings._internal();

  factory UserSettings() {
    return _instance;
  }

  Future<void> loadSettings(BuildContext context) async {
    await this.getSavedThemeColor(context);
    await this.getSavedTrendingTime(context);
  }

  Future<TrendingTime?> getSavedTrendingTime(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    TrendingTime? tRtime = TrendingTime.fromString(prefs.getString('tr_time'));

    if (tRtime != null) {
      context.read<AppState>().trendingTime = tRtime;
    }

    return tRtime;
  }

  Future<void> saveTrendingTime(BuildContext context, TrendingTime time) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('tr_time', time.toString());
    context.read<AppState>().trendingTime = time;
  }

  Future<Color?> getSavedThemeColor(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    int? colorCode = prefs.getInt('theme_color');

    if (colorCode == null) {
      return null;
    } else {
      Color color = Color(colorCode);
      context.read<AppState>().themeColor = color;

      return color;
    }
  }

  Future<void> saveThemeColor(BuildContext context, Color color) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_color', color.value);
    context.read<AppState>().themeColor = color;
  }

  Future<bool> clearAllPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return await prefs.clear();
  }
}
