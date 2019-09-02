import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:project_z/data/repositories.dart';
import 'package:project_z/models/survey.dart';


import '../../survey.dart';

class SurveyDetailBloc extends Bloc<SurveyDetailEvent, SurveyDetailState> {
  final SurveyRepository _surveyRepository;

    SurveyDetailBloc({@required SurveyRepository surveyRepository})
        : assert(surveyRepository != null),
          _surveyRepository = surveyRepository;

  @override
  SurveyDetailState get initialState => SurveyByIdLoading();


  @override
  Stream<SurveyDetailState> mapEventToState(SurveyDetailEvent event) async* {
    print('** Survey State Event is: $event');
    if (event is RetrieveSurveyById) {
      yield SurveyByIdLoading();
      await Future.delayed(Duration(seconds: 2));
      yield* _mapRetrieveSurveyToState(currentState, event);
    } else if (event is AddSurvey) {
      yield* _mapUpdateSurveyToState(currentState, event);
    } else if (event is UpdateNewSurvey) {
      yield* _mapUpdateSurveyToState(currentState, event);
    } 
    // else if (event is DeleteSurvey) {
    //   yield* _mapDeleteSurveyToState(currentState, event);
    // } 
  }
  

  Stream<SurveyDetailState> _mapRetrieveSurveyToState(
    SurveyDetailState currentState,
    RetrieveSurveyById event,
  ) async* {
      try {
        final id = event.id;
        final Survey survey = await _surveyRepository.getSingleSurvey(id);
        yield SurveyByIdLoadingSuccess(survey);
      } catch (error) {
        print("survey by id loading error $error");
        yield SurveyByIdLoadingError();
      }
  }


  Stream<SurveyDetailState> _mapUpdateSurveyToState(
    SurveyDetailState currentState,
    UpdateNewSurvey event,
  ) async* {
    print('** HIT _mapUpdateSurveyToState');
    print('** event is: $event');
    print('** currentState is: $currentState');
    Survey survey = await _surveyRepository.updateSurvey(event.updatedSurvey);
    // if (data) {
      yield UpdateSuccessful(survey);
    // } else {
    //   print('ERROR NO DATA FOR _MAPUPDATESURVEYTOSTATE');
    // }
    
  }
}
