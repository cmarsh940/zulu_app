import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:project_z/auth/authentication.dart';
import 'package:project_z/data/repositories.dart';
import 'package:project_z/utils/jwt-payload-parse.dart';
import 'package:project_z/utils/popUp.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:apple_sign_in/apple_sign_in.dart';

import '../../constants.dart';
import '../login.dart';
import 'create_account_button.dart';
import 'login_button.dart';

const APP_ID = "<Put in your Device ID>";

// FacebookLogin _facebookLogin = FacebookLogin();

 GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['profile', 'email']);
class LoginForm extends StatefulWidget {
  final ClientRepository clientRepository;

  LoginForm({Key key, @required ClientRepository clientRepository})
      : assert(clientRepository != null),
        clientRepository = clientRepository,
        super(key: key);


  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  int rebuild;
  static final FacebookLogin facebookSignIn = new FacebookLogin();

  LoginBloc _loginBloc;

  ClientRepository get clientRepository => widget.clientRepository;

  bool get isPopulated =>
      _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;

  bool isLoginButtonEnabled(LoginState state) {
    return state.isFormValid && isPopulated && !state.isSubmitting;
  }

  static final MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    testDevices: APP_ID != null ? [APP_ID] : null,
    keywords: ['Business', 'Surveys', 'Polls', 'Small Business'],
  );

  BannerAd bannerAd;


  BannerAd buildBanner() {
    return BannerAd(
        adUnitId: Platform.isIOS? iosAds : androidAds,
        size: AdSize.smartBanner,
        targetingInfo: targetingInfo,
        listener: (MobileAdEvent event) {
          print(event);
        });
  }

  @override
  void initState() {
    super.initState();
    rebuild = 0;
    _loginBloc = BlocProvider.of<LoginBloc>(context);
    _emailController.addListener(_onEmailChanged);
    _passwordController.addListener(_onPasswordChanged);

    FirebaseAdMob.instance.initialize(appId: Platform.isIOS ? iosId : androidId);
    bannerAd = buildBanner()..load();

    AppleSignIn.onCredentialRevoked.listen((_) {
      print("Credentials revoked");
    });
  }

  @override
  Widget build(BuildContext context) {
    bannerAd..show();
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
          BlocProvider.of<AuthenticationBloc>(context).add(LoggedIn());
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
                      child: Image.asset('assets/images/splashLogo.png', height: 200),
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
                          ),
                          LoginButton(
                            onPressed: isLoginButtonEnabled(state)
                                ? _onFormSubmitted
                                : null,
                          ),
                          (Platform.isIOS) ? 
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                AppleSignInButton(
                                  onPressed: () {
                                    _handleAppleSignIn();
                                  },
                                ),
                              ]
                            ) : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                              ]
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
                          ),
                          CreateAccountButton(clientRepository: clientRepository),
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
    bannerAd?.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onEmailChanged() {
    _loginBloc.add(
      EmailChanged(email: _emailController.text),
    );
  }

  void _onPasswordChanged() {
    _loginBloc.add(
      PasswordChanged(password: _passwordController.text),
    );
  }

  void _onFormSubmitted() {
    _loginBloc.add(
      LoginButtonPressed(
        email: _emailController.text,
        password: _passwordController.text,
      ),
    );
  }

  Future<void> _handleAppleSignIn() async {
    final AuthorizationResult result = await AppleSignIn.performRequests([
      AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
    ]);

    if (result.status == AuthorizationStatus.authorized) {
      var appleUser = parseJwt(utf8.decode(result.credential.identityToken));
      var firstName = result.credential.fullName.givenName;
      var lastName = result.credential.fullName.familyName;
      var email = (result.credential.email == null) ? appleUser['email'] : result.credential.email;
      var password = (result.credential.email == null) ? 'Apple' + appleUser['email'] : 'Apple' + result.credential.email;
        
      _loginBloc.add(
        AppleLoginButtonPressed(
          email: email,
          password: password,
          firstName: firstName,
          lastName: lastName
        ),
      );
    } else {
      var title = 'Apple Signin Error';
      var message = 'There was a problem signing with apple.';
      showAlertPopup(context, title, message);
    }
  }

   Future<void> _handleGoogleSignIn() async {
     try {
       final GoogleSignInAccount googleUser = await _googleSignIn.signIn().catchError((onError) {
         print("Error $onError");
       });
       if (googleUser == null) {
         var title = 'Google Signin Error';
         var message = 'There was a problem signing into google.';
         showAlertPopup(context, title, message);
       } else {
         var name = _googleSignIn.currentUser.displayName.split(' ');
         var firstName = name[0];
         var lastName = name[1];
         var email = _googleSignIn.currentUser.email;
         var password = 'Google' + _googleSignIn.currentUser.id;
         _loginBloc.add(
           GoogleLoginButtonPressed(
             email: email,
             password: password,
             firstName: firstName,
             lastName: lastName
           ),
         );
       }
     } catch (error) {
       var title = 'Google Signin Error';
       var message = error;
       showAlertPopup(context, title, message);
     }
   }

  Future<void> _handleFacebookSignIn() async {
    String email;
    String id;
    String firstName;
    String lastName;

    final FacebookLoginResult result =
        await facebookSignIn.logIn(['email']);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final FacebookAccessToken accessToken = result.accessToken;
        final token = accessToken.token;
        final graphResponse = await http.get('https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=$token');
        Map profile = json.decode(graphResponse.body);
        for (var i = 0; i < profile.length; i++) {
          var a = profile.entries.elementAt(i);
          if (a.key == 'email') {
            email = a.value;
          }
          else if (a.key == 'id') {
            id = a.value.toString();
          }
          else if (a.key == 'first_name') {
            firstName = a.value.toString();
          }
          else if (a.key == 'last_name') {
            lastName = a.value.toString();
          }
        }
        var password = 'Facebook' + id;
        _loginBloc.add(
          FacebookLoginButtonPressed(
            email: email,
            password: password,
            firstName: firstName,
            lastName: lastName,
          ),
        );
        break;

      case FacebookLoginStatus.cancelledByUser:
        var title = 'Facebook Signin Cancelled';
        var message = 'Cacelled signing into facebook';
        showAlertPopup(context, title, message);
        break;

      case FacebookLoginStatus.error:
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