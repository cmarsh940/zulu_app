import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';

import 'data/client_repository.dart';
import 'auth/authentication.dart';
import 'login/login.dart';
import 'common/common.dart';
import 'utils/bloc_delegate.dart';
import 'client/client.dart';
import 'data/repositories.dart';
import 'survey/survey.dart';



void main() {
  // DEBUG VISUALS
  // debugPaintSizeEnabled=true;
  BlocSupervisor.delegate = SimpleBlocDelegate();
  final clientRepository = ClientRepository(
    api: Api(
      httpClient: http.Client(),
    ),
  );
  final surveyRepository = SurveyRepository(
    api: Api(
      httpClient: http.Client(),
    ),
  );
  runApp(
    BlocProvider<AuthenticationBloc>(
      builder: (context) {
        return AuthenticationBloc(clientRepository: clientRepository)
          ..add(AppStarted());
      },
      child: App(clientRepository: clientRepository, surveyRepository: surveyRepository),
    ),
  );
}

class App extends StatelessWidget {
  final ClientRepository clientRepository;
  final SurveyRepository surveyRepository;

  App({
    Key key, 
    @required this.clientRepository,
    @required this.surveyRepository,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        bloc: BlocProvider.of<AuthenticationBloc>(context),
        // ignore: missing_return
        builder: (BuildContext context, AuthenticationState state) {
          if (state is Uninitialized) {
            print('uninitialized');
            return SplashPage();
          }
          if (state is Authenticated) {
            print('authenticated');
            return SurveyPage(surveyRepository: surveyRepository);
          }
          if (state is Unauthenticated) {
            print('unauthenticated');
            return LoginPage(clientRepository: clientRepository);
          }
          if (state is Loading) {
            print('loading');
            return LoadingIndicator();
          }
          if (state is ClientProfile) {
            print('profile');
            return ProfilePage(client: state.client, clientRepository: clientRepository);
          }
        },
      ),
      
    );
  }
}