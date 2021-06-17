// Copyright (c) 2021 Irian Montón Beltrán
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'package:async/async.dart';
import 'package:audius_journey/model/api/track_info.dart';
import 'package:audius_journey/model/states/algorithm_state.dart';
import 'package:audius_journey/model/states/app_state.dart';
import 'package:audius_journey/screens/settings_screen.dart';
import 'package:audius_journey/services/audius_api.dart';
import 'package:audius_journey/widgets/track_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TrendingScreen extends StatefulWidget {
  static final String name = 'trending_screen';

  @override
  _TrendingScreenState createState() => _TrendingScreenState();
}

class _TrendingScreenState extends State<TrendingScreen> {
  static final String _TAG = "TrendingScreen: ";
  Future<List<TrackInfo>>? _trendingTracksFuture;

  Future<List<TrackInfo>> _updateTrendingList(BuildContext context) async {
    return Future(() async {
      Result<List<TrackInfo>> result = await AudiusAPI()
          .getTrendingTracks(time: context.read<AppState>().trendingTime);

      if (result.asValue != null) {
        // We need a trending tracks list to display to the user. This is
        // the list to display.
        context.read<AppState>().trendingTracks = result.asValue!.value;

        // And then a separate list of the algorithm because this gets
        // sorted internally. This is the list to choose tracks
        // automatically.
        context
            .read<AlgorithmState>()
            .initialise(context.read<AppState>().trendingTracks);

        return result.asValue!.value;
      } else if (result.asError != null) {
        context.read<AppState>().addException(
              error: result.asError!.error as Exception,
              toastMessage:
                  "Connection error. Couldn't retrieve list of trending songs. Please try again.",
            );

        context.read<AppState>().tracksListRefreshPending = false;

        throw (result.asError!.error as Exception);
      } else {
        Exception error =
            Exception("Unknown error when getting trending list.");

        context.read<AppState>().addException(
              error: error,
              toastMessage:
                  "Connection error. Couldn't retrieve list of trending songs. Please try again.",
            );

        context.read<AppState>().tracksListRefreshPending = false;

        throw error;
      }
    });
  }

  void _getNewFuture(BuildContext context) {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      context.read<AppState>().tracksListRefreshPending = false;

      setState(() {
        this._trendingTracksFuture = this._updateTrendingList(context);
      });
    });
  }

  @override
  void initState() {
    this._getNewFuture(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (context.watch<AppState>().tracksListRefreshPending) {
      this._getNewFuture(context);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Trending tracks of ' +
            () {
              switch (context.watch<AppState>().trendingTime) {
                case TrendingTime.ALL:
                  return "all time";

                case TrendingTime.MONTH:
                  return "the month";

                case TrendingTime.WEEK:
                  return "the week";

                default:
                  return "";
              }
            }.call()),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, SettingsScreen.name),
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      body: Container(
        child: FutureBuilder<List<TrackInfo>>(
          future: this._trendingTracksFuture,
          builder:
              (BuildContext context, AsyncSnapshot<List<TrackInfo>> snapshot) {
            Widget errorWidget = Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          "ERROR while retrieving trending songs. Please push the button to try again.",
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        context.read<AppState>().tracksListRefreshPending =
                            true;
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          "Try again",
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );

            // CHECKING CONNECTION STATE

            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(value: null),
                        SizedBox(height: 20),
                        Text(
                          "Loading trending songs list...",
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                );

              case ConnectionState.active:
              case ConnectionState.done:
                if (snapshot.hasData) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<AppState>().tracksListRefreshPending = true;
                    },
                    child: ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          child: TrackWidget(trackInfo: snapshot.data![index]),
                        );
                      },
                    ),
                  );
                } else {
                  return errorWidget;
                }

              default:
                return errorWidget;
            }
          },
        ),
      ),
    );
  }
}
