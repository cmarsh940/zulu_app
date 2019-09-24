import 'package:flutter/material.dart';
import 'package:project_z/models/survey.dart';
import 'package:project_z/survey/charts/charts.dart';
import 'package:project_z/survey/widgets/question_widget.dart';


class DetailsWidget extends StatefulWidget {
  final Survey survey;

  DetailsWidget(this.survey);

  @override
  _DetailsWidgetState createState() => _DetailsWidgetState();
}

class _DetailsWidgetState extends State<DetailsWidget> {
  Survey survey;
  double avg;
  double finalAvg;

  @override
  void initState() {
    survey = widget.survey;
    avg = survey.averageTime / 1000 * survey.totalAnswers;
    finalAvg = double.parse(avg.toStringAsFixed(2));
    convertAnswers();
    super.initState();
  }

  convertAnswers() {
    List<Questions> questions = survey.questions;
    for (var i = 0; i < questions.length; i++) {
      var q = questions[i];
      
      if (q.questionType == 'star') {
        print('********* QUESTION TYPE IS STAR *******');
        var tempAnswers = [{'number': 1, 'count': 0}, {'number': 2, 'count': 0}, {'number': 3, 'count': 0}, {'number': 4, 'count': 0}, {'number': 5, 'count': 0}];
        for (var j = 0; j < q.answers.length; j++) {
          var a = q.answers[j];
          print('a: $a');
          tempAnswers.forEach((f) => {
            if(a == f['number']) {
              f['count'] += 1
            }
          });
        }
        q.answers = tempAnswers;
      }

      if (q.questionType == 'multiplechoice' || q.questionType == 'dropDown') {
        print('********* QUESTION TYPE IS MULTIPLECHOICE *******');
        var tempAnswers = [];
        Map tempOptions;
        q.options.forEach((v) => {
          tempOptions = {'name': v.optionName, 'count': 0},
          tempAnswers.add(tempOptions)
        });
        print(' ### ### Start answers are: $tempAnswers');
        for (var j = 0; j < q.answers.length; j++) {
          var a = q.answers[j];
          print('a: $a');
          tempAnswers.forEach((f) => {
            if(a == f['name']) {
              f['count'] += 1
            }
          });
        }
        q.answers = tempAnswers;
      }

      if (q.questionType == 'boolean' || q.questionType == 'goodbad' || q.questionType == 'likeunlike' || q.questionType == 'yesno' || q.questionType == 'moreless') {
        print('********* QUESTION TYPE IS BOOLEAN *******');
        var tempAnswers = [{'name': 0, 'count': 0}, {'name': 1, 'count': 0}];
        for (var j = 0; j < q.answers.length; j++) {
          var a = q.answers[j];
          print('a: $a');
          tempAnswers.forEach((f) => {
            if(a == f['name']) {
              f['count'] += 1
            }
          });
        }
        q.answers = tempAnswers;
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height * 0.11,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.fromRGBO(21, 102, 182, 1),
                          Color.fromRGBO(24, 115, 205, 1),
                          Color.fromRGBO(27, 127, 228, 1),
                        ],
                      ),
                    ),
                ),
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0.0,
                  title: Text(survey.name),
                ),
              ],
            ),
            Container(
              height: 250,
              child: DateTimeComboLinePointChart.withData(survey),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text('Total Answers: ${survey.totalAnswers}'),
                Text('Average Time: $finalAvg Sec'),
              ],
            ),
            Expanded(
              child: new ListView.builder(
                itemCount: survey.questions.length,
                itemBuilder: (context, i) {
                  Questions questions = survey.questions[i];
                  return Center(
                    child: QuestionWidget(questions),
                  );
                },
            ),
          ),
        ],
      ),
    );
  }
}