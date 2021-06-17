// Copyright (c) 2021 Irian Montón Beltrán
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'package:audio_manager/audio_manager.dart';
import 'package:audius_journey/model/states/algorithm_state.dart';
import 'package:audius_journey/model/states/app_state.dart';
import 'package:audius_journey/model/states/player_state.dart';
import 'package:audius_journey/model/track_score.dart';
import 'package:audius_journey/model/user_settings.dart';
import 'package:audius_journey/screens/settings_screen.dart';
import 'package:audius_journey/screens/track_player_screen.dart';
import 'package:audius_journey/screens/trending_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  final String _TAG = "main() method: ";

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AppState()),
      ChangeNotifierProvider(create: (_) => PlayerState()),
      ChangeNotifierProvider(create: (context) => AlgorithmState(context)),
    ],
    builder: (BuildContext context, Widget? widget) {
      UserSettings().loadSettings(context);

      return MyApp();
    },
  ));
}

class MyApp extends StatelessWidget {
  static final String _TAG = "MyApp: ";

  // ignore: long-method
  void _registerPlayerCallbacks(BuildContext context) {
    AudioManager.instance.onEvents((events, args) {
      switch (events) {
        case AudioManagerEvents.ready:
          context.read<PlayerState>().isReady = true;
          context.read<PlayerState>().isLoading = false;
          context.read<PlayerState>().trackDuration =
              AudioManager.instance.duration;

          print(_TAG +
              "Playing track: ${AudioManager.instance.info?.title ?? 'NONE'}");
          break;

        case AudioManagerEvents.start:
          context.read<PlayerState>().slider = 0;
          break;

        case AudioManagerEvents.seekComplete:
          context.read<PlayerState>().slider =
              AudioManager.instance.position.inMilliseconds /
                  AudioManager.instance.duration.inMilliseconds;
          break;

        case AudioManagerEvents.playstatus:
          context.read<PlayerState>().isPlaying =
              AudioManager.instance.isPlaying;

          break;

        case AudioManagerEvents.timeupdate:
          context.read<PlayerState>().slider =
              AudioManager.instance.position.inMilliseconds /
                  AudioManager.instance.duration.inMilliseconds;

          AudioManager.instance.updateLrc(args["position"].toString());
          break;

        case AudioManagerEvents.next:
          context
              .read<AlgorithmState>()
              .handleUserAction(action: TrackAction.SKIPPED_NEXT);
          break;

        case AudioManagerEvents.ended:
          AudioManager.instance.toPause();
          context
              .read<AlgorithmState>()
              .handleUserAction(action: TrackAction.PLAYED);
          break;

        case AudioManagerEvents.error:
          print("ERROR: " + _TAG + "Media player error.");
          context.read<AppState>().addException(
                error: Exception("Media player plugin error"),
                toastMessage: "Software error, please restart the app.",
              );

          context.read<PlayerState>().setStoppedState();

          // Since this is a plugin error, it seems more serious and we don't want to try a new track. Better to restart the app.
          context
              .read<AlgorithmState>()
              .setCurrentTrack(track: null, tryWithAnotherTrack: false);
          break;

        case AudioManagerEvents.stop:
          if (context.read<AlgorithmState>().currentTrack != null) {
            // We only set the track to null when it's a real stop, not one caused by loading the track, because changing the track triggers an stop event.
            if (!context.read<PlayerState>().isLoading) {
              context.read<PlayerState>().isReady = false;
              context.read<AlgorithmState>().setCurrentTrack(track: null);
            }
          }
          break;

        default:
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      this._registerPlayerCallbacks(context);
    });

    return MaterialApp(
      title: 'Audius Journey',
      theme: ThemeData(
        primarySwatch: (context.watch<AppState>().themeColor) as MaterialColor,
      ),
      initialRoute: TrendingScreen.name,
      routes: {
        TrendingScreen.name: (_) => TrendingScreen(),
        TrackPlayerScreen.name: (_) => TrackPlayerScreen(),
        SettingsScreen.name: (_) => SettingsScreen(),
      },
    );
  }
}
