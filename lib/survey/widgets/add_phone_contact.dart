
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:project_z/data/repositories.dart';

import 'add_user_dialog.dart';


typedef OnSaveCallback = Function(TempUser user);

class AddPhoneContact extends StatefulWidget {
  final String id;
  final SurveyRepository surveyRepository;
  final OnSaveCallback onSave;

  const AddPhoneContact({Key key, this.id, @required SurveyRepository surveyRepository, this.onSave,
  }) : assert(surveyRepository != null),
        surveyRepository = surveyRepository, super(key: key);

  @override
  _AddPhoneContactState createState() => _AddPhoneContactState();
}

class _AddPhoneContactState extends State<AddPhoneContact> {
  Iterable<Contact> _contacts;
  String get id => widget.id;
  SurveyRepository get surveyRepository => widget.surveyRepository;
  TempUser user = new TempUser();

  @override
  initState() {
    super.initState();
    refreshContacts();
  }

  refreshContacts() async {
    // PermissionStatus permissionStsatus = await _getContactPermission();
    // if (permissionStatus == PermissionStatus.granted) {
      var contacts = await ContactsService.getContacts();
//      var contacts = await ContactsService.getContactsForPhone("8554964652");
      setState(() {
        _contacts = contacts;
      });
    // } else {
    //   _handleInvalidPermissions(permissionStatus);
    // }
  }
  
  // Future<PermissionStatus> _getContactPermission() async {
  //   PermissionStatus permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.contacts);
  //   if (permission != PermissionStatus.granted && permission != PermissionStatus.disabled) {
  //     Map<PermissionGroup, PermissionStatus> permissionStatus = await PermissionHandler().requestPermissions([PermissionGroup.contacts]);
  //     return permissionStatus[PermissionGroup.contacts] ?? PermissionStatus.unknown;
  //   } else {
  //     return permission;
  //   }
  // }

  // void _handleInvalidPermissions(PermissionStatus permissionStatus) {
  //   if (permissionStatus == PermissionStatus.denied) {
  //     throw new PlatformException(
  //         code: "PERMISSION_DENIED",
  //         message: "Access to location data denied",
  //         details: null);
  //   } else if (permissionStatus == PermissionStatus.disabled) {
  //     throw new PlatformException(
  //         code: "PERMISSION_DISABLED",
  //         message: "Location data is not available on device",
  //         details: null);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Contacts')),
      body: SafeArea(
        child: _contacts != null
            ? ListView.builder(
          itemCount: _contacts?.length ?? 0,
          itemBuilder: (BuildContext context, int index) {
            Contact c = _contacts?.elementAt(index);
            return ListTile(
              onTap: () {
                _submitContact(c);
              },
              leading: (c.avatar != null && c.avatar.length > 0)
                  ? CircleAvatar(backgroundImage: MemoryImage(c.avatar))
                  : CircleAvatar(child: Text(c.initials())),
              title: Text(c.displayName ?? ""),

            );
          },
        )
            : Center(child: CircularProgressIndicator(),),
      ),
    );
  }

  _submitContact(Contact contact) async {
    var email = contact.emails.toList();
    var newEmail = (email.isNotEmpty) ? email.elementAt(0).value : '';
    var phone = contact.phones.toList();
    var newPhone = (email.isNotEmpty) ? phone.elementAt(0).value.replaceAll(" ", "") : '';
    var tempPhone = newPhone.replaceAll("-", "");
    var temp2Phone = tempPhone.replaceAll("(", "");
    var temp3Phone = temp2Phone.replaceAll(")", "");
    var user = new TempUser(name: contact.displayName, email: newEmail, phone: temp3Phone);
    widget.onSave(user);
    Navigator.pop(context, true);
  }
}