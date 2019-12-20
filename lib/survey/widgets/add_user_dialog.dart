import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:native_widgets/native_widgets.dart';
import 'package:project_z/data/repositories.dart';
import 'package:project_z/models/survey.dart';

typedef OnSaveCallback = Function(TempUser user);
class AddUserDialog extends StatefulWidget {
  final String id;
  final SurveyRepository surveyRepository;
  final bool isEditing;
  final Users tempUser;
  final OnSaveCallback onSave;

  const AddUserDialog({Key key, this.id, @required SurveyRepository surveyRepository, this.onSave, this.tempUser, this.isEditing,
  }) : assert(surveyRepository != null),
        surveyRepository = surveyRepository, super(key: key);

  @override
  _AddUserDialogState createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> with WidgetsBindingObserver {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  String get id => widget.id;
  bool get isEditing => widget.isEditing;
  Users get tempUser => widget.tempUser;
  SurveyRepository get surveyRepository => widget.surveyRepository;
  TempUser user = new TempUser();
  
    @override
    void initState() {
      if (isEditing) {
        user.name = tempUser.name ?? '';
        user.email = tempUser.email ?? '';
        user.phone = tempUser.phone ?? '';
      }
      super.initState();
    }
  
    @override
    void dispose() {
      super.dispose();
    }
  
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            tooltip: 'Back',
            onPressed: () => Navigator.of(context).pop()
          ),
          title: Text('Add User'),
          centerTitle: true,
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 0.0,
        ),
        body:  Padding(
          padding: EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                FormBuilder(
                  key: _fbKey,
                  autovalidate: true,
                  child: Column(
                    children: <Widget>[
                      FormBuilderTextField(
                        attribute: "name",
                        decoration: InputDecoration(labelText: "Name"),
                        initialValue: (user.name != null) ? user.name : '',
                        autofocus: true,
                        keyboardType: TextInputType.text,
                        onChanged: (value) => user.name = value,
                        validators: [
                          FormBuilderValidators.required(),
                        ],
                      ),
                      FormBuilderTextField(
                        attribute: "email",
                        decoration: InputDecoration(labelText: "Email"),
                        initialValue: (user.email != null) ? user.email : '',
                        autofocus: true,
                        onChanged: (value) => user.email = value,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      FormBuilderTextField(
                        attribute: "phone",
                        decoration: InputDecoration(labelText: "Phone"),
                        initialValue: (user.phone != null) ? user.phone : '',
                        autofocus: true,
                        onChanged: (value) => user.phone = value,
                        keyboardType: TextInputType.phone,
                      ),
                    ]
                  )
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: MaterialButton(
                          color: Theme.of(context).accentColor,
                          child: Text(
                            "Add User",
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            _fbKey.currentState.save();
                            if (_fbKey.currentState.validate()) {
                              _submitForm();
                            } else {
                              print(_fbKey.currentState.value);
                              print("validation failed");
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
   _submitForm() async {
      _fbKey.currentState.save();
      widget.onSave(user);
      Navigator.pop(context, true);
    }
  }
  
  class TempUser {
  String email;
  String name;
  String phone;

  TempUser({this.email, this.name, this.phone});

  TempUser.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    name = json['name'];
    phone = json['phone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['email'] = this.email;
    data['name'] = this.name;
    data['phone'] = this.phone;
    return data;
  }
}