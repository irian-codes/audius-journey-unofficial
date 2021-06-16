// Copyright (c) 2021 Irian Montón Beltrán
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'package:audius_journey/model/api/track_info.dart';
import 'package:audius_journey/model/states/algorithm_state.dart';

class TrackScore extends TrackInfo implements Comparable<TrackScore> {
  static final String _TAG = "TrackScore: ";

  final ScoreFactors scoreFactors;
  int _score = 0;
  int get score => _score;
  // We store the order where the track was played, 0 meaning it never played, to get it in case the user wants to listen to previously listened tracks.
  int _playOrder = 0;
  int get playOrder => _playOrder;
  set playOrder(int value) {
    // Cannot set number to 0 again or negative, otherwise it would imply it has not been played which is not the case.
    if (value > 0) {
      this._playOrder = value;
    }
  }

  TrackAction _lastRatingAction = TrackAction.NONE;
  TrackAction get lastRatingAction => this._lastRatingAction;
  set lastRatingAction(TrackAction action) {
    // NONE is a state that is only meant to be used to mark the song was never played before. Therefore you can't update to this value.
    if (action != TrackAction.NONE) {
      this._lastRatingAction = action;
    }
  }

  TrackScore.fromTrackInfo({
    required TrackInfo track,
    required this.scoreFactors,
  }) : super(
          track.artwork,
          track.description,
          track.genre,
          track.id,
          track.mood,
          track.duration,
          track.releaseDate,
          track.tags,
          track.title,
          track.artist,
        ) {
    this.updateTotalScore();
  }

  int _calcMoodScore() {
    String? moodKey = this.mood?.trim().toLowerCase();

    if (moodKey != null) {
      return this.scoreFactors.getMoodScore(moodKey);
    } else {
      return 0;
    }
  }

  int _calcGenreScore() {
    String? genreKey = this.genre?.trim().toLowerCase();

    if (genreKey != null) {
      return this.scoreFactors.getGenreScore(genreKey);
    } else {
      return 0;
    }
  }

  int _calcArtistScore() {
    String? artistKey = this.artist.id.trim();

    if (artistKey != null) {
      return this.scoreFactors.getArtistScore(artistKey);
    } else {
      return 0;
    }
  }

  void updateTotalScore() {
    this._score += _calcMoodScore();
    this._score += _calcGenreScore();
    this._score += _calcArtistScore();

    print(_TAG + "Track score updated to ${this.score}: ${this.title}.");
  }

  /// The highest score of an entire list will have index 0.
  @override
  int compareTo(TrackScore other) {
    return other._score - this._score;
  }

  @override
  String toString() {
    return "'${this.title}' by ${this.artist.name}. Score: ${this.score}";
  }
}

enum TrackAction {
  THUMB_UP,
  THUMB_DOWN,
  SKIPPED_NEXT,
  SKIPPED_PREVIOUS,
  PLAYED,
  OTHER,
  NONE,
}
