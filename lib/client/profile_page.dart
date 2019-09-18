import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:native_widgets/native_widgets.dart';
import 'package:project_z/auth/authentication.dart';
import 'package:project_z/client/widgets/subscriptions_dialog.dart';
import 'package:project_z/data/repositories.dart';
import 'package:project_z/models/client.dart';

import 'edit_profile_screen.dart';


class ProfilePage extends StatelessWidget {

  final ClientModel client;
  final ClientRepository clientRepository;

  ProfilePage({Key key, @required this.client, this.clientRepository}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () => BlocProvider.of<AuthenticationBloc>(context).dispatch(LoggedIn()),
          ),
        title: Text('Profile'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // Container(height: 10.0),
            // client?.picture != null ? Center(
            //   child: Container(
            //     width: 120.0,
            //     height: 120.0,
            //     decoration: BoxDecoration(
            //       color: Colors.grey[300],
            //       image: DecorationImage(
            //         image: NetworkImage(client?.picture),
            //         fit: BoxFit.cover,
            //       ),
            //       borderRadius: BorderRadius.all(Radius.circular(60.0)),
            //       border: Border.all(
            //         color: Colors.grey,
            //         width: 2.0,
            //       ),
            //     ),
            //   ),
            // ) : Container(
            //   height: 0.0,
            // ),
            ListTile(
              title: Text('First Name'),
              subtitle: client?.firstName == null ? null : Text(
                client?.firstName.toString() ?? "",
              ),
            ),
            ListTile(
              title: Text('Last Name'),
              subtitle: client?.lastName == null ? null : Text(
                client?.lastName.toString() ?? "",
              ),
            ),
            ListTile(
              title: Text('Email'),
              subtitle: client?.email == null ? null : Text(
                client?.email.toString() ?? "",
              ),
            ),
            ListTile(
              title: Text('Address'),
              subtitle: client?.address?.address == null ? null : Text(
                client?.address?.address.toString() ?? "",
              ),
            ),
            ListTile(
              title: Text('City'),
              subtitle: client?.address?.city == null ? null : Text(
                client?.address?.city.toString() ?? "",
              ),
            ),
            ListTile(
              title: Text('State'),
              subtitle:client?.address?.state == null ? null : Text(
                client?.address?.state.toString() ?? "",
              ),
            ),
            ListTile(
              title: Text('Postal Code'),
              subtitle: client?.address?.postalCode== null ? null : Text(
                client?.address?.postalCode.toString() ?? "",
              ),
            ),
            Center(child: Divider()),
            // ListTile(
            //   title: Text('Subscription'),
            //   subtitle: client?.subscription== null ? null : Text(
            //     client?.subscription.toString() ?? "",
            //   ),
            // ),
            ListTile(
              title: Text('Total Surveys'),
              subtitle: client?.surveys?.length == null ? null : Text(
                client?.surveys?.length.toString() ?? 0,
              ),
            ),
            MaterialButton(
              color: Theme.of(context).accentColor,
              child: Text(
                "Subscriptions",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) {
                  return SubscriptionDialog(id: client.id, clientRepository: clientRepository);
                }),
              ),
            ),
            MaterialButton(
              color: Theme.of(context).accentColor,
              child: Text(
                "Edit",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) {
                  return EditProfileScreen(client: client, clientRepository: clientRepository);
                }),
              ),
            )
          ],
        ),
      ),
    );
  }
}
