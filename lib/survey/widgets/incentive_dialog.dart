import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:native_widgets/native_widgets.dart';
import 'package:project_z/data/repositories.dart';
import 'package:project_z/models/survey.dart';
import 'package:intl/intl.dart';

class IncentiveDialog extends StatefulWidget {
  final String id;
  final SurveyRepository _surveyRepository;
  final Survey survey;

  const IncentiveDialog({Key key, this.id, @required SurveyRepository surveyRepository, this.survey,
  }) : assert(surveyRepository != null),
        _surveyRepository = surveyRepository, super(key: key);

  @override
  _IncentiveDialogState createState() => _IncentiveDialogState();
}

class _IncentiveDialogState extends State<IncentiveDialog> with WidgetsBindingObserver {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  String get id => widget.id;
  Survey get survey => widget.survey;
  SurveyRepository get _surveyRepository => widget._surveyRepository;
  TempIncentive incentive = new TempIncentive(null, '');

  @override
  void initState() {
    print('incentive: ${survey.incentive}');
    if (survey.incentive != null) {
      incentive.name = survey.incentive.name;
      incentive.date = survey.incentive.drawDate;
    } else {
      incentive = new TempIncentive(DateTime.now(), '');
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).pop()
        ),
        title: Text('Survey Incentive'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0.0,
      ),
      body:  Padding(
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
                      decoration: InputDecoration(labelText: "Incentive", hintText: 'Win a new iphone!', helperText: 'explain what the incentive is:'),
                      initialValue: (survey?.incentive?.name != null) ? survey?.incentive?.name : '',
                      autofocus: true,
                      onChanged: (value) => incentive.name = value,
                      validators: [
                        FormBuilderValidators.required(),
                      ],
                    ),
                    FormBuilderDateTimePicker(
                      attribute: "date",
                      inputType: InputType.date,
                      format: DateFormat("yyyy-MM-dd"),
                      initialValue: (survey?.incentive?.drawDate != null) ? DateTime.parse(survey?.incentive?.drawDate) : null,
                      firstDate: DateTime.now(),
                      onChanged: (value) => incentive.date = value.toString(),
                      decoration:
                          InputDecoration(labelText: "Last submission date"),
                    ),
                  ]
                )
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: MaterialButton(
                        color: Theme.of(context).accentColor,
                        child: Text(
                          "Add Incentive",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          _fbKey.currentState.save();
                          if (_fbKey.currentState.validate()) {
                            // _submitForm(survey, questions);
                            _submitForm();
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
                          "Cancel",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
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
 _submitForm() async {
    _fbKey.currentState.save();
    print('incentive: $incentive');

    await _surveyRepository.updateIncentive(id: id, form: incentive);
    Navigator.pop(context);
  }
}