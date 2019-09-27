import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:project_z/data/repositories.dart';
import 'package:project_z/models/survey.dart';

import '../survey.dart';

class SurveyBloc extends Bloc<SurveyEvent, SurveyState> {
  final SurveyRepository _surveyRepository;

    SurveyBloc({@required SurveyRepository surveyRepository})
        : assert(surveyRepository != null),
          _surveyRepository = surveyRepository;

  @override
  SurveyState get initialState => SurveyLoading();

  @override
  Stream<SurveyState> mapEventToState(SurveyEvent event) async* {
    if (event is LoadSurvey) {
      yield* _mapLoadSurveyToState();
    } else if (event is CloseSurvey) {
      yield* _mapCloseSurveyToState(currentState, event);
    } else if (event is OpenSurvey) {
      yield* _mapOpenSurveyToState(currentState, event);
    } else if (event is AddSurvey) {
      yield* _mapAddSurveyToState(currentState, event);
    } else if (event is UpdateSurvey) {
      yield* _mapUpdateSurveyToState(currentState, event);
    } else if (event is DeleteSurvey) {
      yield* _mapDeleteSurveyToState(currentState, event);
    } else if (event is Refresh) {
      yield* _mapLoadSurveyToState();
    }
  }

  Stream<SurveyState> _mapLoadSurveyToState() async* {
    try {
      var survey = await _surveyRepository.loadSurvey();
      var categories = await _surveyRepository.loadCategories(); 
      if (survey == null) {
        print('**** ERROR SURVEY RETURNED NULL');
        yield SurveyNotLoaded();
      } else {
        List responseJson = json.decode(survey);
        var newSurvey = responseJson.map((m) => new Survey.fromJson(m)).toList();
        yield SurveyLoaded(
          newSurvey
        );
      }
    } catch (_) {
      yield SurveyNotLoaded();
    }
  }

  Stream<SurveyState> _mapCloseSurveyToState(
    SurveyState currentState,
    CloseSurvey event,
  ) async* {
    try {
        final id = event.id;
        final bool data = await _surveyRepository.closeSurvey(id);
        if( data == true) {
//          _mapLoadSurveyToState();
           yield SurveyClosedSuccess(data);
        } else {
          // _mapLoadSurveyToState();
          yield SurveyNotLoaded();
        }
    } catch (_) {
      yield SurveyNotLoaded();
    }
  }
  Stream<SurveyState> _mapOpenSurveyToState(
    SurveyState currentState,
    OpenSurvey event,
  ) async* {
    try {
        final id = event.id;
        final bool data = await _surveyRepository.openSurvey(id);
        if( data == true) {
          yield SurveyOpenedSuccess(data);
        } else {
          yield SurveyNotLoaded();
        }
    } catch (_) {
      yield SurveyNotLoaded();
    }
  }

  Stream<SurveyState> _mapAddSurveyToState(
    SurveyState currentState,
    AddSurvey event,
  ) async* {
    if (currentState is SurveyLoaded) {
      final List<Survey> updatedSurvey = List.from(currentState.survey)
        ..add(event.survey);
      yield SurveyLoaded(updatedSurvey);
      _saveSurvey(updatedSurvey);
    }
  }

  Stream<SurveyState> _mapUpdateSurveyToState(
    SurveyState currentState,
    UpdateSurvey event,
  ) async* {
    if (currentState is SurveyLoaded) {
      final List<Survey> updatedSurvey = currentState.survey.map((survey) {
        return survey.id == event.updatedSurvey.id ? event.updatedSurvey : survey;
      }).toList();
      yield SurveyLoaded(updatedSurvey);
      _saveSurvey(updatedSurvey);
    }
  }

  Stream<SurveyState> _mapDeleteSurveyToState(
    SurveyState currentState,
    DeleteSurvey event,
  ) async* {
    if (currentState is SurveyLoaded) {
      final updatedSurvey =
          currentState.survey.where((survey) => survey.id != event.survey.id).toList();
      yield SurveyLoaded(updatedSurvey);
      _saveSurvey(updatedSurvey);
    }
  }


  Future _saveSurvey(List<Survey> surveys) {
    return _surveyRepository.saveSurvey(
      surveys.toList(),
    );
  }
}