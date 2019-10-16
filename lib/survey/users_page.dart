import 'package:flutter/material.dart';

import 'package:project_z/data/repositories.dart';
import 'package:project_z/models/survey.dart';
import 'package:project_z/survey/widgets/add_phone_contact.dart';
import 'package:project_z/survey/widgets/add_user_dialog.dart';
import 'package:project_z/survey/widgets/user_list.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

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
      floatingActionButton: SpeedDial(
        heroTag: "addUser",
        tooltip: 'Add User',
        animatedIcon: AnimatedIcons.menu_close,
        animatedIconTheme: IconThemeData(size: 22.0),
        // child: Icon(Icons.add),
        onOpen: () => print('OPENING DIAL'),
        onClose: () => print('DIAL CLOSED'),
        visible: dialVisible,
        curve: Curves.bounceIn,
        children: [
          SpeedDialChild(
            label: 'New User',
            child: Icon(Icons.person_add, color: Colors.white),
            backgroundColor: Colors.greenAccent,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) {
                return AddUserDialog(surveyRepository: _surveyRepository, id: survey.id);
              }),
            ),
            labelStyle: TextStyle(fontWeight: FontWeight.w500),
            labelBackgroundColor: Colors.greenAccent,
          ),
          SpeedDialChild(
            child: Icon(Icons.contacts, color: Colors.white),
            backgroundColor: Colors.blueAccent,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) {
                return AddPhoneContact(surveyRepository: _surveyRepository, id: survey.id);
              }),
            ),
            label: 'Add Contact',
            labelStyle: TextStyle(fontWeight: FontWeight.w500),
            labelBackgroundColor: Colors.blueAccent,
          ),
        ],
      )
    );
  }
}