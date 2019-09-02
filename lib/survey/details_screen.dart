import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_z/data/repositories.dart';

import 'survey.dart';


class SurveyDetailScreen extends StatelessWidget {
  final SurveyRepository _surveyRepository;
  final String id;

  SurveyDetailScreen({Key key, this.id, @required SurveyRepository surveyRepository})
      : assert(surveyRepository != null),
        _surveyRepository = surveyRepository,
        super(key: key);
        
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: BlocProvider<SurveyDetailBloc>(
          builder: (context) => SurveyDetailBloc(surveyRepository: _surveyRepository),
          child: SurveyDetails(surveyRepository: _surveyRepository, id: id),
        ),
      ),
    );
  }
}