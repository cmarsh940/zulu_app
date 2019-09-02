import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:project_z/auth/authentication.dart';
import 'package:project_z/data/repositories.dart';
import 'package:project_z/utils/popUp.dart';


import '../login.dart';
import 'login_button.dart';

FacebookLogin _facebookLogin = FacebookLogin();

GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['profile', 'email']);
class LoginForm extends StatefulWidget {
  final ClientRepository _clientRepository;

  LoginForm({Key key, @required ClientRepository clientRepository})
      : assert(clientRepository != null),
        _clientRepository = clientRepository,
        super(key: key);


  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  int rebuild;

  LoginBloc _loginBloc;

  ClientRepository get _clientRepository => widget._clientRepository;

  bool get isPopulated =>
      _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;

  bool isLoginButtonEnabled(LoginState state) {
    return state.isFormValid && isPopulated && !state.isSubmitting;
  }

  @override
  void initState() {
    super.initState();
    rebuild = 0;
    _loginBloc = BlocProvider.of<LoginBloc>(context);
    _emailController.addListener(_onEmailChanged);
    _passwordController.addListener(_onPasswordChanged);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      bloc: _loginBloc,
      listener: (BuildContext context, LoginState state) {
        if (state.isFailure) {
          Scaffold.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text('Login Failure'), Icon(Icons.error)],
                ),
                backgroundColor: Colors.red,
              ),
            );
        }
        if (state.isSubmitting) {
          Scaffold.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Logging In...'),
                    CircularProgressIndicator(),
                  ],
                ),
              ),
            );
        }
        if (state.isSuccess) {
          BlocProvider.of<AuthenticationBloc>(context).dispatch(LoggedIn());
        }
      },
      child: BlocBuilder(
        bloc: _loginBloc,
        builder: (BuildContext context, LoginState state) {
          return Center(
            child: Container(
              width: 400,
              padding: EdgeInsets.all(20.0),
              child: Form(
                child: ListView(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Image.asset('assets/images/splashLogo.png', height: 300),
                    ),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        icon: Icon(Icons.email),
                        labelText: 'Email',
                      ),
                      autovalidate: true,
                      autocorrect: false,
                      validator: (_) {
                        return !state.isEmailValid ? 'Invalid Email' : null;
                      },
                    ),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        icon: Icon(Icons.lock),
                        labelText: 'Password',
                      ),
                      obscureText: true,
                      autovalidate: true,
                      autocorrect: false,
                      validator: (_) {
                        return !state.isPasswordValid ? 'Invalid Password' : null;
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text('*Note: You must already have an account to login. If you do not have a account please sign up at surveyzulu.com', style: TextStyle(color: Colors.red, fontSize: 12)),
                          ),
                          LoginButton(
                            onPressed: isLoginButtonEnabled(state)
                                ? _onFormSubmitted
                                : null,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              IconButton(
                                icon: Image.asset(
                                  'assets/icons/loginWithGoogle.png',
                                ),
                                iconSize: 60,
                                onPressed: () {
                                  _handleGoogleSignIn();
                                },
                              ),
                              IconButton(
                                icon: Image.asset(
                                  'assets/icons/loginWithFacebook.png',
                                ),
                                iconSize: 60,
                                onPressed: () {
                                  _handleFacebookSignIn();
                                },
                              )
                            ],
                          )
                          // CreateAccountButton(clientRepository: _clientRepository),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onEmailChanged() {
    _loginBloc.dispatch(
      EmailChanged(email: _emailController.text),
    );
  }

  void _onPasswordChanged() {
    _loginBloc.dispatch(
      PasswordChanged(password: _passwordController.text),
    );
  }

  void _onFormSubmitted() {
    _loginBloc.dispatch(
      LoginButtonPressed(
        email: _emailController.text,
        password: _passwordController.text,
      ),
    );
  }
  Future<void> _handleGoogleSignIn() async {
    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn().catchError((onError) {
        print("Error $onError");
      });
      print('##### GOOGLE ###### $googleUser');
      if (googleUser == null) {
        var title = 'Google Signin Error';
        var message = 'There was a problem signing into goolgle.';
        showAlertPopup(context, title, message);
      } else {
        var email = _googleSignIn.currentUser.email;
        var password = 'Google' + _googleSignIn.currentUser.id;
        _loginBloc.dispatch(
          LoginButtonPressed(
            email: email,
            password: password,
          ),
        );
      }
    } catch (error) {
      print('google signin error');
      var title = 'Google Signin Error';
      var message = error;
      showAlertPopup(context, title, message);
    }
  }
  Future<void> _handleFacebookSignIn() async {
    String email;
    String id;
    final results = await _facebookLogin.logInWithReadPermissions(['email']);
    switch (results.status) {
      case FacebookLoginStatus.loggedIn:
        final token = results.accessToken.token;
        final graphResponse = await http.get('https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=$token');
        Map profile = json.decode(graphResponse.body);
        for (var i = 0; i < profile.length; i++) {
          var a = profile.entries.elementAt(i);
          print(a);
          if (a.key == 'email') {
            email = a.value;
          } 
          else if (a.key == 'id') {
            id = a.value.toString();
          }
        }
        var password = 'Facebook' + id;
        _loginBloc.dispatch(
          LoginButtonPressed(
            email: email,
            password: password,
          ),
        );
        break;
      case FacebookLoginStatus.cancelledByUser :
        var title = 'Facebook Signin Error';
        var message = 'There was a problem signing in with Facebook.';
        showAlertPopup(context, title, message);
        break;

      case FacebookLoginStatus.error :
        print('FACEBOOK LOGIN ERROR');
        var title = 'Facebook Signin Error';
        var message = 'There was a problem signing in with Facebook.';
        showAlertPopup(context, title, message);
        setState(() {
          rebuild += 1;
        });
        
        break;
    }
    
  }
}