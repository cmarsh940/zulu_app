import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_z/data/repositories.dart';
import 'package:project_z/models/client.dart';


import 'edit_profile_form.dart';
import 'profile_bloc/profile.dart';


class EditProfileScreen extends StatelessWidget {
  final ClientRepository clientRepository;
  final ClientModel client;

  EditProfileScreen({Key key, @required this.clientRepository, this.client})
      : assert(clientRepository != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider<ProfileBloc>(
        builder: (context) => ProfileBloc(clientRepository: clientRepository),
        child: EditProfileForm(onSave: (ClientModel client) {
          Navigator.of(context).pop(true);
        }, client: client, clientRepository: clientRepository)
      ),
    );
  }
}