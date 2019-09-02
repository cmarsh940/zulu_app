import 'dart:async';
import 'package:bloc/bloc.dart';

import '../tab.dart';

class TabBloc extends Bloc<TabEvent, TabState> {
  @override
  TabState get initialState => InitialTabState();

  @override
  Stream<TabState> mapEventToState(TabEvent event) async* {
    // if (event is UpdateTab) {
    //   yield event.tab;
    // }
  }
}
