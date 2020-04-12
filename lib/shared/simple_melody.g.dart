// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'simple_melody.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SimpleMelody _$SimpleMelodyFromJson(Map<String, dynamic> json) {
  return SimpleMelody(
    title: json['title'] as String,
    notes: (json['notes'] as List)
        ?.map(
            (e) => e == null ? null : Note.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$SimpleMelodyToJson(SimpleMelody instance) =>
    <String, dynamic>{
      'title': instance.title,
      'notes': instance.notes?.map((e) => e?.toJson())?.toList(),
    };
