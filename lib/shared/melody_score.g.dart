// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'melody_score.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MelodyScore _$MelodyScoreFromJson(Map<String, dynamic> json) {
  return MelodyScore(
    noteScores: (json['noteScores'] as List)
        ?.map((e) => (e as num)?.toDouble())
        ?.toList(),
  );
}

Map<String, dynamic> _$MelodyScoreToJson(MelodyScore instance) =>
    <String, dynamic>{
      'noteScores': instance.noteScores,
    };
