import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_z/auth/authentication.dart';
import 'package:project_z/common/common.dart';
import 'package:project_z/data/repositories.dart';
import 'package:project_z/models/survey.dart';
import 'package:project_z/survey/users_page.dart';
import 'package:project_z/survey/widgets/incentive_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_share_plugin/social_share_plugin.dart';
import 'package:url_launcher/url_launcher.dart';

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
  File _image;
  String sub;

  @override
  void initState() {
    getSub();
    rebuilt = 0;
    _surveyBloc = SurveyBloc(surveyRepository: _surveyRepository)..add(LoadSurvey());
    super.initState();
    _refreshCompleter = Completer<void>();
  }

  @override
  void dispose() { 
    _surveyBloc.close();
    super.dispose();
  }

  getSub() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    sub = pref.getString("_subscription");
  }

  _launchTermsURL() async {
    const url = 'https://surveyzulu.com/policies/terms';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _launchPrivacyURL() async {
    const url = 'https://surveyzulu.com/policies/usage';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future getImage(String id) async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    var name = 'picture';

    if (image == null) {
      Navigator.pop(context);
    } else {
      setState(() {
        _image = image;
      });
      
      await _surveyRepository.uploadLogo(id, _image, name);
      Navigator.pop(context);
    }
  }
  
 
Future<String> _asyncSimpleDialog(BuildContext context, String id, bool active, String logo, Survey survey) async {
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
                  child: Text('Share by email'),
                  onPressed: () async {
                    final Uri params = Uri(
                      scheme: 'mailto',
                      path: '',
                      query: 'subject=Take%20our%20Survey&body=Please%20participate%20in%20our%20survey.%0ahttps://surveyzulu.com/takeSurvey/$id',
                    );

                    var url = params.toString();
                    if (await canLaunch(url)) {
                      await launch(url);
                    } else {
                      print('Could not launch $url');
                    }
                  },
                ),
                SimpleDialogOption(
                  child: Text('Share by text'),
                  onPressed: () async {
                    if(Platform.isAndroid){
                        //FOR Android
                        String url ='sms:?body=Please%20participate%20in%20our%20survey.%0ahttps://surveyzulu.com/takeSurvey/$id';
                        await launch(url);
                    } 
                    else if(Platform.isIOS){
                        //FOR IOS
                        String url ='sms:&body=Please%20participate%20in%20our%20survey.%0ahttps://surveyzulu.com/takeSurvey/$id';
                        await launch(url);
                    }
                  },
                ),
                SimpleDialogOption(
                  child: Text('Share to Facebook'),
                  onPressed: () async {
                    String url = 'https://surveyzulu.com/takeSurvey/$id';
                    final result = await SocialSharePlugin.shareToFeedFacebookLink(
                      url: url,
                      onSuccess: (_) {
                        print('FACEBOOK SUCCESS');
                        return;
                      },
                      onCancel: () {
                        print('FACEBOOK CANCELLED');
                        return;
                      },
                      onError: (error) {
                        print('FACEBOOK ERROR $error');
                        return;
                      },
                    );

                    print(result);
                  },
                ),
                SimpleDialogOption(
                  child: Text('Share to Twitter'),
                  onPressed: () async {
                    String url = 'https://surveyzulu.com/takeSurvey/$id';
                    final text =
                        'Please participate in our survey';
                    final result = await SocialSharePlugin.shareToTwitterLink(
                        text: text,
                        url: url,
                        onSuccess: (_) {
                          print('TWITTER SUCCESS');
                          return;
                        },
                        onCancel: () {
                          print('TWITTER CANCELLED');
                          return;
                        });
                    print(result);
                  },
                ),
                (sub.toLowerCase() != 'free' || sub.toLowerCase() != 'trial') ? SimpleDialogOption(
                  onPressed: () {
                    getImage(id);
                  },
                  child: (logo == '') ? Text('Add logo') : Text('Change logo'),
                ) : SizedBox(),
                (sub.toLowerCase() != 'free' || sub.toLowerCase() != 'trial') ? SimpleDialogOption(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) {
                      return IncentiveDialog(id: id, surveyRepository: _surveyRepository, survey: survey);
                    }),
                  ),
                  child: Text('Add survey incentive'),
                ) : SizedBox(width: 0.0, height: 0.0),
                (survey.private) ? SimpleDialogOption(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) {
                      return UsersPage(surveyRepository: _surveyRepository, survey: survey);
                    }),
                  ),
                  child: Text('Manage users'),
                ) : SizedBox(
                  width: 0.0,
                  height: 0.0,
                ),
                (!active) ? SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context, 'open');
                  },
                  child: !active ? Text('Open survey', style: TextStyle(color: Theme.of(context).accentColor)) : SizedBox(
                    width: 0.0, height: 0.0),
                ) : SizedBox(width: 0.0, height: 0.0),
                (active) ? SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context, 'close');
                  },
                  child: active ? Text('Close survey', style: TextStyle(color: Colors.red)) : SizedBox(
                    width: 0.0, height: 0.0),
                ) : SizedBox(width: 0.0, height: 0.0),
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: double.infinity,
                  child: FlatButton.icon(
                    icon: Icon(Icons.person), //`Icon` to display
                    label: Text('Profile', 
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                      ),
                    ),
                    onPressed: () {
                      BlocProvider.of<AuthenticationBloc>(context).add(
                        Profile(),
                      );
                      Navigator.pop(context);
                    },
                  ),
                ),
                Container(
                  width: double.infinity,
                  child: FlatButton.icon(
                    icon: Icon(Icons.info), //`Icon` to display
                    label: Text('Terms of Use', 
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                      ),
                    ),
                    onPressed: () {
                      _launchTermsURL();
                    },
                  ),
                ),
                Container(
                  width: double.infinity,
                  child: FlatButton.icon(
                    icon: Icon(Icons.info), //`Icon` to display
                    label: Text('Privacy Policy', 
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                      ),
                    ),
                    onPressed: () {
                      _launchPrivacyURL();
                    },
                  ),
                ),
                Container(
                  width: double.infinity,
                  child: FlatButton.icon(
                    icon: Icon(Icons.exit_to_app), //`Icon` to display
                    label: Text('Logout', 
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                      ),
                    ),
                    onPressed: () {
                      BlocProvider.of<AuthenticationBloc>(context).add(
                        LoggedOut(),
                      );
                      Navigator.pop(context);
                    },
                  ),
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
            return SplashPage();
          } else if (state is SurveyNotLoaded) {
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
                        _surveyBloc.add(
                          Refresh(),
                        );
                        setState(() {
                          rebuilt += 1;
                        });
                        Completer<Null> completer = new Completer<Null>();
                        new Future.delayed(new Duration(seconds: 2)).then((_){
                          completer.complete();
                        });
                        return completer.future;
                      },
                      child: (survey.length < 1) ? Text(
                            'No Surveys',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontWeight: FontWeight.w500),
                        ) : ListView.separated(
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
                                final actionName = await _asyncSimpleDialog(context, surveys.id, surveys.active, surveys.logo, surveys );
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
    _surveyBloc.add(CloseSurvey(id));
  }

  void _openSurvey(String id) {
    _surveyBloc.add(OpenSurvey(id));
  }
  
}
