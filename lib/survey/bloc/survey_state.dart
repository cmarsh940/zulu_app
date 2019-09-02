import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:project_z/models/survey.dart';

@immutable
abstract class SurveyState extends Equatable {
  SurveyState([List props = const []]) : super(props);
}

class SurveyUninitialized extends SurveyState {
  @override
  String toString() => 'Uninitialized';
}


class SurveyLoading extends SurveyState {
  @override
  String toString() => 'SurveyLoading';
}

class SurveyLoaded extends SurveyState {
  final List<Survey> survey;

  SurveyLoaded([this.survey = const []]) : super([survey]);

  @override
  String toString() => 'SurveyLoaded { survey: $survey }';
}

class SurveyNotLoaded extends SurveyState {
  @override
  String toString() => 'SurveyNotLoaded';
}

class SurveyClosedSuccess extends SurveyState {
  SurveyClosedSuccess(this.data);

  final data;

  @override
  String toString() => 'SurveyClosedSuccess { data: $data }';
}
class SurveyOpenedSuccess extends SurveyState {
  SurveyOpenedSuccess(this.data);

  final data;

  @override
  String toString() => 'SurveyOpenedSuccess { id: $data }';
}