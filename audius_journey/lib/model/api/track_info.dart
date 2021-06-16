// Copyright (c) 2021 Irian Montón Beltrán
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'package:json_annotation/json_annotation.dart';
import 'artist.dart';
import 'track_artwork.dart';

part 'track_info.g.dart';

@JsonSerializable(explicitToJson: true)
class TrackInfo {
  @JsonKey(required: false)
  final TrackArtwork? artwork;

  @JsonKey(required: false)
  final String? description;

  @JsonKey(required: false)
  final String? genre;

  final String id;

  @JsonKey(required: false)
  final String? mood;

  @JsonKey(name: "release_date", required: false)
  final String? releaseDate;

  @JsonKey(required: false)
  final String? tags;

  final String title;
  final int duration;
  @JsonKey(name: 'user')
  final Artist artist;

  TrackInfo(
    this.artwork,
    this.description,
    this.genre,
    this.id,
    this.mood,
    this.duration,
    this.releaseDate,
    this.tags,
    this.title,
    this.artist,
  );

  factory TrackInfo.fromJson(Map<String, dynamic> json) =>
      _$TrackInfoFromJson(json);

  Map<String, dynamic> toJson() => _$TrackInfoToJson(this);

  @override
  bool operator ==(dynamic other) {
    return other is TrackInfo && other.id == this.id;
  }

  // Override hashCode using strategy from recommended Dart docs.
  @override
  int get hashCode {
    int result = 17;
    result = 37 * result + this.id.hashCode;

    return result;
  }

  String getFormattedTrackDuration() {
    Duration duration = Duration(seconds: this.duration);

    return duration.inHours.toString().padLeft(2, "0") +
        ":" +
        duration.inMinutes.remainder(60).toString().padLeft(2, "0") +
        ":" +
        duration.inSeconds.remainder(60).toString().padLeft(2, "0");
  }
}
