import 'package:meta/meta.dart';

@immutable
class ProfileState {
  final bool isSubmitting;
  final bool isSuccess;
  final bool isFailure;


  ProfileState({
    @required this.isSubmitting,
    @required this.isSuccess,
    @required this.isFailure,
  });

  factory ProfileState.empty() {
    return ProfileState(
      isSubmitting: false,
      isSuccess: false,
      isFailure: false,
    );
  }

  factory ProfileState.loading() {
    return ProfileState(
      isSubmitting: true,
      isSuccess: false,
      isFailure: false,
    );
  }

  factory ProfileState.failure() {
    return ProfileState(
      isSubmitting: false,
      isSuccess: false,
      isFailure: true,
    );
  }

  factory ProfileState.success() {
    return ProfileState(
      isSubmitting: false,
      isSuccess: true,
      isFailure: false,
    );
  }

  // LoginState update({
  //   bool isEmailValid,
  //   bool isPasswordValid,
  // }) {
  //   return copyWith(
  //     isEmailValid: isEmailValid,
  //     isPasswordValid: isPasswordValid,
  //     isSubmitting: false,
  //     isSuccess: false,
  //     isFailure: false,
  //   );
  // }

  ProfileState copyWith({
    bool isSubmitEnabled,
    bool isSubmitting,
    bool isSuccess,
    bool isFailure,
  }) {
    return ProfileState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      isFailure: isFailure ?? this.isFailure,
    );
  }

  @override
  String toString() {
    return '''ProfileState {
      isSubmitting: $isSubmitting,
      isSuccess: $isSuccess,
      isFailure: $isFailure,
    }''';
  }
}