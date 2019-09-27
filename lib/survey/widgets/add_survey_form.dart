import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:project_z/data/repositories.dart';
import 'package:project_z/models/survey.dart';

import '../survey.dart';




// typedef OnSaveCallback = Function(Survey survey);

class AddSurveyForm extends StatefulWidget {
  final bool isEditing;
  final OnSaveCallback onSave;
  final Survey survey;
  final SurveyRepository _surveyRepository;

  AddSurveyForm({
    Key key,
    @required this.onSave,
    @required this.isEditing,
    this.survey, @required SurveyRepository surveyRepository
  }) : assert(surveyRepository != null),
        _surveyRepository = surveyRepository, super(key: key);

  @override
  _AddSurveyFormState createState() => _AddSurveyFormState();
}

class _AddSurveyFormState extends State<AddSurveyForm> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  AddUpdateBloc _addUpdateBloc;
  Survey get survey => widget.survey;
  bool get isEditing => widget.isEditing;
  SurveyRepository get _surveyRepository => widget._surveyRepository;
  List<String> _layouts = <String>['', 'PAGE', 'STEPS'];
  List<Map<String, String>> _qTypes = [
    {"value": "", "viewValue": ""},
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

  List<Question> questions = []; 
  List _categories = [''];
  String id;
  String _subscription;

  @override
  void initState() {
    super.initState();
    getCategories();
    getSubscription();
    getId();
     _addUpdateBloc = BlocProvider.of<AddUpdateBloc>(context);
     rebuild = false;
     Question first = Question();
     first.questionType = '';
     first.question = '';
     first.options = [];
     first.options.add(new NewOptions());
     questions.add(first);
  }

  @override
  void dispose() { 
    _addUpdateBloc.dispose();
    super.dispose();
  }

  void getCategories() async {
    List categories = await _surveyRepository.getCategories();
    setState(() {
      categories.forEach((f) => _categories.add(f));
    });
  }
  void getSubscription() async {
    String subscription = await _surveyRepository.getSubscription();
    setState(() {
      _subscription = subscription;
    });
  }

  void getId() async {
    String clientId = await _surveyRepository.getId();
    setState(() {
      id = clientId;
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
                'Add Survey',
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
                            initialValue: '',
                            autofocus: true,
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
                            // validators: [FormBuilderValidators.required()],
                            items: _layouts.map((layout) => DropdownMenuItem(
                              value: layout,
                              child: Text('$layout'),
                            )).toList(),
                            onChanged: (value) => survey?.layout = value,
                          ),
                          FormBuilderDropdown(
                            attribute: "category",
                            decoration: InputDecoration(labelText: "Survey Category"),
                            initialValue: '',
                            hint: Text('Select Category'),
                            validators: [FormBuilderValidators.required()],
                            items: _categories.map((category) => DropdownMenuItem(
                              value: category,
                              child: Text('$category'),
                            )).toList(),
                            onChanged: (value) => survey?.category = value,
                          ),
                          ListView.separated(
                            padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                            itemCount: questions.length,
                            shrinkWrap: true,
                            physics: ClampingScrollPhysics(),
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
                                            questions.remove(questions[i]);
                                          });
                                        },
                                      ),
                                    ),
                                    FormBuilderDropdown(
                                      attribute: "$i",
                                      decoration: InputDecoration(labelText: "Question ${i+1}"),
                                      initialValue: questions[i].questionType,
                                      validators: [
                                        FormBuilderValidators.required(),
                                      ],
                                      hint: Text('Select Question Type'),
                                      // validators: [FormBuilderValidators.required()],
                                      items: _qTypes.map((Map q) => DropdownMenuItem(
                                        value: q['value'],
                                        child: Text('${q['viewValue']}'),
                                      )).toList(),
                                      onChanged: (value) => questions[i].questionType = value,
                                    ),
                                    FormBuilderTextField(
                                      attribute: "question$i",
                                      decoration: InputDecoration(labelText: "Question"),
                                      initialValue: questions[i].question,
                                      validators: [
                                        FormBuilderValidators.required(),
                                      ],
                                      onChanged: (value) => questions[i].question = value,
                                    ),
                                    Center(
                                      child: (questions[i].questionType == 'dateStartEnd')
                                      ? Center(
                                        child: (questions[i].options != null) 
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
                                                    subtitle: (questions[i].options.length > 1) ? Text('${questions[i]?.options[1].optionName}') : Text('Select a Date'),
                                                  ),
                                                  ListTile(
                                                    title:Text("End Date"),
                                                    subtitle:(questions[i].options.length > 2) ? Text('${questions[i].options[2].optionName}') : Text('Select a Date'),
                                                  ),
                                                  
                                                ]
                                              )
                                            ),
                                            (questions[i].options.length <= 1) ? RaisedButton(onPressed: () async {
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
                                                if (questions[i].options == null) {
                                                  questions[i].options = [];
                                                  questions[i].options.add(new NewOptions(optionName: start.toString()));
                                                } else {
                                                  questions[i].options.add(new NewOptions(optionName: start.toString()));
                                                }
                                              });
                                            },child: Text('Start Date')) : SizedBox(),
                                            (questions[i].options.length >= 1 && questions[i].options.length < 3) ? RaisedButton(onPressed: () async {
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
                                                if (questions[i].options == null) {
                                                  questions[i].options = [];
                                                  questions[i].options.add(new NewOptions(optionName: start.toString()));
                                                } else {
                                                  questions[i].options.add(new NewOptions(optionName: start.toString()));
                                                }
                                              });
                                            },child: Text('End Date')) : SizedBox()
                                          ]
                                        ): SizedBox(),
                                      ) : SizedBox(),
                                    ),
                                    
                                    Center(
                                      child: (questions[i].questionType == 'multiplechoice' || questions[i].questionType == 'dropDown' || questions[i].questionType == 'dropDownMultiple')
                                      ? Center(
                                        child: (questions[i].options != null) 
                                        ? ListView.builder(
                                          key: Key('options'),
                                          itemCount: questions[i].options.length,
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
                                                          questions[i].options.remove(questions[i].options[j]);
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                  FormBuilderTextField(
                                                    attribute: "option$j",
                                                    initialValue: questions[i].options[j].optionName ?? '',
                                                    validators: [
                                                      FormBuilderValidators.required(),
                                                    ],
                                                    onChanged: (value) => questions[i]?.options[j]?.optionName = value,
                                                  )
                                                ]
                                              )
                                            );
                                          },
                                        ): SizedBox(),
                                      ) : SizedBox(),
                                    ),
                                    Center(
                                      child: (questions[i].questionType == 'multiplechoice' || questions[i].questionType == 'dropDown' || questions[i].questionType == 'dropDownMultiple') 
                                      ? MaterialButton(
                                        minWidth: 300,
                                        color: Colors.black,
                                        child: Text(
                                          "Add Option",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            if (questions[i].options == null) {
                                              questions[i].options = [];
                                              questions[i].options.add(new NewOptions());
                                            } else {
                                              questions[i].options.add(new NewOptions());
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
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Container(
                              child: Center(
                                child: MaterialButton(
                                  minWidth: 350,
                                  color: Theme.of(context).accentColor,
                                  child: Text(
                                    "Add Question",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onPressed: () {
                                    if (_fbKey.currentState.validate()) {
                                      setState(() {
                                        questions.add(new Question());
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        ]
                      )
                    ),
                    (_subscription != 'FREE') ? FormBuilderSwitch(
                      label: Text('Private Survey'),
                      attribute: "private",
                      readOnly: (_subscription == 'FREE'),
                      initialValue: false,
                      onChanged: (value) => survey?.private = value,
                    ) : SizedBox(),
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
                      initialValue: false,
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
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
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
                                  // _submitForm(survey, questions);
                                  _submitForm(_fbKey.currentState.value);
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

  _submitForm(dynamic survey) async {
    _fbKey.currentState.save();
    // widget.onSave(survey);
    dynamic data = {'id': id,'survey': survey, 'questions': questions};

    _addUpdateBloc.dispatch(
      AddButtonPressed(
        data      
      ),
    );
  }
}

class Question {
  String questionType;
  String question;
  List<NewOptions> options;

  Question({this.questionType, this.question, this.options});

  Question.fromJson(Map<String, dynamic> json) {
    questionType = json['questionType'];
    question = json['question'];
    if (json['options'] != null) {
      options = new List<NewOptions>();
      json['options'].forEach((v) {
        options.add(new NewOptions.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['questionType'] = this.questionType;
    data['question'] = this.question;
    if (this.options != null) {
      data['options'] = this.options.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class NewOptions {
  String optionName;

  NewOptions({this.optionName});

  NewOptions.fromJson(Map<String, dynamic> json) {
    optionName = json['optionName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['optionName'] = this.optionName;
    return data;
  }
}