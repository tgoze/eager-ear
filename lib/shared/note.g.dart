// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Note _$NoteFromJson(Map<String, dynamic> json) {
  return Note(
    pitch: json['pitch'] == null
        ? null
        : Pitch.fromJson(json['pitch'] as Map<String, dynamic>),
    duration: _$enumDecodeNullable(_$PitchDurationEnumMap, json['duration']),
  );
}

Map<String, dynamic> _$NoteToJson(Note instance) => <String, dynamic>{
      'pitch': instance.pitch,
      'duration': _$PitchDurationEnumMap[instance.duration],
    };

T _$enumDecode<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }

  final value = enumValues.entries
      .singleWhere((e) => e.value == source, orElse: () => null)
      ?.key;

  if (value == null && unknownValue == null) {
    throw ArgumentError('`$source` is not one of the supported values: '
        '${enumValues.values.join(', ')}');
  }
  return value ?? unknownValue;
}

T _$enumDecodeNullable<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source, unknownValue: unknownValue);
}

const _$PitchDurationEnumMap = {
  PitchDuration.Whole: 'Whole',
  PitchDuration.Quarter: 'Quarter',
  PitchDuration.Eighth: 'Eighth',
  PitchDuration.Unknown: 'Unknown',
};
