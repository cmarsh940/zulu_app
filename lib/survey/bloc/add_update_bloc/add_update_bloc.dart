import 'dart:async';

import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:project_z/data/repositories.dart';
import 'package:project_z/models/survey.dart';


import '../../survey.dart';

class AddUpdateBloc extends Bloc<AddUpdateEvent, AddUpdateState> {
  final SurveyRepository _surveyRepository;

  AddUpdateBloc({
    @required SurveyRepository surveyRepository,
  })  : assert(surveyRepository != null),
        _surveyRepository = surveyRepository;

  @override
  AddUpdateState get initialState => AddUpdateState.empty();


  @override
  Stream<AddUpdateState> mapEventToState(AddUpdateEvent event) async* {
    if (event is AddButtonPressed) {
      yield* _mapAddPressedToState(
        survey: event.survey      );
    }
    else if (event is SubmissionButtonPressed) {
      yield* _mapSubmissionPressedToState(
        survey: event.survey
      );
    }
  }


  Stream<AddUpdateState> _mapSubmissionPressedToState({
    Survey survey
  }) async* {
    yield AddUpdateState.loading();
    try {
      await _surveyRepository.updateSurvey(survey);
      yield AddUpdateState.success();
    } catch (_) {
      yield AddUpdateState.failure();
    }
  }
  Stream<AddUpdateState> _mapAddPressedToState({
    dynamic survey,
  }) async* {
    yield AddUpdateState.loading();
    try {
      await _surveyRepository.addSurvey(survey);
      yield AddUpdateState.success();
    } catch (_) {
      yield AddUpdateState.failure();
    }
  }
}