// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrackInfo _$TrackInfoFromJson(Map<String, dynamic> json) {
  return TrackInfo(
    json['artwork'] == null
        ? null
        : TrackArtwork.fromJson(json['artwork'] as Map<String, dynamic>),
    json['description'] as String?,
    json['genre'] as String?,
    json['id'] as String,
    json['mood'] as String?,
    json['duration'] as int,
    json['release_date'] as String?,
    json['tags'] as String?,
    json['title'] as String,
    Artist.fromJson(json['user'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$TrackInfoToJson(TrackInfo instance) => <String, dynamic>{
      'artwork': instance.artwork?.toJson(),
      'description': instance.description,
      'genre': instance.genre,
      'id': instance.id,
      'mood': instance.mood,
      'release_date': instance.releaseDate,
      'tags': instance.tags,
      'title': instance.title,
      'duration': instance.duration,
      'user': instance.artist.toJson(),
    };
