import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_z/auth/authentication.dart';
import 'package:project_z/common/common.dart';
import 'package:project_z/data/repositories.dart';
import 'package:project_z/models/survey.dart';

import '../survey.dart';


class SurveyList extends StatefulWidget {
  final SurveyRepository _surveyRepository;

  SurveyList({Key key, @required SurveyRepository surveyRepository})
      : assert(surveyRepository != null),
        _surveyRepository = surveyRepository,
        super(key: key);

  _SurveyListState createState() => _SurveyListState();
}

class _SurveyListState extends State<SurveyList> {
  SurveyBloc _surveyBloc;
  SurveyRepository get _surveyRepository => widget._surveyRepository;
  Completer<void> _refreshCompleter;
  int rebuilt;

  @override
  void initState() {
    rebuilt = 0;
    _surveyBloc = SurveyBloc(surveyRepository: _surveyRepository)..dispatch(LoadSurvey());
    super.initState();
    _refreshCompleter = Completer<void>();
  }

  @override
  void dispose() { 
    _surveyBloc.dispose();
    super.dispose();
  }


  
 
Future<String> _asyncSimpleDialog(BuildContext context, bool active) async {
  return await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('Survey Action', style: TextStyle(decoration: TextDecoration.underline), textAlign: TextAlign.center),
          children: <Widget>[
            Column(
              children: <Widget>[
                SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context, 'open');
                  },
                  child: !active ? Text('Open', style: TextStyle(color: Theme.of(context).accentColor)) : SizedBox(),
                ),
                SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context, 'close');
                  },
                  child: active ? Text('Close', style: TextStyle(color: Colors.red)) : SizedBox(),
                ),
                SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel', style: TextStyle(color: Colors.black)),
                ),
              ]
            )
          ],
        );
      });
}
Future _settingsDialog(BuildContext context) async {
  return await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('Settings', style: TextStyle(decoration: TextDecoration.underline), textAlign: TextAlign.center),
          children: <Widget>[
            Column(
              children: <Widget>[
                FlatButton(
                  child: Text(
                    "Profile",
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                    ),
                  ),
                  onPressed: () {
                    BlocProvider.of<AuthenticationBloc>(context).dispatch(
                      Profile(),
                    );
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  child: Text(
                    "logout",
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                    ),
                  ),
                  onPressed: () {
                    BlocProvider.of<AuthenticationBloc>(context).dispatch(
                      LoggedOut(),
                    );
                    Navigator.pop(context);
                  },
                ),
              ]
            )
          ],
        );
      });
}

  @override
  Widget build(BuildContext context) {
    return BlocListener( 
      bloc: _surveyBloc,  
       // ignore: missing_return       
      listener: (context, state) {
        if (state is SurveyLoaded) {
          _refreshCompleter?.complete();
          _refreshCompleter = new Completer();
        }
        if (state is SurveyClosedSuccess) {
          Scaffold.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Survey Closed...'),
                  ],
                ),
                backgroundColor: Colors.redAccent,
              ),
            );
        }
        if (state is SurveyOpenedSuccess) {
          Scaffold.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Survey Opened...'),
                  ],
                ),
                backgroundColor: Theme.of(context).accentColor,
              ),
            );
        }
      },
      child: BlocBuilder(
        bloc: _surveyBloc,
        // ignore: missing_return
        builder: (context, state) {
          if (state is SurveyUninitialized) {
            print('state is uninitialized in survey list');
            return SplashPage();
          } else if (state is SurveyNotLoaded) {
            print("No Surveys found");
            return Scaffold(
              appBar: AppBar(
                title: Text('No Surveys Found!'),
                backgroundColor: Colors.red,
                elevation: 0.0,
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.settings),
                    tooltip: 'Options',
                    onPressed: () {
                      _settingsDialog(context);
                    },
                  ),    
                ]
              ),
                    
            );
          } else if (state is SurveyLoading) {
            return LoadingIndicator();
          } else if (state is SurveyOpenedSuccess) {
            return new SurveyPage(surveyRepository: _surveyRepository);
          } else if (state is SurveyClosedSuccess) {
            return new SurveyPage(surveyRepository: _surveyRepository);
          }  else if (state is SurveyLoaded) {
            List<Survey> survey = state.survey;
            return Scaffold(
              body: Column(
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      Container(
                        height: MediaQuery.of(context).size.height * 0.15,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color.fromRGBO(21, 102, 182, 1),
                                Color.fromRGBO(24, 115, 205, 1),
                                Color.fromRGBO(27, 127, 228, 1),
                              ],
                            ),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(30),
                              bottomRight: Radius.circular(30),
                            )),
                      ),
                      AppBar(
                        backgroundColor: Colors.transparent,
                        elevation: 0.0,
                        actions: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: IconButton(
                              icon: Icon(Icons.person_outline),
                              tooltip: 'Settings',
                              onPressed: () {
                                _settingsDialog(context);
                              },
                            ),
                          ),    
                        ]
                      ),
                      Positioned(
                        top: MediaQuery.of(context).size.height * 0.07,
                        left: 20,
                        right: MediaQuery.of(context).size.width * 0.3,
                        child: Text(
                          "Your Surveys",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                          ),
                        ),
                      )
                    ],
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () {
                        _surveyBloc.dispatch(
                          Refresh(),
                        );
                        setState(() {
                          rebuilt += 1;
                        });
                        print('rebuilt $rebuilt times');
                        Completer<Null> completer = new Completer<Null>();
                        new Future.delayed(new Duration(seconds: 2)).then((_){
                          completer.complete();
                        });
                        return completer.future;
                      },
                      child: ListView.separated(
                        itemCount: survey.length,
                        itemBuilder: (context, i) {
                          Survey surveys = survey[i];
                          return ListTile(
                            leading: Text('${i+1} )', textAlign: TextAlign.justify, textScaleFactor: 1.3,),
                            enabled: surveys.active,
                            title: Text(
                              '${surveys.name}',
                              textAlign: TextAlign.left,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontWeight: FontWeight.w400),
                            ),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) {
                                return SurveyDetailScreen(id: surveys.id, surveyRepository: _surveyRepository);
                              }),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.more_vert),
                              tooltip: 'options',
                              onPressed: () async {
                                final actionName = await _asyncSimpleDialog(context, surveys.active);
                                print("Selected Action is $actionName");
                                if (actionName == 'close') {
                                    _closeSurvey(surveys.id);
                                }
                                if (actionName == 'open') {
                                    _openSurvey(surveys.id);
                                }
                              },
                            ),
                          );
                        },
                        separatorBuilder: (BuildContext context, index) {
                          return Divider(
                            height: 8.0,
                            color: Color.fromRGBO(21, 102, 182, 1),
                          );
                        },
                      ),
                    ),
                  )
                ],
              ),
            );
          }
        }
      )
    );
  }

  void _closeSurvey(String id) {
    _surveyBloc.dispatch(CloseSurvey(id));
  }

  void _openSurvey(String id) {
    _surveyBloc.dispatch(OpenSurvey(id));
  }
}
