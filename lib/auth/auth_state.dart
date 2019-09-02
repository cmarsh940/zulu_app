import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class AuthenticationState extends Equatable {
  AuthenticationState([List props = const []]) : super(props);
}

class Uninitialized extends AuthenticationState {
  @override
  String toString() => 'Uninitialized';
}

class Authenticated extends AuthenticationState {
  final String id;

  Authenticated(this.id) : super([id]);

  @override
  String toString() => 'Authenticated { client: $id }';
}

class Unauthenticated extends AuthenticationState {
  @override
  String toString() => 'Unauthenticated';
}

class Loading extends AuthenticationState {
  @override
  String toString() => 'AuthenticationLoading';
}

class ClientProfile extends AuthenticationState {
  final client;

  ClientProfile(this.client) : super([client]);

  @override
  String toString() => 'ClientProfile { client: $client }';
}