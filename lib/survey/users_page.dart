import 'package:flutter/material.dart';

import 'package:project_z/data/repositories.dart';
import 'package:project_z/models/survey.dart';
import 'package:project_z/survey/widgets/user_list.dart';

class UsersPage extends StatelessWidget {
  final SurveyRepository _surveyRepository;
  final Survey survey;
  final bool dialVisible = true;

  UsersPage({Key key, @required SurveyRepository surveyRepository, this.survey})
      : assert(surveyRepository != null),
        _surveyRepository = surveyRepository,
        super(key: key);



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: UserList(surveyRepository: _surveyRepository, survey: survey),
      ),
    );
  }
}