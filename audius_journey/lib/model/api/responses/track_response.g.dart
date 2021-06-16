// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrackResponse _$TrackResponseFromJson(Map<String, dynamic> json) {
  return TrackResponse(
    TrackInfo.fromJson(json['data'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$TrackResponseToJson(TrackResponse instance) =>
    <String, dynamic>{
      'data': instance.data.toJson(),
    };
