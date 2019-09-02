import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_z/auth/authentication.dart';

import '../constants.dart';


class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AuthenticationBloc authenticationBloc =
        BlocProvider.of<AuthenticationBloc>(context);
    return Drawer(
      child: SafeArea(
        // color: Colors.grey[50],
        child: ListView(
          children: <Widget>[
            // ListTile(
            //   leading: Icon(Icons.account_circle),
            //   title: Text(
            //     _auth.client.firstname + " " + _auth.client.lastname,
            //     textScaleFactor: textScaleFactor,
            //     maxLines: 1,
            //   ),
            //   subtitle: Text(
            //     _auth.client.status.toString(),
            //     textScaleFactor: textScaleFactor,
            //     maxLines: 1,
            //   ),
            //   onTap: () {
            //     Navigator.of(context).popAndPushNamed("/profile");
            //   },
            // ),   
            ListTile(
              leading: Icon(Icons.format_list_bulleted),
              title: Text(
                'Surveys',
                textScaleFactor: textScaleFactor,
              ),
              onTap: () {
                print('need to navigate to survey list');
                // Navigator.of(context).push(
                //   MaterialPageRoute(builder: (context) {
                //     return SurveyList();
                //   }),
                // );
              },
            ),
            Divider(),

            ListTile(
              leading: Icon(Icons.settings),
              title: Text(
                'Settings',
                textScaleFactor: textScaleFactor,
              ),
              onTap: () {
                Navigator.of(context).popAndPushNamed("/settings");
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.arrow_back),
              title: Text(
                'Logout',
                textScaleFactor: textScaleFactor,
              ),
              onTap: () { 
                Navigator.pop(context, true);
                authenticationBloc.dispatch(LoggedOut());
              },
            ),
          ],
        ),
      ),
    );
  }
}
