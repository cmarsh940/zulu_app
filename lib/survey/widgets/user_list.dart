import 'package:flutter/material.dart';

import 'package:project_z/data/repositories.dart';
import 'package:project_z/models/survey.dart';
import 'package:url_launcher/url_launcher.dart';



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

  _launchTermsURL(Users user) async {
    var url = 'https://surveyzulu.com/pSurvey/${user.sId}/${survey.id}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _removeUser(String id) async {
    List<Users> updatedUsers = await _surveyRepository.removeUser(id: id);
    print('response is: $updatedUsers');
    setState(() {
      users = updatedUsers;
    });
    Navigator.pop(context);
  }
  
  Future<String> _asyncSimpleDialog(BuildContext context, Users user) async {
  return await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('Survey Action', style: TextStyle(decoration: TextDecoration.underline), textAlign: TextAlign.center),
          children: <Widget>[
            Column(
              children: <Widget>[
                SimpleDialogOption(
                  onPressed: () {
                    _launchTermsURL(user);
                  },
                  child: Text('Take Survey', style: TextStyle(color: Colors.black)),
                ),
                SimpleDialogOption(
                  onPressed: () {
                    _removeUser(user.sId);
                    // Navigator.pop(context, 'close');
                  },
                  child: Text('Remove User', style: TextStyle(color: Colors.red)),
                ),
                SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel', style: TextStyle(color: Colors.black)),
                ),
              ]
            )
          ],
        );
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
              leading: Icon(Icons.person_outline),
              title: Text(u.name ?? ""),
              subtitle: Text(u.phone ?? ""),
              trailing: IconButton(
                icon: Icon(Icons.more_vert),
                tooltip: 'options',
                onPressed: () async {
                  final actionName = await _asyncSimpleDialog(context, u);
                  
                },
              ),
            );
          },
        ) : Center(child: Text('No users added'))
      ),
    );
  }
}