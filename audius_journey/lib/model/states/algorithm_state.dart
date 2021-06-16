// Copyright (c) 2021 Irian Montón Beltrán
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'dart:collection';
import 'package:audius_journey/model/api/track_info.dart';
import 'package:audius_journey/model/states/player_state.dart';
import 'package:audius_journey/model/track_score.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Handles the song recommendation algorithm. Assigns scores at each song depending on what the user action was.
/// For example, if the user tapped the downvote (thumb down) button then a -2 score to that artist, genre and mood is assigned globally.
/// Then with these global score each song calculates its own score. That way the algorithm can recommend the next song, based on a favourable score.
/// This class is not saved in the permanent storage since its assumed the user may have different preferenes on a given day, and it's better to start fresh each time. So if the app is killed, the score resets to 0.
class AlgorithmState with ChangeNotifier {
  static final String _TAG = "AlgorithmState: ";
  final ScoreFactors _scoreFactors = ScoreFactors();
  List<TrackScore> _tracksPlayList = [];
  TrackScore? _currentTrack;
  TrackScore? get currentTrack => _currentTrack;

  final int maxTries = 10;
  int _errorTries = 0;
  int get errorTries => _errorTries;

  int _playOrderTracker = 0;

  bool _initialised = false;
  bool get initialised => _initialised;
  BuildContext context;

  AlgorithmState(this.context);

  void initialise(List<TrackInfo> tracks) {
    // If it is not initialied we just create the whole list, if it is we only add the new songs we detected as trending.
    // We want to keep the old ones because even though they are not anymore in the trending list, maybe the user wants to listen them again.
    if (!this.initialised) {
      this._tracksPlayList = tracks
          .map(
            (t) => TrackScore.fromTrackInfo(
              track: t,
              scoreFactors: this._scoreFactors,
            ),
          )
          .toList();

      this._initialised = true;
    } else {
      tracks.forEach(
        (t) {
          if (!this._tracksPlayList.contains(t)) {
            this._tracksPlayList.add(
                  TrackScore.fromTrackInfo(
                    track: t,
                    scoreFactors: this._scoreFactors,
                  ),
                );
          }
        },
      );
    }
  }

  void _setCurrentTrackSR(TrackScore? value) {
    if (this._currentTrack != value) {
      this._currentTrack = value;

      if (value == null) {
        // We set error tries to 0 because if we deliverately let the track be null is the behaviour that we want to keep, and avoid further trying.
        this._errorTries = 0;
        print(_TAG + "Set current track to NULL");
      } else {
        context.read<PlayerState>().isLoading = true;

        print(_TAG +
            "Set current track to: ${value.title} by ${value.artist.name} with score ${value.score}");
      }

      notifyListeners();
    }
  }

  /// Manually set [currentTrack] to a specific track.
  /// Passing null means no track is being played, in other words, stop playing any tracks.
  void setCurrentTrack({
    required TrackInfo? track,
    bool tryWithAnotherTrack = false,
  }) {
    if (track == null) {
      // We want to find another track if the current one gave error.
      if (tryWithAnotherTrack &&
          this.currentTrack != null &&
          this._errorTries < maxTries) {
        this._errorTries++;
        // We mark the track so we know something weird happened.
        this.currentTrack!.lastRatingAction = TrackAction.OTHER;
        this._chooseNextTrack(toPrevious: false);
      } else {
        this._setCurrentTrackSR(null);
      }

      return;
    }

    TrackScore? nextTrack;

    try {
      nextTrack = this._tracksPlayList.firstWhere((ts) => ts == track);
    } catch (e) {
      nextTrack = TrackScore.fromTrackInfo(
        track: track,
        scoreFactors: this._scoreFactors,
      );

      this._tracksPlayList.add(nextTrack);
    }

    this._playOrderTracker++;
    this._setCurrentTrackSR(nextTrack);
    this.currentTrack?.playOrder = this._playOrderTracker;
  }

  /// Updates [currentTrack] to the next track chosen by the recommendation algorithm.
  /// If [toPrevious] is true then the next track will be the previous one.
  void _chooseNextTrack({required bool toPrevious}) {
    if (this._tracksPlayList.length != 0) {
      if (!toPrevious) {
        this._playOrderTracker++;
        this._tracksPlayList.sort();

        TrackScore? nextTrack;
        try {
          // Find a never played before track.
          nextTrack =
              this._tracksPlayList.firstWhere((ts) => ts.playOrder == 0);
        } catch (e) {
          nextTrack = this.currentTrack;
        }

        this._setCurrentTrackSR(nextTrack);
        nextTrack?.playOrder = this._playOrderTracker;
      } else {
        if (this._playOrderTracker > 1) {
          this._playOrderTracker--;

          TrackScore? previousTrack;

          try {
            previousTrack = this
                ._tracksPlayList
                .firstWhere((ts) => ts.playOrder == this._playOrderTracker);

            this._setCurrentTrackSR(previousTrack);
          } catch (e) {
            // If this was unsuccessful we need to revert the play order to where it was.
            this._playOrderTracker++;
          }
        }
      }
    }
  }

