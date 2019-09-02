import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_z/data/repositories.dart';
import 'package:project_z/tab/tab_screen.dart';

import '../survey.dart';



class SurveyDetails extends StatefulWidget {
  final SurveyRepository _surveyRepository;
  final String id;

  SurveyDetails({Key key, this.id, @required SurveyRepository surveyRepository})
      : assert(surveyRepository != null),
        _surveyRepository = surveyRepository,
        super(key: key);

  _SurveyDetailsState createState() => _SurveyDetailsState();
}

class _SurveyDetailsState extends State<SurveyDetails> {
  SurveyDetailBloc _surveyDetailBloc;
  SurveyRepository get _surveyRepository => widget._surveyRepository;
  String id;

  @override
  void initState() {
    id = widget.id;
    print('initial id is: $id');
    _surveyDetailBloc = SurveyDetailBloc(surveyRepository: _surveyRepository)..dispatch(RetrieveSurveyById(id));
    super.initState();
  }

  @override
  void dispose() { 
    _surveyDetailBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      bloc: _surveyDetailBloc,
      listener: (context, state) {
        if (state is UpdateSuccessful) {
          print('survey detail page update successful');
          Navigator.push(context,
            MaterialPageRoute(
              builder: (context) => SurveyList(surveyRepository: _surveyRepository),
            ),
          );
        }
      },
      child: BlocBuilder(
        bloc: _surveyDetailBloc,
        // ignore: missing_return
        builder: (context, state) {
          if (state is SurveyByIdLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is SurveyByIdLoadingError) {
            print(" **** No Survey found ****");
            return Text(
              'Something went wrong!',
              style: TextStyle(color: Colors.red),
            );
          } else if (state is SurveyByIdLoadingSuccess) {
            print('survey details loaded successfully');
            final survey = state.survey;
            return TabScreen(survey, _surveyRepository);
          } else if (state is UpdateSuccessful) {
            print('**********   STATE IS UPDATE SUCCESSFUL  **********');
          }
        }
      )
    );
  }
}