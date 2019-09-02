import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:project_z/models/survey.dart';

@immutable
abstract class SurveyDetailState extends Equatable {
  SurveyDetailState([List props = const []]) : super(props);
}

class InitialSurveyDetailState extends SurveyDetailState {}


class SurveyByIdLoading extends SurveyDetailState {
  @override
  String toString() => 'SurveyByIdLoading';
}

class SurveyByIdLoadingSuccess extends SurveyDetailState {
  SurveyByIdLoadingSuccess(this.survey);

  final Survey survey;

  @override
  String toString() => 'SurveyByIdLoadingSuccess';
}
class UpdateSuccessful extends SurveyDetailState {
  UpdateSuccessful(this.survey);

  final Survey survey;

  @override
  String toString() => 'UpdateSuccessful';
}

class SurveyByIdLoadingError extends SurveyDetailState {

  @override
  String toString() => 'SurveyByIdLoadingError';
}