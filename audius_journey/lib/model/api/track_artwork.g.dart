// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track_artwork.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrackArtwork _$TrackArtworkFromJson(Map<String, dynamic> json) {
  return TrackArtwork(
    json['150x150'] as String,
    json['480x480'] as String,
    json['1000x1000'] as String,
  );
}

Map<String, dynamic> _$TrackArtworkToJson(TrackArtwork instance) =>
    <String, dynamic>{
      '150x150': instance.smallResolution,
      '480x480': instance.mediumResolution,
      '1000x1000': instance.bigResolution,
    };
