import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:project_z/common/validators.dart';
import 'package:project_z/data/repositories.dart';
import 'package:rxdart/rxdart.dart';

import '../register.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final ClientRepository _clientRepository;

  RegisterBloc({@required ClientRepository clientRepository})
      : assert(clientRepository != null),
        _clientRepository = clientRepository;


  @override
  RegisterState get initialState => RegisterState.empty();

  // @override
  Stream<RegisterState> transformEvents(
    Stream<RegisterEvent> events,
    Stream<RegisterState> Function(RegisterEvent event) next,
  ) {
    final observableStream = events as Observable<RegisterEvent>;
    final nonDebounceStream = observableStream.where((event) {
      return (event is! EmailChanged && event is! PasswordChanged);
    });
    final debounceStream = observableStream.where((event) {
      return (event is EmailChanged || event is PasswordChanged);
    }).debounceTime(Duration(milliseconds: 300));
    return super.transformEvents(nonDebounceStream.mergeWith([debounceStream]), next);
    // return super.transform(nonDebounceStream.mergeWith([debounceStream]), next);
  }

  @override
  Stream<RegisterState> mapEventToState(
    RegisterEvent event,
  ) async* {
    if (event is EmailChanged) {
      yield* _mapEmailChangedToState(event.email);
    } else if (event is PasswordChanged) {
      yield* _mapPasswordChangedToState(event.password);
    } else if (event is ConfirmPasswordChanged) {
      yield* _mapConfirmPasswordChangedToState(event.password, event.confirmPassword);
    } else if (event is Submitted) {
      yield* _mapFormSubmittedToState(event.firstName, event.lastName, event.email, event.password);
    }
  }

  Stream<RegisterState> _mapEmailChangedToState(String email) async* {
    yield state.update(
      isEmailValid: Validators.isValidEmail(email),
    );
  }

  Stream<RegisterState> _mapPasswordChangedToState(String password) async* {
    yield state.update(
      isPasswordValid: Validators.isValidPassword(password),
    );
  }
  Stream<RegisterState> _mapConfirmPasswordChangedToState(String confirmPassword, String password) async* {
    yield state.update(
      passwordsMatch: Validators.passwordsMatch(password, confirmPassword),
    );
  }

  Stream<RegisterState> _mapFormSubmittedToState(
    String firstName,
    String lastName,
    String email,
    String password,
  ) async* {
    yield RegisterState.loading();
    var response = await _clientRepository.signUp(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
    );
    print('RESPONSE RETURNED $response');
    if (response != null) {
      yield RegisterState.success();
    } else {
      yield RegisterState.failure();
    }
  }
}
