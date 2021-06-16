// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trending_tracks_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrendingTracksResponse _$TrendingTracksResponseFromJson(
    Map<String, dynamic> json) {
  return TrendingTracksResponse(
    (json['data'] as List<dynamic>)
        .map((e) => TrackInfo.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$TrendingTracksResponseToJson(
        TrendingTracksResponse instance) =>
    <String, dynamic>{
      'data': instance.data.map((e) => e.toJson()).toList(),
    };
