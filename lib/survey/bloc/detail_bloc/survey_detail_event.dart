import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:project_z/models/survey.dart';

@immutable
abstract class SurveyDetailEvent extends Equatable {
  SurveyDetailEvent([List props = const []]) : super(props);
}


class RetrieveSurveyById extends SurveyDetailEvent {
  final String id;

  RetrieveSurveyById(this.id);

  @override
  String toString() => 'RetrieveSurveyById';
}

class UpdateNewSurvey extends SurveyDetailEvent {
  final Survey updatedSurvey;

  UpdateNewSurvey(this.updatedSurvey) : super([updatedSurvey]);

  @override
  String toString() => 'UpdateNewSurvey { updatedSurvey: $updatedSurvey }';
}