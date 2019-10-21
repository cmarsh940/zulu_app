import 'dart:async';

import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:project_z/common/validators.dart';
import 'package:project_z/data/repositories.dart';
import 'package:rxdart/rxdart.dart';

import '../login.dart';


class LoginBloc extends Bloc<LoginEvent, LoginState> {
  ClientRepository _clientRepository;

  LoginBloc({
    @required ClientRepository clientRepository,
  })  : assert(clientRepository != null),
        _clientRepository = clientRepository;

  @override
  LoginState get initialState => LoginState.empty();

  @override
  Stream<LoginState> transformEvents(
    Stream<LoginEvent> events,
    Stream<LoginState> Function(LoginEvent event) next,
  ) {
    final observableStream = events as Observable<LoginEvent>;
    final nonDebounceStream = observableStream.where((event) {
      return (event is! EmailChanged && event is! PasswordChanged);
    });
    final debounceStream = observableStream.where((event) {
      return (event is EmailChanged || event is PasswordChanged);
    }).debounceTime(Duration(milliseconds: 300));
    return super
        .transformEvents(nonDebounceStream.mergeWith([debounceStream]), next);
  }

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if (event is EmailChanged) {
      yield* _mapEmailChangedToState(event.email);
    } else if (event is PasswordChanged) {
      yield* _mapPasswordChangedToState(event.password);
    } else if (event is LoginButtonPressed) {
      yield* _mapLoginWithCredentialsPressedToState(
        email: event.email,
        password: event.password,
      );
    }
  }

  Stream<LoginState> _mapEmailChangedToState(String email) async* {
    yield state.update(
      isEmailValid: Validators.isValidEmail(email),
    );
  }

  Stream<LoginState> _mapPasswordChangedToState(String password) async* {
    yield state.update(
      isPasswordValid: Validators.isValidPassword(password),
    );
  }

  // Stream<LoginState> _mapLoginWithGooglePressedToState() async* {
  //   try {
  //     await _userRepository.signInWithGoogle();
  //     yield LoginState.success();
  //   } catch (_) {
  //     yield LoginState.failure();
  //   }
  // }

  Stream<LoginState> _mapLoginWithCredentialsPressedToState({
    String email,
    String password,
  }) async* {
    yield LoginState.loading();
    
    var response =  await _clientRepository.authenticate(
      email: email,
      password: password,
    );

    if (response != null) {
      yield LoginState.success();
    } else {
      yield LoginState.failure();
    }
    // try {
    //   await _clientRepository.authenticate(
    //     email: email,
    //     password: password,
    //   );
    //   yield LoginState.success();
    // } catch (_) {
    //   yield LoginState.failure();
    // }
  }
}