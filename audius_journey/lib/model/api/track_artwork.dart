// Copyright (c) 2021 Irian Montón Beltrán
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'package:json_annotation/json_annotation.dart';

part 'track_artwork.g.dart';

@JsonSerializable()
class TrackArtwork {
  // 150x150 pixels
  @JsonKey(name: "150x150")
  final String smallResolution;
  // 480x480 pixels
  @JsonKey(name: "480x480")
  final String mediumResolution;
  // 1000x1000 pixels
  @JsonKey(name: "1000x1000")
  final String bigResolution;

  factory TrackArtwork.fromBaseUrl(String baseURL) {
    baseURL = baseURL.trim();

    if (!baseURL.endsWith("/")) {
      baseURL += "/";
    }

    return TrackArtwork(
      baseURL + "150x150.jpg",
      baseURL + "480x480.jpg",
      baseURL + "1000x1000.jpg",
    );
  }

  TrackArtwork(this.smallResolution, this.mediumResolution, this.bigResolution);

  factory TrackArtwork.fromJson(Map<String, dynamic> json) =>
      _$TrackArtworkFromJson(json);

  Map<String, dynamic> toJson() => _$TrackArtworkToJson(this);
}
