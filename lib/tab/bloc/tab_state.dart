import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class TabState extends Equatable {
  TabState([List props = const []]) : super(props);
}

class InitialTabState extends TabState {}
