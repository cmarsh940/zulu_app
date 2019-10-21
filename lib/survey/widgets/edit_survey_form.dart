import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:project_z/data/repositories.dart';
import 'package:project_z/models/survey.dart';

import '../survey.dart';




typedef OnSaveCallback = Function(Survey survey);

class EditSurveyForm extends StatefulWidget {
  final bool isEditing;
  final OnSaveCallback onSave;
  final Survey survey;
  final List editCategories;
  final SurveyRepository _surveyRepository;

  EditSurveyForm({
    Key key,
    @required this.onSave,
    @required this.isEditing,
    this.survey, @required SurveyRepository surveyRepository, this.editCategories
  }) : assert(surveyRepository != null),
        _surveyRepository = surveyRepository, super(key: key);

  @override
  _EditSurveyFormState createState() => _EditSurveyFormState();
}

class _EditSurveyFormState extends State<EditSurveyForm> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  AddUpdateBloc _addUpdateBloc;
  Survey get survey => widget.survey;
  bool get isEditing => widget.isEditing;
  List get editCategories => widget.editCategories;
  SurveyRepository get _surveyRepository => widget._surveyRepository;
  List<String> _layouts = <String>['', 'PAGE', 'STEPS'];
  List<Map<String, String>> _qTypes = [
    {"value": "goodbad", "viewValue": "Good / Bad"},
    {"value": "likeunlike", "viewValue": "Like / Unlike"},
    {"value": "boolean", "viewValue": "True / False"},
    {"value": "yesno", "viewValue": "YES / NO"},
    {"value": "moreless", "viewValue": "More / Less"},
    {"value": "date", "viewValue": "Date Calendar"},
    {"value": "dateStartEnd", "viewValue": "Date Calendar (Min-Max date range)"},
    {"value": "dateWeekday", "viewValue": "Weekday Calendar (Monday-Friday)"},
    {"value": "dropDown", "viewValue": "Drop Down (Single answer)"},
    {"value": "dropDownMultiple", "viewValue": "Drop Down (Multiple answer)"},
    {"value": "multiplechoice", "viewValue": "Multiple Choice (Single answer)"},
    {"value": "rate", "viewValue": "Slide Rating (1-5)"},
    {"value": "star", "viewValue": "Star Rating"},
    {"value": "likelyUnlikely", "viewValue": "Likely or Unlikely 1-10"},
    {"value": "howoften", "viewValue": "How often"},
    {"value": "moresameless", "viewValue": "More-Same-Less"},
    {"value": "smilieFaces", "viewValue": "Satisfaction (images)"},
    {"value": "satisfaction", "viewValue": "Satisfaction (text)"},
    {"value": "slide", "viewValue": "Sliding scale (1-100)"},
    {"value": "text", "viewValue": "Single Answer Responce"},
    {"value": "paragraph", "viewValue": "User Feedback"}
  ];
  bool rebuild; 
  String  _subscription;
  

  @override
  void initState() {
    super.initState();
    getSubscription();
    _addUpdateBloc = BlocProvider.of<AddUpdateBloc>(context);
    rebuild = false;
  }

  @override
  void dispose() { 
    _addUpdateBloc.close();
    super.dispose();
  }

  void getSubscription() async {
    String subscription = await _surveyRepository.getSubscription();
    setState(() {
      _subscription = subscription;
    });
  }
    
  @override
  Widget build(BuildContext context) {
    return BlocListener(
      bloc: _addUpdateBloc,
      listener: (BuildContext context, AddUpdateState state) {
        if (state.isFailure) {
          Scaffold.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text('Failure'), Icon(Icons.error)],
                ),
                backgroundColor: Colors.red,
              ),
            );
        }
        if (state.isSubmitting) {
          Scaffold.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Submitting...'),
                    CircularProgressIndicator(),
                  ],
                ),
              ),
            );
        }
        if (state.isSuccess) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) {
              return SurveyPage(surveyRepository: _surveyRepository);
            })
          );
        }
      },
      child: BlocBuilder(
        bloc: _addUpdateBloc,
        builder: (BuildContext context, AddUpdateState state) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Edit Survey',
              ),
            ),
            body: Padding(
              padding: EdgeInsets.all(10),
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    FormBuilder(
                      key: _fbKey,
                      autovalidate: true,
                      child: Column(
                        children: <Widget>[
                          FormBuilderTextField(
                            attribute: "name",
                            decoration: InputDecoration(labelText: "Name"),
                            initialValue: survey?.name,
                            onChanged: (value) => survey?.name = value,
                            validators: [
                              FormBuilderValidators.required(),
                            ],
                          ),
                          FormBuilderDropdown(
                            attribute: "layout",
                            decoration: InputDecoration(labelText: "Survey Layout"),
                            initialValue: isEditing ? survey?.layout : '',
                            hint: Text('Select Layout'),
                            validators: [FormBuilderValidators.required()],
                            items: _layouts.map((layout) => DropdownMenuItem(
                              value: layout,
                              child: Text('$layout'),
                            )).toList(),
                            onChanged: (value) => survey?.layout = value,
                          ),
                          FormBuilderDropdown(
                            attribute: "category",
                            decoration: InputDecoration(labelText: "Survey Category"),
                            initialValue: survey?.category ?? '',
                            hint: Text('Select Category'),
                            // validators: [FormBuilderValidators.required()],
                            items: editCategories.map((category) => DropdownMenuItem(
                              value: category,
                              child: Text('$category'),
                            )).toList(),
                            onChanged: (value) => survey?.category = value,
                          ),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: ClampingScrollPhysics(),
                            itemCount: survey?.questions?.length ?? 0,
                            itemBuilder: (context, i) {
                              return new Card(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    ListTile(
                                      title: Text("Question ${i+1}"),
                                      trailing: IconButton(
                                        icon: Icon(Icons.close),
                                        tooltip: 'Remove question',
                                        onPressed: () {
                                          setState(() {
                                            survey.questions.remove(survey.questions[i]);
                                          });
                                        },
                                      ),
                                    ),
                                    FormBuilderDropdown(
                                      attribute: "$i",
                                      decoration: InputDecoration(labelText: "Question ${i+1}"),
                                      initialValue: isEditing ? survey.questions[i].questionType : '',
                                      hint: Text('Select Question Type'),
                                      // validators: [FormBuilderValidators.required()],
                                      items: _qTypes.map((Map q) => DropdownMenuItem(
                                        value: q['value'],
                                        child: Text('${q['viewValue']}'),
                                      )).toList(),
                                      onChanged: (value) => survey.questions[i].questionType = value,
                                    ),
                                    FormBuilderTextField(
                                      attribute: "question$i",
                                      decoration: InputDecoration(labelText: "Question"),
                                      initialValue: survey.questions[i].question,
                                      onChanged: (value) => survey.questions[i].question = value,
                                    ),

                                    Center(
                                      child: (survey.questions[i].questionType == 'dateStartEnd')
                                      ? ListView(
                                        key: Key('options'),
                                        shrinkWrap: true,
                                        physics: ClampingScrollPhysics(),
                                        children: <Widget>[
                                          Card(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                ListTile(
                                                  title:Text("Start Date"),
                                                  subtitle: (survey.questions[i].options != null && survey.questions[i].options.length > 1) ? Text('${survey.questions[i]?.options[0].optionName}') : Text('Select a Date'),
                                                ),
                                                ListTile(
                                                  title:Text("End Date"),
                                                  subtitle:(survey.questions[i].options != null && survey.questions[i].options.length == 2) ? Text('${survey.questions[i].options[1].optionName}') : Text('Select a Date'),
                                                ),
                                              ]
                                            )
                                          ),
                                          (survey.questions[i].options == null || survey.questions[i].options.length <= 1) ? RaisedButton(onPressed: () async {
                                            var start = await showDatePicker(
                                              context: context,
                                              initialDate: DateTime.now(),
                                              firstDate: DateTime(2018),
                                              lastDate: DateTime(2030),
                                              builder: (BuildContext context, Widget child) {
                                                return Theme(
                                                  data: ThemeData.dark(),
                                                  child: child,
                                                );
                                              },
                                            );
                                            setState(() {
                                              if (survey.questions[i].options == null) {
                                                survey.questions[i].options = [];
                                                survey.questions[i].options.add(new Options(optionName: start.toString()));
                                              } else {
                                                survey.questions[i].options.add(new Options(optionName: start.toString()));
                                              }
                                            });
                                          },child: Text('Start Date')) : SizedBox(),
                                          (survey.questions[i].options != null && survey.questions[i].options.length >= 1 && survey.questions[i].options.length < 3) ? RaisedButton(onPressed: () async {
                                            var start = await showDatePicker(
                                              context: context,
                                              initialDate: DateTime.now(),
                                              firstDate: DateTime(2018),
                                              lastDate: DateTime(2030),
                                              builder: (BuildContext context, Widget child) {
                                                return Theme(
                                                  data: ThemeData.dark(),
                                                  child: child,
                                                );
                                              },
                                            );
                                            setState(() {
                                              if (survey.questions[i].options == null) {
                                                survey.questions[i].options = [];
                                                survey.questions[i].options.add(new Options(optionName: start.toString()));
                                              } else {
                                                survey.questions[i].options.add(new Options(optionName: start.toString()));
                                              }
                                            });
                                          },child: Text('End Date')) : SizedBox()
                                        ]
                                      ): SizedBox(),
                                    ),

                                    Center(
                                      child: (survey.questions[i].questionType == 'multiplechoice' || survey.questions[i].questionType == 'dropDown' || survey.questions[i].questionType == 'dropDownMultiple')
                                      ? Center(
                                        child: (survey.questions[i].options != null) 
                                        ? ListView.builder(
                                          itemCount: survey.questions[i].options?.length,
                                          shrinkWrap: true,
                                          physics: ClampingScrollPhysics(),
                                          itemBuilder: (context, j) {
                                            return new Card(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  ListTile(
                                                    title: Text("Option ${j+1}"),
                                                    trailing: IconButton(
                                                      icon: Icon(Icons.close),
                                                      tooltip: 'Remove question option',
                                                      onPressed: () {
                                                        setState(() {
                                                          survey.questions[i].options.remove(survey.questions[i].options[j]);
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                  FormBuilderTextField(
                                                    attribute: "option$j",
                                                    decoration: InputDecoration(labelText: "Option ${j+1}"),
                                                    initialValue: survey.questions[i].options[j].optionName ?? '',
                                                    validators: [
                                                      FormBuilderValidators.required(),
                                                    ],
                                                    onChanged: (value) => survey.questions[i].options[j]?.optionName = value,
                                                  )
                                                ]
                                              )
                                            );
                                          }
                                        ): SizedBox(),
                                      ) : SizedBox(),
                                    ),
                                    Center(
                                      child: (survey.questions[i].questionType == 'multiplechoice' || survey.questions[i].questionType == 'dropDown' || survey.questions[i].questionType == 'dropDownMultiple')
                                      ? MaterialButton(
                                        minWidth: 300,
                                        color: Colors.black,
                                        child: Text(
                                          "Add Option",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            if (survey.questions[i].options == null) {
                                              survey.questions[i].options = [];
                                              survey.questions[i].options.add(Options());
                                            } else {
                                              survey.questions[i].options.add(Options());
                                            }
                                          });
                                        },
                                      ) 
                                      : SizedBox(),
                                    )
                                  ],
                                )
                              );
                            },
                            separatorBuilder: (BuildContext context, int index) => const Divider(),
                          ),
                          MaterialButton(
                            minWidth: 350,
                            color: Theme.of(context).accentColor,
                            child: Text(
                              "Add Question",
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () {
                              setState(() {
                                survey.questions.add(new Questions());
                              });
                            },
                          ),
                          (_subscription != 'FREE') ? FormBuilderSwitch(
                            label: Text('Private Survey'),
                            attribute: "private",
                            readOnly: (_subscription == 'FREE'),
                            initialValue: survey?.private,
                            onChanged: (value) => survey?.private = value,
                          ): SizedBox(),
                          // Center(
                          //   child: (_subscription == 'FREE') 
                          //   ? Row(
                          //     children: [
                          //       Icon(
                          //         Icons.info,
                          //         color: Colors.red,
                          //         size: 20.0,
                          //       ),
                          //       Text('Upgrade to use this future', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))
                          //     ]
                          //   ) 
                          //   : SizedBox(),
                          // ),
                          FormBuilderSwitch(
                            label: Text('Public Survey'),
                            attribute: "public",
                            // readOnly: (_subscription == 'FREE'),
                            initialValue: survey?.public,
                            onChanged: (value) => survey?.public = value,
                          ),
                          // Center(
                          //   child: (_subscription == 'FREE') 
                          //   ? Row(
                          //     children: [
                          //       Icon(
                          //         Icons.info,
                          //         color: Colors.red,
                          //         size: 20.0,
                          //       ),
                          //       Text('Upgrade to use this future', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))
                          //     ]
                          //   ) 
                          //   : SizedBox(),
                          // ),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: MaterialButton(
                                  color: Theme.of(context).accentColor,
                                  child: Text(
                                    "Submit",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onPressed: () {
                                    _fbKey.currentState.save();
                                    if (_fbKey.currentState.validate()) {
                                      _submitForm(survey);
                                      // _submitForm(_fbKey.currentState.value);
                                    } else {
                                      print(_fbKey.currentState.value);
                                      print("validation failed");
                                    }
                                  },
                                ),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Expanded(
                                child: MaterialButton(
                                  color: Theme.of(context).accentColor,
                                  child: Text(
                                    "Reset",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onPressed: () {
                                    _fbKey.currentState.reset();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      )
    );
  }

  _submitForm(Survey survey) async {
    _fbKey.currentState.save();
    widget.onSave(survey);
    _addUpdateBloc.add(
      SubmissionButtonPressed(
        survey: survey
      ),
    );
  }
}