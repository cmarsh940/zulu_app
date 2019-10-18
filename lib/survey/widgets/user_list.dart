import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import 'package:project_z/data/repositories.dart';
import 'package:project_z/models/survey.dart';
import 'package:project_z/survey/widgets/add_phone_contact.dart';
import 'package:project_z/survey/widgets/add_user_dialog.dart';
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
  bool dialVisible = true;


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

  _sendEmail(Users user) async {
    var subject = 'Take%20our%20Survey';
    var surveyUrl = 'https://surveyzulu/pSurvey/${user.sId}/${user.sSurvey}';
    var output = 'Please%20participate%20in%20our%20survey.%20$surveyUrl';
    var url = 'mailto:${user.email}?subject=$subject&body=$output';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
  _sendSMS(Users user) async {
    var newPhone = int.parse(user.phone);
    var surveyUrl = 'https://surveyzulu/pSurvey/${user.sId}/${user.sSurvey}';
    var output = 'Please%20participate%20in%20our%20survey.%20$surveyUrl';
    var url = 'sms:$newPhone?&body=$output';
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
  } 

  _updateUser(String id, TempUser user) async {
    print('********** HIT UPDATE USER ************');
    List<Users> updatedUsers = await _surveyRepository.addUser(id: id, form: user);
    setState(() {
      users = updatedUsers;
    });
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
                (user.email != '' && !user.emailSent) ? SimpleDialogOption(
                  onPressed: () {
                    _sendEmail(user);
                  },
                  child: Text('Email Survey', style: TextStyle(color: Colors.black)),
                ) : SizedBox(
                  width: 0.0,
                  height: 0.0,
                ),
                (user.phone != '' && !user.textSent) ? SimpleDialogOption(
                  onPressed: () {
                    _sendSMS(user);
                  },
                  child: Text('Send Text', style: TextStyle(color: Colors.black)),
                ) : SizedBox(
                  width: 0.0,
                  height: 0.0,
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
              subtitle: (u.phone != '') ? Text(u.phone) : (u.email != '') ? Text(u.email) : '',
              trailing: IconButton(
                icon: Icon(Icons.more_vert),
                tooltip: 'options',
                onPressed: () async {
                  final actionName = await _asyncSimpleDialog(context, u);
                  print('dialog action name = $actionName');
                },
              ),
            );
          },
        ) : Center(child: Text('No users added'))
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
            onTap: () =>  
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) {
                  return AddUserDialog(surveyRepository: _surveyRepository, id: survey.id, onSave: (TempUser user) {
                      _updateUser(survey.id, user);
                    },
                  );
                }),
              ),
            //   _updateUser(survey.id)
            // },
            labelStyle: TextStyle(fontWeight: FontWeight.w500),
            labelBackgroundColor: Colors.greenAccent,
          ),
          SpeedDialChild(
            child: Icon(Icons.contacts, color: Colors.white),
            backgroundColor: Colors.blueAccent,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) {
                return AddPhoneContact(surveyRepository: _surveyRepository, id: survey.id, onSave: (TempUser user) {
                    _updateUser(survey.id, user);
                  },
                );
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