import 'package:flutter/material.dart';
import 'package:project_z/data/repositories.dart';
import 'package:project_z/register/register.dart';



class CreateAccountButton extends StatelessWidget {
  final ClientRepository _clientRepository;

  CreateAccountButton({Key key, @required ClientRepository clientRepository})
      : assert(clientRepository != null),
        _clientRepository = clientRepository,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: Text(
        'Create an Account',
      ),
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) {
            return RegisterPage(clientRepository: _clientRepository);
          }),
        );
      },
    );
  }
}