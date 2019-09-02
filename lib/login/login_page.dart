import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_z/data/repositories.dart';

import 'login.dart';



class LoginPage extends StatelessWidget {
  final ClientRepository clientRepository;

  LoginPage({Key key, @required this.clientRepository})
      : assert(clientRepository != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: BlocProvider<LoginBloc>(
        builder: (context) => LoginBloc(clientRepository: clientRepository),
        child: LoginForm(clientRepository: clientRepository),
      ),
    );
  }
}