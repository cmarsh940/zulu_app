import 'package:flutter/material.dart';

import 'package:project_z/data/repositories.dart';
import 'package:project_z/models/survey.dart';



class UserList extends StatefulWidget {
  final SurveyRepository _surveyRepository;
  final Survey survey;
  

  UserList({Key key, @required SurveyRepository surveyRepository, this.survey})
      : assert(surveyRepository != null),
        _surveyRepository = surveyRepository,
        super(key: key);

  _UserListState createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  SurveyRepository get _surveyRepository => widget._surveyRepository;
  Survey get survey => widget.survey;
  Iterable<Users> users;


  @override
  initState() {
    print(survey.name);
    print(survey.users);
    setUsers();
    super.initState();
  }

  setUsers() {
    setState(() {
      if (survey.users == null) {
        users = [];
      } else {
        users = survey.users;
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User List')),
      body: SafeArea(
        child: (users.length != 0) ? ListView.builder(
          itemCount: users?.length ?? 0,
          itemBuilder: (BuildContext context, int index) {
            Users u = users?.elementAt(index);
            return ListTile(
              onTap: () {
                print(u.name);
                // Navigator.of(context).push(MaterialPageRoute(
                //     builder: (BuildContext context) =>
                //         ContactDetailsPage(c)));
              },
              title: Text(u.name ?? ""),

              );
            },
          ) : Center(child: Text('No users added'))
        ),
      );
  }
}