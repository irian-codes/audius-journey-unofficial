// Copyright (c) 2021 Irian Montón Beltrán
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'package:audius_journey/model/api/track_info.dart';
import 'package:audius_journey/model/states/algorithm_state.dart';
import 'package:audius_journey/screens/track_player_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TrackWidget extends StatelessWidget {
  final TrackInfo trackInfo;

  const TrackWidget({Key? key, required this.trackInfo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Container(
        width: double.infinity,
        child: Card(
          elevation: 5,
          child: Material(
            child: InkWell(
              enableFeedback: true,
              onTap: () async {
                // A bit of a delay so the user sees the visual feedback
                await Future.delayed(Duration(milliseconds: 300));

                context
                    .read<AlgorithmState>()
                    .setCurrentTrack(track: this.trackInfo);
                Navigator.pushNamed(context, TrackPlayerScreen.name);
              },
              child: Column(
                children: [
                  ListTile(
                    title: Text(trackInfo.title, maxLines: 2),
                    subtitle: Text(trackInfo.artist.name, maxLines: 1),
                  ),
                  Center(
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            fit: BoxFit.fitWidth,
                            alignment: Alignment.center,
                            image:
                                ((trackInfo.artwork?.mediumResolution != null)
                                    ? NetworkImage(
                                        trackInfo.artwork!.mediumResolution,
                                      )
                                    : AssetImage(
                                        "assets/images/music_record.jpeg",
                                      )) as ImageProvider,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Genre: ${trackInfo.genre ?? "Unespecified"}",
                              textAlign: TextAlign.start,
                            ),
                            SizedBox(height: 3),
                            Text(
                              "Mood: ${trackInfo.mood ?? "Unespecified"}",
                              textAlign: TextAlign.start,
                            ),
                          ],
                        ),
                        Text(
                          "Duration: ${trackInfo.getFormattedTrackDuration()}",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
