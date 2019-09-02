import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:project_z/models/survey.dart';


@immutable
abstract class SurveyEvent extends Equatable {
  SurveyEvent([List props = const []]) : super(props);
}

class LoadSurvey extends SurveyEvent {
  @override
  String toString() => 'LoadSurvey';
}
class CloseSurvey extends SurveyEvent {

  final String id;

  CloseSurvey(this.id) : super([id]);

  @override
  String toString() => 'CloseSurvey { id: $id }';
}
class OpenSurvey extends SurveyEvent {

  final String id;

  OpenSurvey(this.id) : super([id]);

  @override
  String toString() => 'OpenSurvey { id: $id }';
}

class AddSurvey extends SurveyEvent {
  final Survey survey;

  AddSurvey(this.survey) : super([survey]);

  @override
  String toString() => 'AddSurvey { survey: $survey }';
}

class UpdateSurvey extends SurveyEvent {
  final Survey updatedSurvey;

  UpdateSurvey(this.updatedSurvey) : super([updatedSurvey]);

  @override
  String toString() => 'UpdateSurvey { updatedSurvey: $updatedSurvey }';
}

class DeleteSurvey extends SurveyEvent {
  final Survey survey;

  DeleteSurvey(this.survey) : super([survey]);

  @override
  String toString() => 'DeleteSurvey { survey: $survey }';
}

class Refresh extends SurveyEvent {
  @override
  String toString() => 'Refresh';
}