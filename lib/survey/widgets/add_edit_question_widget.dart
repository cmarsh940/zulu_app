import 'package:flutter/material.dart';
import 'package:project_z/models/survey.dart';



class AddEditQuestionWidget extends StatefulWidget {
  final Questions question;
  final bool isEditing;

  AddEditQuestionWidget({Key key, this.question, this.isEditing}) : super(key: key);

  _AddEditQuestionWidgetState createState() => _AddEditQuestionWidgetState();
}

class _AddEditQuestionWidgetState extends State<AddEditQuestionWidget> {
  Questions get question => widget.question;
  bool get isEditing => widget.isEditing;
  String _type;
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

  @override
  void initState() {
    _type = isEditing ? question.questionType.toString() : '';
    super.initState();
  }
   
  
  @override
  Widget build(BuildContext context) {
    return (new Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          new FormField(
            builder: (FormFieldState field) {
              return InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Question Type',
                ),
                isEmpty: !isEditing,
                child: new DropdownButtonHideUnderline(
                  child: new DropdownButton(
                    value: _type,
                    isDense: true,
                    onChanged: (newValue){
                      setState(() {
                        _type = newValue;
                      });      
                    },
                    items: _qTypes.map((Map val) {
                      return new DropdownMenuItem(
                        value: val['value'],
                        child: new Text(val['viewValue']),
                      );
                    }).toList(),
                  ),
                ),
              );
            },
            onSaved: (value) => question.questionType = value,
          ),
          TextFormField(
            initialValue: isEditing ? question.question : '',
            onSaved: (value) => question.question = value,
          ),
        ],
      )
    ));
  }
}