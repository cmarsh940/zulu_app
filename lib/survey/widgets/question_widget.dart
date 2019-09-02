import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_z/models/survey.dart';

class QuestionWidget extends StatelessWidget {
  const QuestionWidget(this.question);

  final Questions question;


  @override
  Widget build(BuildContext context) {
    if (question.questionType == 'date' || question.questionType == 'dateStartEnd' || question.questionType == 'dateWeekday') {
      return (new Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.adjust),
            title: Text(
              '${question.question}',
              textAlign: TextAlign.left,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.w400),
            ),
            onTap: () => print('tapped question ${question.sId}'),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(40.0, 10.0, 40.0, 5.0),
            child: Container(
              height: 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Text('Answers', textAlign: TextAlign.justify, textScaleFactor: 1.1,),
                  Expanded(
                    child: new ListView.builder(
                      itemCount: question.answers.length ?? 0,
                      itemBuilder: (context, i) {
                        var answer = question.answers[i];
                        var time = new DateFormat("yyyy-MM-dd", "en_US").parse(answer);
                        return Text('${time.month}/${time.day}/${time.year}', textAlign: TextAlign.justify, textScaleFactor: 1.1,);
                      },
                    ),
                  ),
                ]
              )
            ),
          ),
        ],
      ),
    ));
    } else if (question.questionType == 'boolean') {
      List<OptionAnswers> temp = [];
      List test = question.answers;
      test.asMap();
      question.answers.forEach((f) => temp.add(new OptionAnswers.fromJson(f)));
      return (new Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.adjust),
              title: Text(
                '${question.question}',
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.w400),
              ),
              onTap: () => print('tapped question ${question.sId}'),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(40.0, 10.0, 40.0, 5.0),
              child: Container(
                height: 100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('Answers',style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.justify, textScaleFactor: 1.1),
                        Text('Total',style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.justify, textScaleFactor: 1.1),
                      ]
                    ),
                    Expanded(
                      child: new ListView.builder(
                        itemCount: question.answers.length,
                        itemBuilder: (context, i) {
                          return Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              (temp[i].name == 0) ? Text('true', textAlign: TextAlign.justify, textScaleFactor: 1.1,) : Text('false', textAlign: TextAlign.justify, textScaleFactor: 1.1,),
                              ( temp[i].name == 0) ? Text('${temp[1].count}', textAlign: TextAlign.justify, textScaleFactor: 1.1,) : Text('${temp[0].count}', textAlign: TextAlign.justify, textScaleFactor: 1.1,)
                            ]
                          );
                        },
                      ),
                    ),
                  ]
                )
              ),
            ),
          ],
        ),
      )
    );


    //MULTIPLE CHOICE
    } else if (question.questionType == 'multiplechoice') {
      List<OptionAnswers> temp = [];
      List test = question.answers;
      test.asMap();
      question.answers.forEach((f) => temp.add(new OptionAnswers.fromJson(f)));
      return (new Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.adjust),
              title: Text(
                '${question.question}',
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.w400),
              ),
              onTap: () => print('tapped question ${question.sId}'),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(40.0, 10.0, 40.0, 5.0),
              child: Container(
                height: 100,
                 child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('Answers',style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.justify, textScaleFactor: 1.1),
                          Text('Total',style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.justify, textScaleFactor: 1.1),
                        ]
                      ),
                      Expanded(
                        child: new ListView.builder(
                          itemCount: temp.length,
                          itemBuilder: (context, index) {
                            return (question.answers.length > 0) ? new Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('${temp[index].name}'),
                                (temp[index].count != null) ? Text('${temp[index].count / question.answers.length * 100}', textAlign: TextAlign.right,) : Text('No Answer')
                              ],
                            ) : Text('No Answers', textAlign: TextAlign.left, textScaleFactor: 1.1,);
                          } 
                        ),
                      )
                    ]
                  )
              )
            ),
          ],
        ),
      )
    );

    //STAR
    } else if (question.questionType == 'star' || question.questionType == 'rate') {
      List<StarAnswers> temp = [];
      List test = question.answers;
      test.asMap();
      question.answers.forEach((f) => temp.add(new StarAnswers.fromJson(f)));
      var total = 0;
      temp.forEach((f) => {
        total += f.number * f.count
      });
      return (new Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.adjust),
              title: Text(
                '${question.question}',
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.w400),
              ),
              onTap: () => print('tapped question ${question.sId}'),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(40.0, 10.0, 40.0, 5.0),
              child: Container(
                height: 100,
                 child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: (temp.length > 0) ? Text('1: ${temp[0].count}', style: TextStyle(color: Colors.black)) : Text('1: 0', style: TextStyle(color: Colors.black)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: (temp.length > 0) ? Text('2: ${temp[1].count}', style: TextStyle(color: Colors.black)): Text('2: 0', style: TextStyle(color: Colors.black)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: (temp.length > 0) ? Text('3: ${temp[2].count}', style: TextStyle(color: Colors.black)): Text('3: 0', style: TextStyle(color: Colors.black)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: (temp.length > 0) ? Text('4: ${temp[3].count}', style: TextStyle(color: Colors.black)): Text('4: 0', style: TextStyle(color: Colors.black)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: (temp.length > 0) ? Text('5: ${temp[4].count}', style: TextStyle(color: Colors.black)): Text('5: 0', style: TextStyle(color: Colors.black)),
                            ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.star, color: Color(0xFFFFE600)),
                            (total / (temp[0].count + temp[1].count + temp[2].count + temp[3].count + temp[4].count) < 3) ? Text('Average: ${total / (temp[0].count + temp[1].count + temp[2].count + temp[3].count + temp[4].count)}', style: TextStyle(color: Colors.red)) : Text('Average: ${total / (temp[0].count + temp[1].count + temp[2].count + temp[3].count + temp[4].count)}', style: TextStyle(color: Colors.green, fontSize: 20)),
                          ],
                        ),
                      )
                          

                    ]
                  )
              )
            ),
          ],
        ),
      )
    );



    // EVERYTHING ELSE
    } else {
      return (new Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.adjust),
              title: Text(
                '${question.question}',
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.w400),
              ),
              onTap: () => print('tapped question ${question.sId}'),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(40.0, 10.0, 40.0, 5.0),
              child: Container(
                height: 100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Text('Answers', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.left, textScaleFactor: 1.1,),
                    Expanded(
                      child: new ListView.builder(
                        itemCount: question.answers.length,
                        itemBuilder: (context, i) {
                          var answer = question.answers[i];
                          return (question.answers.length > 0) ? Text(answer.toString(), textAlign: TextAlign.left, textScaleFactor: 1.1,) : Text('No Answers', textAlign: TextAlign.left, textScaleFactor: 1.1,);
                        },
                      ),
                    ),
                  ]
                )
              ),
            ),
          ],
        ),
      )
    );
    }
  }
}

class StarAnswers {
  dynamic number;
  int count;

  StarAnswers({this.number, this.count});

  StarAnswers.fromJson(Map<dynamic, dynamic> json) {
    number = json['number'];
    count = json['count'];
  }
}
class OptionAnswers {
  dynamic name;
  int count;

  OptionAnswers({this.name, this.count});

  OptionAnswers.fromJson(Map<dynamic, dynamic> json) {
    name = json['name'];
    count = json['count'];
  }
}
