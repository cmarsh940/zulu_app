class QuestionTypesModel {
  List<QuestionTypes> questionTypes;

  QuestionTypesModel({this.questionTypes});

  QuestionTypesModel.fromJson(Map<String, dynamic> json) {
    if (json['questionTypes'] != null) {
      questionTypes = new List<QuestionTypes>();
      json['questionTypes'].forEach((v) {
        questionTypes.add(new QuestionTypes.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.questionTypes != null) {
      data['questionTypes'] =
          this.questionTypes.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class QuestionTypes {
  String name;
  List<Group> group;

  QuestionTypes({this.name, this.group});

  QuestionTypes.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    if (json['group'] != null) {
      group = new List<Group>();
      json['group'].forEach((v) {
        group.add(new Group.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    if (this.group != null) {
      data['group'] = this.group.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Group {
  String value;
  String viewValue;

  Group({this.value, this.viewValue});

  Group.fromJson(Map<String, dynamic> json) {
    value = json['value'];
    viewValue = json['viewValue'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['value'] = this.value;
    data['viewValue'] = this.viewValue;
    return data;
  }
}