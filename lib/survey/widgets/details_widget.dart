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
        for (var j = 0; j < q.answers.length; j++) {
          var a = q.answers[j];
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
    return Scaffold(
      body: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              pinned: true,
              expandedHeight: 250.0,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                centerTitle: true,
                background: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
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
                  ],
                ),
              ),
            ),
            SliverPadding(
                  padding: EdgeInsets.all(0),
                  sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      Questions questions = survey.questions[i];
                      return Center(
                        child: QuestionWidget(questions),
                      );
                    },
                    childCount: survey.questions.length,
                  )),
                ),
          ],
        ),
    );
  }
}
