import 'dart:async';
import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:project_z/data/repositories.dart';
import 'package:project_z/models/client.dart';
import 'authentication.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
    final ClientRepository _clientRepository;

    AuthenticationBloc({@required ClientRepository clientRepository})
        : assert(clientRepository != null),
          _clientRepository = clientRepository;

    @override
    AuthenticationState get initialState => Uninitialized();

    @override
  Stream<AuthenticationState> mapEventToState(
    AuthenticationEvent event,
  ) async* {
    if (event is AppStarted) {
      yield* _mapAppStartedToState();
    } else if (event is LoggedIn) {
      yield* _mapLoggedInToState();
    } else if (event is LoggedOut) {
      yield* _mapLoggedOutToState();
    } else if (event is Profile) {
      yield* _mapProfileToState();
    }
  }

  Stream<AuthenticationState> _mapAppStartedToState() async* {
    try {
      final isSignedIn = await _clientRepository.isSignedIn();
      if (isSignedIn == null || !isSignedIn) {
        yield Unauthenticated();
      } else {
        final String id = await _clientRepository.getId();
        yield Authenticated(id);
      }
    } catch (_) {
      yield Unauthenticated();
    }
  }

  Stream<AuthenticationState> _mapLoggedInToState() async* {
    yield Authenticated(await _clientRepository.getId());
  }

  Stream<AuthenticationState> _mapLoggedOutToState() async* {
    yield Unauthenticated();
    _clientRepository.signOut();
  }

  Stream<AuthenticationState> _mapProfileToState() async* {
    try {
      final isSignedIn = await _clientRepository.isSignedIn();
      if (isSignedIn == null || !isSignedIn) {
        print('Not signed in');
        yield Unauthenticated();
      } else {
        var client = await _clientRepository.getClient();
        Map clientMap = jsonDecode(client);
        final ClientModel newClient = new ClientModel.fromJson(clientMap);
        yield ClientProfile(newClient);
      }
    } catch (_) {
      yield Unauthenticated();
    }
  }
}