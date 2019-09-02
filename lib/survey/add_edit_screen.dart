import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_z/data/repositories.dart';
import 'package:project_z/models/survey.dart';

import 'survey.dart';



class AddEditScreen extends StatelessWidget {
  final SurveyRepository surveyRepository;
  final Survey survey;
  final bool isEditing;
  final List categories;

  AddEditScreen({Key key, @required this.surveyRepository, this.survey, this.isEditing, this.categories})
      : assert(surveyRepository != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider<AddUpdateBloc>(
        builder: (context) => AddUpdateBloc(surveyRepository: surveyRepository),
        child: isEditing ? EditSurveyForm(isEditing: true, onSave: (Survey survey) {
          Navigator.of(context).pop(true);
        }, survey: survey, surveyRepository: surveyRepository, editCategories: categories) : AddSurveyForm(isEditing: false, onSave: (Survey survey) {
          Navigator.of(context).pop(true);
        }, survey: survey, surveyRepository: surveyRepository),
      ),
    );
  }
}