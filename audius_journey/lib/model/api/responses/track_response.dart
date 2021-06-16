// Copyright (c) 2021 Irian Montón Beltrán
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'package:audius_journey/model/api/track_info.dart';
import 'package:json_annotation/json_annotation.dart';

part 'track_response.g.dart';

@JsonSerializable(explicitToJson: true)
class TrackResponse {
  final TrackInfo data;

  TrackResponse(this.data);

  factory TrackResponse.fromJson(Map<String, dynamic> json) =>
      _$TrackResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TrackResponseToJson(this);
}
