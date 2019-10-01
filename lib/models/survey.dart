// import 'package:equatable/equatable.dart';

class Survey {
// class Survey extends Equatable {
  bool active;
  List<String> facebookPostId;
  List<String> meta;
  bool private;
  bool public;
  List<Questions> questions;
  List<String> submissionDates;
  int surveyTime;
  int totalAnswers;
  List<Users> users;
  String id;
  dynamic category;
  String name;
  String lastSubmission;
  Null experationDate;
  String layout;
  String creator;
  String createdAt;
  String updatedAt;
  String logo;
  int iV;
  double averageTime;

  Survey({
    this.active,
    this.facebookPostId,
    this.meta,
    this.private,
    this.public,
    this.questions,
    this.submissionDates,
    this.surveyTime,
    this.totalAnswers,
    this.users,
    this.id,
    this.category,
    this.name,
    this.lastSubmission,
    this.experationDate,
    this.layout,
    this.creator,
    this.createdAt,
    this.updatedAt,
    this.logo,
    this.iV,
    this.averageTime
  });

  Survey.fromJson(Map<String, dynamic> json) {
    active = json['active'];
    facebookPostId = json['facebookPostId'].cast<String>();
    meta = json['meta'].cast<String>();
    private = json['private'];
    public = json['public'];
    if (json['questions'] != null) {
      questions = new List<Questions>();
      json['questions'].forEach((v) {
        questions.add(new Questions.fromJson(v));
      });
    }
    submissionDates = json['submissionDates'].cast<String>();
    surveyTime = json['surveyTime'];
    totalAnswers = json['totalAnswers'];
    if (json['users'] != null) {
      users = new List<Null>();
      json['users'].forEach((v) {
        users.add(new Users.fromJson(v));
      });
    }
    id = json['_id'];
    category = json['category'];
    name = json['name'];
    lastSubmission = json['lastSubmission'];
    experationDate = json['experationDate'];
    layout = json['layout'];
    creator = json['creator'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    logo = (json['logo'] != null) ? json['logo'] : '';
    averageTime = (json['averageTime'] != null) ? json['averageTime'].toDouble() : 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['active'] = this.active;
    data['facebookPostId'] = this.facebookPostId;
    data['meta'] = this.meta;
    data['private'] = this.private;
    data['public'] = this.public;
    if (this.questions != null) {
      data['questions'] = this.questions.map((v) => v.toJson()).toList();
    }
    data['submissionDates'] = this.submissionDates;
    data['surveyTime'] = this.surveyTime;
    data['totalAnswers'] = this.totalAnswers;
    if (this.users != null) {
      data['users'] = this.users.map((v) => v.toJson()).toList();
    }
    data['_id'] = this.id;
    data['category'] = this.category;
    data['name'] = this.name;
    data['lastSubmission'] = this.lastSubmission;
    data['experationDate'] = this.experationDate;
    data['layout'] = this.layout;
    data['creator'] = this.creator;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    data['averageTime'] = this.averageTime;
    data['logo'] = this.logo;
    return data;
  }
}

class Questions {
  List<dynamic> answers;
  bool isRequired;
  String sId;
  String questionType;
  String question;
  List<Options> options;
  String sSurvey;
  String createdAt;
  String updatedAt;
  int iV;
  String lastAnswered;

  Questions(
      {this.answers,
      this.isRequired,
      this.sId,
      this.questionType,
      this.question,
      this.options,
      this.sSurvey,
      this.createdAt,
      this.updatedAt,
      this.iV,
      this.lastAnswered});

  Questions.fromJson(Map<String, dynamic> json) {
    answers = json['answers'];
    isRequired = json['isRequired'];
    sId = json['_id'];
    questionType = json['questionType'];
    question = json['question'];
    if (json['options'] != null) {
      options = new List<Options>();
      json['options'].forEach((v) {
        options.add(new Options.fromJson(v));
      });
    }
    sSurvey = json['_survey'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    lastAnswered = json['lastAnswered'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['answers'] = this.answers;
    data['isRequired'] = this.isRequired;
    data['_id'] = this.sId;
    data['questionType'] = this.questionType;
    data['question'] = this.question;
    if (this.options != null) {
      data['options'] = this.options.map((v) => v.toJson()).toList();
    }
    data['_survey'] = this.sSurvey;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    data['lastAnswered'] = this.lastAnswered;
    return data;
  }
}

class Options {
  String optionName;

  Options({this.optionName});

  Options.fromJson(Map<String, dynamic> json) {
    optionName = json['optionName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['optionName'] = this.optionName;
    return data;
  }
}

class Users {
  String sId;
  bool answeredSurvey;
  List<String> answers;
  String email;
  bool emailSent;
  String messageSID;
  String name;
  String phone;
  String submissionDate;
  String surveyOwner;
  bool textSent;
  bool private;
  String sMeta;
  String sSurvey;

  Users(
      {this.sId,
      this.answeredSurvey,
      this.answers,
      this.email,
      this.emailSent,
      this.messageSID,
      this.name,
      this.phone,
      this.submissionDate,
      this.surveyOwner,
      this.textSent,
      this.private,
      this.sMeta,
      this.sSurvey});

  Users.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    answeredSurvey = json['answeredSurvey'];
    answers = json['answers'].cast<String>();
    email = json['email'];
    emailSent = json['emailSent'];
    messageSID = json['messageSID'];
    name = json['name'];
    phone = json['phone'];
    submissionDate = json['submissionDate'];
    surveyOwner = json['surveyOwner'];
    textSent = json['textSent'];
    private = json['private'];
    sMeta = json['_meta'];
    sSurvey = json['_survey'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['answeredSurvey'] = this.answeredSurvey;
    data['answers'] = this.answers;
    data['email'] = this.email;
    data['emailSent'] = this.emailSent;
    data['messageSID'] = this.messageSID;
    data['name'] = this.name;
    data['phone'] = this.phone;
    data['submissionDate'] = this.submissionDate;
    data['surveyOwner'] = this.surveyOwner;
    data['textSent'] = this.textSent;
    data['private'] = this.private;
    data['_meta'] = this.sMeta;
    data['_survey'] = this.sSurvey;
    return data;
  }
}