import 'package:json_annotation/json_annotation.dart';

part 'melody_score.g.dart';

@JsonSerializable()
class MelodyScore {
  List<double> noteScores;

  MelodyScore({this.noteScores});

  MelodyScore.fromMaxScore(int melodyLength, double maxScore) {
    noteScores = List<double>(melodyLength);
    this.noteScores.fillRange(0, noteScores.length, maxScore / melodyLength);
  }

  double getScore() {
    var totalScore = 0.0;
    if (noteScores != null)
      totalScore = noteScores.reduce((previous, next) => previous + next);
    return totalScore;
  }

  factory MelodyScore.fromJson(Map<String, dynamic> json) =>
      _$MelodyScoreFromJson(json);

  Map<String, dynamic> toJson() => _$MelodyScoreToJson(this);
}