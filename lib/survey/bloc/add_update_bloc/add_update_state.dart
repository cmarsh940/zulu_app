import 'package:meta/meta.dart';

@immutable
class AddUpdateState {
  final bool isSubmitting;
  final bool isSuccess;
  final bool isFailure;


  AddUpdateState({
    @required this.isSubmitting,
    @required this.isSuccess,
    @required this.isFailure,
  });

  factory AddUpdateState.empty() {
    return AddUpdateState(
      isSubmitting: false,
      isSuccess: false,
      isFailure: false,
    );
  }

  factory AddUpdateState.loading() {
    return AddUpdateState(
      isSubmitting: true,
      isSuccess: false,
      isFailure: false,
    );
  }

  factory AddUpdateState.failure() {
    return AddUpdateState(
      isSubmitting: false,
      isSuccess: false,
      isFailure: true,
    );
  }

  factory AddUpdateState.success() {
    return AddUpdateState(
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

  AddUpdateState copyWith({
    bool isSubmitEnabled,
    bool isSubmitting,
    bool isSuccess,
    bool isFailure,
  }) {
    return AddUpdateState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      isFailure: isFailure ?? this.isFailure,
    );
  }

  @override
  String toString() {
    return '''AddUpdateState {
      isSubmitting: $isSubmitting,
      isSuccess: $isSuccess,
      isFailure: $isFailure,
    }''';
  }
}
  