  /// Handles what to do depending on with which [action] the user interacted with the player.
  /// If [track] is not passed or is passed as null it is assumed as the current track.
  void handleUserAction({TrackInfo? track, required TrackAction action}) {
    track = track ?? this._currentTrack;
    if (track == null || context.read<PlayerState>().isLoading) {
      return;
    }

    TrackScore? trackSR =
        (track is TrackScore) ? track : this._getTrackSRbyTrack(track);

    if (trackSR != null) {
      // UPDATING TRACK SCORE.
      //
      // We don't want to update the score of a previously rated song. In other words, the global score is only influenced by never played before songs.
      // If the song was played before, then [lastRatingAction] will be different than NONE.
      if (trackSR.lastRatingAction == TrackAction.NONE) {
        this._updateGlobalScores(track: track, action: action);

        this._tracksPlayList.forEach((ts) => ts.updateTotalScore());

        // Saving last action so we can register what the user did with this track.
        trackSR.lastRatingAction = action;

        notifyListeners();
      }

      // CHOOSING NEXT TRACK depending on the action.
      switch (action) {
        case TrackAction.PLAYED:
        case TrackAction.THUMB_DOWN:
        case TrackAction.SKIPPED_NEXT:
          this._chooseNextTrack(toPrevious: false);
          break;

        case TrackAction.SKIPPED_PREVIOUS:
          this._chooseNextTrack(toPrevious: true);
          break;

        default:
          break;
      }
    }
  }

  /// Updates the global score depending on how the user interacted with that [track] via [action].
  void _updateGlobalScores({
    required TrackInfo track,
    required TrackAction action,
  }) {
    this._scoreFactors.updateScores(
          track: track,
          score: this._calcScoreByAction(action),
        );

    // this._tracksPlayList.sort();
    // this._tracksPlayList.where((ts) => ts.score != 0).take(10).forEach((ts) =>
    //     print(_TAG + "Top 10 track with score non 0: " + ts.toString()));
  }

  /// Defines how many points to allocate depending on user interaction. F.e. If the user skipped a song we interpret he didn't liked it much so we substract points.
  int _calcScoreByAction(TrackAction action) {
    switch (action) {
      case TrackAction.PLAYED:
        return 1;

      case TrackAction.THUMB_DOWN:
      case TrackAction.SKIPPED_NEXT:
        return -2;

      case TrackAction.THUMB_UP:
        return 2;

      default:
        return 0;
    }
  }

  // Tries to finde the Track Score Record that belongs to a specific track. If can't find it it returns null.
  TrackScore? _getTrackSRbyTrack(TrackInfo track) {
    try {
      return this._tracksPlayList.firstWhere((ts) => ts == track);
    } catch (e) {
      return null;
    }
  }
}

class ScoreFactors {
  static final String _TAG = "ScoreFactors: ";
  static final ScoreFactors _instance = ScoreFactors._internal();

  ScoreFactors._internal();

  factory ScoreFactors() {
    return _instance;
  }

  final Map<String, int> _moodScores = HashMap();
  final Map<String, int> _genreScores = HashMap();
  final Map<String, int> _artistScores = HashMap();

  void updateScores({required TrackInfo track, required int score}) {
    String? mood = track.mood?.trim().toLowerCase();
    String? genre = track.genre?.trim().toLowerCase();
    String? artistId = track.artist.id.trim();

    if (mood != null && mood.isNotEmpty) {
      this
          ._moodScores
          .update(mood, (value) => value + score, ifAbsent: () => score);
    }

    if (genre != null && genre.isNotEmpty) {
      this
          ._genreScores
          .update(genre, (value) => value + score, ifAbsent: () => score);
    }

    if (artistId.isNotEmpty) {
      this
          ._artistScores
          .update(artistId, (value) => value + score, ifAbsent: () => score);
    }

    print(_TAG +
        "Scores updated:\n" +
        "$_TAG Mood: '$mood' new score: ${this.getMoodScore(mood ?? "")}\n" +
        "$_TAG Genre: '$genre' new score: ${this.getGenreScore(genre ?? "")}\n" +
        "$_TAG Artist: '$artistId' new score: ${this.getArtistScore(artistId)}\n");
  }

  int getMoodScore(String moodKey) {
    return this._moodScores[moodKey.trim().toLowerCase()] ?? 0;
  }

  int getGenreScore(String genreKey) {
    return this._genreScores[genreKey.trim().toLowerCase()] ?? 0;
  }

  /// [artistKey] is the ID of the artist.
  int getArtistScore(String artistKey) {
    return this._artistScores[artistKey.trim()] ?? 0;
  }
}
