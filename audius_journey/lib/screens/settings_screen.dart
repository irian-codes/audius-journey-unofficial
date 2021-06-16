// Copyright (c) 2021 Irian Montón Beltrán
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'package:audius_journey/model/states/app_state.dart';
import 'package:audius_journey/model/user_settings.dart';
import 'package:audius_journey/services/audius_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  static final String name = "settings_screen";
  static final String _TAG = "SettingsScreen: ";

  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select a theme color"),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: context.watch<AppState>().themeColor,
              onColorChanged: (newColor) {
                UserSettings().saveThemeColor(context, newColor);
              },
              availableColors: Colors.primaries,
            ),
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
              ),
            ),
          ],
        );
      },
      useSafeArea: true,
    );
  }

  void _showTimePeriodPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select the time period of trending songs"),
          content: SingleChildScrollView(
            child: Container(
              child: Column(
                children: [
                  this._getButtonAccordingToState(
                    context: context,
                    buttonTime: TrendingTime.WEEK,
                  ),
                  this._getButtonAccordingToState(
                    context: context,
                    buttonTime: TrendingTime.MONTH,
                  ),
                  this._getButtonAccordingToState(
                    context: context,
                    buttonTime: TrendingTime.ALL,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
              ),
            ),
          ],
        );
      },
      useSafeArea: true,
    );
  }

  Widget _getButtonAccordingToState({
    required BuildContext context,
    required TrendingTime buttonTime,
  }) {
    TrendingTime selectedTime = context.watch<AppState>().trendingTime;
    String text = "";

    switch (buttonTime) {
      case TrendingTime.ALL:
        text = "All time";
        break;

      case TrendingTime.MONTH:
        text = "All month";
        break;

      case TrendingTime.WEEK:
        text = "All week";
        break;

      default:
        text = "";
        break;
    }

    ButtonStyle highlightedButtonStyle = ButtonStyle(
      backgroundColor:
          MaterialStateProperty.all(Theme.of(context).primaryColor),
    );

    TextStyle? highlightedTextStyle = Theme.of(context).accentTextTheme.button;

    if (selectedTime == buttonTime) {
      return OutlinedButton(
        onPressed: () {
          UserSettings().saveTrendingTime(context, buttonTime);
        },
        child: Text(
          text,
          style: highlightedTextStyle,
        ),
        style: highlightedButtonStyle,
      );
    } else {
      return OutlinedButton(
        onPressed: () {
          UserSettings().saveTrendingTime(context, buttonTime);
        },
        child: Text(text),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: GestureDetector(
                onTap: () => this._showColorPicker(context),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black26),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(width: 1),
                        Text(
                          "Theme color",
                          style: TextStyle(fontSize: 20),
                          textAlign: TextAlign.center,
                        ),
                        Container(
                          child: Container(
                            height: 60,
                            width: 150,
                            decoration: BoxDecoration(
                              color: context.watch<AppState>().themeColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: GestureDetector(
                onTap: () => this._showTimePeriodPicker(context),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black26),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(width: 1),
                        Text(
                          "Trending songs\nperiod",
                          style: TextStyle(fontSize: 20),
                          textAlign: TextAlign.center,
                        ),
                        Container(
                          child: Container(
                            height: 60,
                            width: 150,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              () {
                                switch (
                                    context.watch<AppState>().trendingTime) {
                                  case TrendingTime.ALL:
                                    return "All time";

                                  case TrendingTime.MONTH:
                                    return "All month";

                                  case TrendingTime.WEEK:
                                    return "All week";

                                  default:
                                    return "";
                                }
                              }.call(),
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
