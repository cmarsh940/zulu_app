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
    if (event is RetrieveSurveyById) {
      yield SurveyByIdLoading();
      await Future.delayed(Duration(seconds: 2));
      yield* _mapRetrieveSurveyToState(event);
    } else if (event is AddSurvey) {
      yield* _mapUpdateSurveyToState(event);
    } else if (event is UpdateNewSurvey) {
      yield* _mapUpdateSurveyToState(event);
    } 
    // else if (event is DeleteSurvey) {
    //   yield* _mapDeleteSurveyToState(currentState, event);
    // } 
  }
  

  Stream<SurveyDetailState> _mapRetrieveSurveyToState(
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
    UpdateNewSurvey event,
  ) async* {
    Survey survey = await _surveyRepository.updateSurvey(event.updatedSurvey);
    // if (data) {
      yield UpdateSuccessful(survey);
    // } else {
    //   print('ERROR NO DATA FOR _MAPUPDATESURVEYTOSTATE');
    // }
    
  }
}
