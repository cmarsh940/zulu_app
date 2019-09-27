import 'dart:async';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:project_z/data/repositories.dart';
import 'package:project_z/models/client.dart';
import 'profile.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ClientRepository _clientRepository;

  ProfileBloc({
    @required ClientRepository clientRepository,
  })  : assert(clientRepository != null),
        _clientRepository = clientRepository;

  @override
  ProfileState get initialState => ProfileState.empty();


  @override
  Stream<ProfileState> mapEventToState(ProfileEvent event) async* {
    if (event is SubmissionProfileButtonPressed) {
      yield* _mapSubmissionPressedToState(
        client: event.client
      );
    }
  }


  Stream<ProfileState> _mapSubmissionPressedToState({
    ClientModel client
  }) async* {
    yield ProfileState.loading();
    try {
      await _clientRepository.updateClient(client);
      yield ProfileState.success();
    } catch (_) {
      yield ProfileState.failure();
    }
  }
}
