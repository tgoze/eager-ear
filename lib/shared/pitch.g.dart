// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pitch.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Pitch _$PitchFromJson(Map<String, dynamic> json) {
  return Pitch(
    pitchClass: _$enumDecodeNullable(_$PitchClassEnumMap, json['pitchClass']),
    pitchClassString: json['pitchClassString'] as String,
    octave: json['octave'] as int,
    hertz: (json['hertz'] as num)?.toDouble(),
    variance: (json['variance'] as num)?.toDouble(),
    accidental: json['accidental'] as bool,
  );
}

Map<String, dynamic> _$PitchToJson(Pitch instance) => <String, dynamic>{
      'pitchClass': _$PitchClassEnumMap[instance.pitchClass],
      'pitchClassString': instance.pitchClassString,
      'octave': instance.octave,
      'hertz': instance.hertz,
      'variance': instance.variance,
      'accidental': instance.accidental,
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

const _$PitchClassEnumMap = {
  PitchClass.C: 'C',
  PitchClass.CSharp: 'CSharp',
  PitchClass.D: 'D',
  PitchClass.DSharp: 'DSharp',
  PitchClass.E: 'E',
  PitchClass.F: 'F',
  PitchClass.FSharp: 'FSharp',
  PitchClass.G: 'G',
  PitchClass.GSharp: 'GSharp',
  PitchClass.A: 'A',
  PitchClass.ASharp: 'ASharp',
  PitchClass.B: 'B',
  PitchClass.Unknown: 'Unknown',
};
