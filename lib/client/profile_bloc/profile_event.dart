import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:project_z/models/client.dart';

@immutable
abstract class ProfileEvent extends Equatable {
  ProfileEvent([List props = const []]) : super(props);
}

class SubmissionProfileButtonPressed extends ProfileEvent {
  final ClientModel client;

  SubmissionProfileButtonPressed({
    @required this.client,
  }) : super([client]);

  @override
  String toString() =>
      'SubmissionProfileButtonPressed { client: $client}';
}

class SubmittedProfile extends ProfileEvent {
  final ClientModel client;

  SubmittedProfile({@required this.client})
      : super([client]);

  @override
  String toString() {
    return 'Submitted { client: $client }';
  }
}
