import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:project_z/models/survey.dart';

@immutable
abstract class AddUpdateEvent extends Equatable {
  AddUpdateEvent([List props = const []]) : super(props);
}

class SubmissionButtonPressed extends AddUpdateEvent {
  final Survey survey;

  SubmissionButtonPressed({
    @required this.survey,
  }) : super([survey]);

  @override
  String toString() =>
      'SubmissionButtonPressed { survey: $survey}';
}
class AddButtonPressed extends AddUpdateEvent {
  final dynamic survey;

  AddButtonPressed(this.survey) : super([survey]);

  @override
  String toString() =>
      'AddButtonPressed { survey: $survey}';
}

class SubmittedSurvey extends AddUpdateEvent {
  final Survey survey;

  SubmittedSurvey({@required this.survey})
      : super([survey]);

  @override
  String toString() {
    return 'Submitted { survey: $survey }';
  }
}