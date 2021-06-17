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
// Changed name of the original file from 'mp_album_ui.dart' to the current
// one. Simplified file by removing animations and progress bar.

// Copyright (c) 2021 Irian Montón Beltrán
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'package:audius_journey/model/api/track_info.dart';
import 'package:audius_journey/model/states/algorithm_state.dart';
import 'package:audius_journey/model/states/player_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AlbumImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    TrackInfo? track = context.read<AlgorithmState>().currentTrack;
    bool isReady = context.watch<PlayerState>().isReady;
    bool isLoading = context.watch<PlayerState>().isLoading;

    if (track == null) {
      return Container();
    }

    var albumImage = track.artwork?.mediumResolution;

    return Material(
      elevation: 5.0,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
        ),
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            (albumImage == null || !isReady || isLoading
                ? Image.asset(
                    "assets/images/music_record.jpeg",
                    fit: BoxFit.cover,
                    height: 250,
                    width: 250,
                    gaplessPlayback: false,
                  )
                : Image.network(
                    albumImage,
                    fit: BoxFit.cover,
                    height: 250,
                    width: 250,
                    gaplessPlayback: true,
                  )),
            Transform.scale(
              scale: 1.8,
              child: CircularProgressIndicator(
                value: (!isReady || isLoading) ? null : 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
