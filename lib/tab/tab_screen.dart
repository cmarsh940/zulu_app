import 'package:flutter/material.dart';
import 'package:project_z/data/repositories.dart';
import 'package:project_z/models/survey.dart';
import 'package:project_z/survey/survey.dart';


class TabScreen extends StatefulWidget {
  final Survey survey;
  final SurveyRepository _surveyRepository;
  

  TabScreen(this.survey, this._surveyRepository);

  @override
  _TabScreenState createState() => _TabScreenState();
}

class _TabScreenState extends State<TabScreen> with SingleTickerProviderStateMixin{
  Survey survey;
  TabController controller;
  SurveyRepository get _surveyRepository => widget._surveyRepository;
  List _categories = [''];

  @override
  void initState() {
    getCategories();
    survey = widget.survey;
    controller = new TabController(vsync: this, length: 2);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void getCategories() async {
    List categories = await _surveyRepository.getCategories();
    
    categories.forEach((f) => _categories.add(f));
  }
  


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new TabBarView(
        controller: controller,
        children: <Widget>[
          new DetailsWidget(survey),
          new AddEditScreen(survey: survey, surveyRepository: _surveyRepository, isEditing: true, categories: _categories)
        ],
      ),
      bottomNavigationBar: new Material(
        color: Color.fromRGBO(21, 102, 182, 1),
        child: new TabBar(
          controller: controller,
          tabs: <Tab>[
            new Tab(icon: new Icon(Icons.dashboard)),
            new Tab(icon: new Icon(Icons.edit)),
          ]
        )
      ),
      
    );
  }
}