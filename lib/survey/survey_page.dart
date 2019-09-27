import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_z/data/repositories.dart';
import 'package:project_z/models/survey.dart';
import 'package:project_z/utils/popUp.dart';

import 'survey.dart';


class SurveyPage extends StatelessWidget {
  final SurveyRepository _surveyRepository;

  SurveyPage({Key key, @required SurveyRepository surveyRepository})
      : assert(surveyRepository != null),
        _surveyRepository = surveyRepository,
        super(key: key);
        

  _handleAction(context) async {
    int count = await _surveyRepository.getSurveyCount();
    if (count < 1 || count == null) {
      var title = 'Out of Surveys!';
      var message = 'It looks like you used all your surveys. if you fell like you have reached this in error, contact support at support@surveyzulu.com';
      showAlertPopup(context, title, message);
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) {
          return AddEditScreen(surveyRepository: _surveyRepository, survey: new Survey(), isEditing: false);
        }),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: BlocProvider<SurveyBloc>(
          builder: (context) => SurveyBloc(surveyRepository: _surveyRepository),
          child: new SurveyList(surveyRepository: _surveyRepository),
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        heroTag: "addBTN",
        onPressed: () => _handleAction(context),
        tooltip: 'Add',
        child: Icon(Icons.add),
      ),
    );
  }
}