// Copyright 2018 Pawan Kumar

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// Original source code at https://github.com/iampawan/Flutter-Music-Player

// Modifications copyright (C) 2021 Irian Montón Beltrán
//
// Merged different original files into this file. Replaced all the
// original behaviour code with one fit for this project. Modified UI code
// to incorporate aspects of this project but maintaining a visual aspect
// close to the original.

// Copyright (c) 2021 Irian Montón Beltrán
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'dart:ui';
import 'package:async/async.dart';
import 'package:audius_journey/model/api/track_info.dart';
import 'package:audius_journey/model/states/algorithm_state.dart';
import 'package:audius_journey/model/states/app_state.dart';
import 'package:audius_journey/model/states/player_state.dart';
import 'package:audius_journey/services/audius_api.dart';
import 'package:audius_journey/widgets/track_player/album_image.dart';
import 'package:audius_journey/widgets/track_player/track_player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audio_manager/audio_manager.dart';

class TrackPlayerScreen extends StatelessWidget {
  static final String _TAG = "TrackPlayerScreen: ";
  static final String name = 'track_player_screen';
  final AudioManager _player = AudioManager.instance;
  late TrackInfo? _currentTrack;

  void _playTrack(BuildContext context) async {
    if (this._currentTrack != null) {
      String? currentTrackId = this._currentTrack?.id;
      String? playingUrl = AudioManager.instance.info?.url;

      // Check that we don't make a request for the track that's already
      // playing.
      if (currentTrackId != null && playingUrl != null) {
        if (playingUrl.contains(currentTrackId)) {
          return;
        }
      }

      Result<String> result =
          await AudiusAPI().getTrackMp3Url(_currentTrack?.id ?? "");

      String? trackMp3Url = result.asValue?.value;

      if (trackMp3Url != null) {
        print("$_TAG" + "Trying to play this track: $trackMp3Url");

        this._player.start(
              trackMp3Url,
              this._currentTrack?.title ?? "",
              desc: this._currentTrack?.description ?? "",
              cover: this._currentTrack?.artwork?.smallResolution ?? "",
            );
      } else {
        late Exception error;

        try {
          error = result.asError!.error as Exception;
        } catch (e) {
          error = Exception("Error while trying track, couldn't get MP3 url.");
        }

        String toastMessage = "";

        if (context.read<AlgorithmState>().errorTries <
            context.read<AlgorithmState>().maxTries) {
          toastMessage = "Couldn't play this track, suggesting a new one.";
        } else {
          toastMessage = "Couldn't play this track, please select another.";
        }

        context.read<AppState>().addException(
              error: error,
              toastMessage: toastMessage,
            );

        context.read<PlayerState>().setStoppedState();
        context
            .read<AlgorithmState>()
            .setCurrentTrack(track: null, tryWithAnotherTrack: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLoading = context.read<PlayerState>().isLoading;
    this._currentTrack = context.watch<AlgorithmState>().currentTrack;

    if (!isLoading && this._currentTrack == null) {
      // We need to add it here or it will crash because for whatever
      // reason it needs to finish building to pop.
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        Navigator.pop(context);
        print(_TAG + "Closing player screen");
      });
    }

    // Scheduling the start of the music player after the UI has been
    // built.
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      this._playTrack(context);
    });

    return Scaffold(
      appBar: AppBar(title: Text('Track player')),
      body: Container(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            // Background image
            Container(
              child: this._currentTrack?.artwork?.mediumResolution != null
                  ? Image.network(
                      _currentTrack?.artwork?.mediumResolution ?? "",
                      fit: BoxFit.cover,
                      color: Colors.black54,
                      colorBlendMode: BlendMode.darken,
                    )
                  : null,
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black87.withOpacity(0.1),
                ),
              ),
            ),
            // Actual track player UI
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                AlbumImage(),
                Material(
                  child:
                      this._currentTrack != null ? TrackPlayer() : Container(),
                  color: Colors.transparent,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
