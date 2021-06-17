// Copyright (c) 2021 Irian Montón Beltrán
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'package:audio_manager/audio_manager.dart';
import 'package:audius_journey/model/api/track_info.dart';
import 'package:audius_journey/model/states/algorithm_state.dart';
import 'package:audius_journey/model/states/player_state.dart';
import 'package:audius_journey/model/track_score.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:like_button/like_button.dart';

import 'control_button.dart';

class TrackPlayer extends StatelessWidget {
  static final String _TAG = "TrackPlayer: ";

  /// Changes current track to next or previous track depending on the
  /// [next] parameter value.
  void _changeTrack({required BuildContext context, required bool next}) {
    if (next) {
      context
          .read<AlgorithmState>()
          .handleUserAction(action: TrackAction.SKIPPED_NEXT);
    } else {
      context
          .read<AlgorithmState>()
          .handleUserAction(action: TrackAction.SKIPPED_PREVIOUS);
    }
  }

  void _onRatingButtonTapped({
    required BuildContext context,
    required bool isLiked,
  }) {
    TrackAction action =
        (isLiked) ? TrackAction.THUMB_UP : TrackAction.THUMB_DOWN;

    context.read<AlgorithmState>().handleUserAction(action: action);
  }

  String _formatTrackDuration(Duration trackTimeElapsed) {
    return trackTimeElapsed.inHours.toString().padLeft(2, "0") +
        ":" +
        trackTimeElapsed.inMinutes.remainder(60).toString().padLeft(2, "0") +
        ":" +
        trackTimeElapsed.inSeconds.remainder(60).toString().padLeft(2, "0");
  }

  Widget _getTrackInfoText({
    required BuildContext context,
    required TrackInfo track,
  }) {
    String titleText = track.title;
    String artistText = track.artist.name;
    final int maxTitleChars = 25;
    final int maxArtistChars = 20;

    if (titleText.length > maxTitleChars) {
      titleText = titleText.substring(0, maxTitleChars) + "...";
    }

    if (artistText.length > maxArtistChars) {
      artistText = artistText.substring(0, maxArtistChars) + "...";
    }

    return Column(
      children: [
        Text(
          titleText,
          style: Theme.of(context).textTheme.headline5,
        ),
        Text(
          artistText,
          style: Theme.of(context).textTheme.bodyText1,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isPlaying = context.watch<PlayerState>().isPlaying;
    bool isLoading = context.watch<PlayerState>().isLoading;
    TrackScore? currentTrack = context.watch<AlgorithmState>().currentTrack;
    double slider = context.watch<PlayerState>().slider;
    Duration trackDuration = context.watch<PlayerState>().trackDuration;

    return (currentTrack == null)
        ? Container()
        : Container(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(90),
                    color: Colors.white.withOpacity(0.55),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: this._getTrackInfoText(
                      context: context,
                      track: currentTrack,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  ControlButton(Icons.skip_previous, () {
                    this._changeTrack(context: context, next: false);
                  }),
                  ControlButton(
                    (isPlaying || isLoading) ? Icons.pause : Icons.play_arrow,
                    () {
                      (AudioManager.instance.isPlaying)
                          ? AudioManager.instance.toPause()
                          : AudioManager.instance.toPlay();
                    },
                  ),
                  ControlButton(Icons.skip_next, () {
                    this._changeTrack(context: context, next: true);
                  }),
                ]),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Flexible(
                      flex: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(90),
                          color: Colors.white.withOpacity(0.55),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          child: Text(
                            (!isLoading)
                                ? this._formatTrackDuration(
                                    trackDuration * slider,
                                  )
                                : "--:--:--",
                            style: TextStyle(fontSize: 14.0),
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 3,
                      child: Slider(
                        value: slider,
                        onChanged: (value) {
                          context.read<PlayerState>().slider = value;
                        },
                        onChangeEnd: (value) {
                          AudioManager.instance
                              .seekTo(AudioManager.instance.duration * value);
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    LikeButton(
                      onTap: (_) async {
                        this._onRatingButtonTapped(
                          context: context,
                          isLiked: false,
                        );

                        return true;
                      },
                      size: 50,
                      likeCount: null,
                      likeBuilder: (bool isLiked) {
                        return Icon(
                          Icons.thumb_down,
                          color: currentTrack.lastRatingAction ==
                                  TrackAction.THUMB_DOWN
                              ? Colors.redAccent
                              : Colors.grey,
                          size: 50,
                        );
                      },
                    ),
                    LikeButton(
                      onTap: (_) async {
                        this._onRatingButtonTapped(
                          context: context,
                          isLiked: true,
                        );

                        return true;
                      },
                      size: 50,
                      likeCount: null,
                      likeBuilder: (bool isLiked) {
                        return Icon(
                          Icons.thumb_up,
                          color: currentTrack.lastRatingAction ==
                                  TrackAction.THUMB_UP
                              ? Colors.greenAccent
                              : Colors.grey,
                          size: 50,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
  }
}
