import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_z/data/repositories.dart';

import 'register.dart';



class RegisterPage extends StatelessWidget {
  final ClientRepository _clientRepository;

  RegisterPage({Key key, @required ClientRepository clientRepository})
      : assert(clientRepository != null),
        _clientRepository = clientRepository,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Center(
        child: BlocProvider<RegisterBloc>(
          builder: (context) => RegisterBloc(clientRepository: _clientRepository),
          child: RegisterForm(),
        ),
      ),
    );
  }
}