import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:project_z/models/question_types.dart';
import 'package:project_z/models/survey.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;



import '../constants.dart';
import 'repositories.dart';

class SurveyRepository {
  final Api api;

  SurveyRepository({@required this.api})
      : assert(api != null);


  Future<String> getId() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString("client_id");
  }
  
  Future getToken() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString("client_token");
  }
  Future<String> getSubscription() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString("_subscription");
  }

  Future<dynamic> loadQuestionTypes() async {
    var url = getQuestionTypesURL;
    var response =  await http.get(url);
    QuestionTypes _questionTypes = QuestionTypes.fromJson(json.decode(response.body));
    SharedPreferences.getInstance().then((prefs) {
        prefs.setString("question_types", _questionTypes.toString());
      });
    return ;
  }

  Future<dynamic> get getQuestionTypes async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString("question_types");
  }
  
  Future<dynamic> loadSurvey() async {
    var id = await getId();
    if (id == null) {
      return null;
    } else {
      var url = getSurveysURL + '$id';
      var response =  await http.get(url);
      return response.body;
    }
  }

  Future<dynamic> loadCategories() async {
    var checkCategories = await getCategories();
    if (checkCategories == null) {
      var url = getCategoriesURL;
      var response =  await http.get(url);
      List responseJson = json.decode(response.body);
      var _categories = responseJson.map((m) => m).toList();
      List<String> categories = [];
      for (var i = 0; i < _categories.length; i++) {		
        var a = _categories[i];	
        var c = a['name'];	
        categories.add(c);
      }
      SharedPreferences.getInstance().then((prefs) {
        prefs.setStringList("_categories", categories);
      });
      return categories;
    } else {
      return checkCategories;
    }
    
  }

  Future<Survey> getSingleSurvey(String id) async {
    if (id == null) {
      return null;
    } else {
      var url = getSingleSurveyURL + '$id';
      var response =  await http.get(url);
      if (response.statusCode == 200) {
        Survey _survey = Survey.fromJson(json.decode(response.body));
        
        TempCategory temp = TempCategory.fromJson(_survey.category);
        _survey.category = temp.name;
        return _survey;
      } else {
        print('Error gettting single survey');
        return null;
      }
    }
  }
  Future<bool> closeSurvey(String _id) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String _token = pref.getString("client_token");
    var id = _id;
    if (id == null) {
      return null;
    } else {
      var url = closeSurveyURL + '$id';
      var _body = json.encode({'id': id});
      final http.Response response = await http.put(
        Uri.encodeFull(url), 
        body: _body, 
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: "Bearer $_token",
        },
      );
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        return data;
      } else {
        print('Error gettting single survey');
        return null;
      }
    }
  }
  Future<bool> openSurvey(String _id) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String _token = pref.getString("client_token");
    var id = _id;
    if (id == null) {
      return null;
    } else {
      var url = openSurveyURL + '$id';
      var _body = json.encode({'id': id});
      final http.Response response = await http.put(
        Uri.encodeFull(url), 
        body: _body, 
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: "Bearer $_token",
        },
      );
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        return data;
      } else {
        print('Error gettting single survey');
        return null;
      }
    }
  }

  Future updateSurvey(Survey survey) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String _token = pref.getString("client_token");
    var id = survey.id;
    if (id == null) {
      return null;
    } else {
      var url = updateSurveyURL + '$id';
      var _body = json.encode(survey.toJson());
      final http.Response response = await http.put(
        Uri.encodeFull(url), 
        body: _body, 
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: "Bearer $_token",
        },
      );
      if (response.statusCode == 200) {
        var data = Survey.fromJson(json.decode(response.body));
        return data;
      } else {
        print('Error did not return 200');
        return null;
      }
    }
  }

  Future addSurvey(dynamic survey) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String _token = pref.getString("client_token");
    var url = postSurveyURL;
    var _body = json.encode(survey);
    var response = await http.post(
      url,
      body: _body, 
      headers: {
        'Content-Type': 'application/json',
        HttpHeaders.authorizationHeader: "Bearer $_token",
      },
    );
    if (response.statusCode == 200) {
      var data = int.parse(response.body);
      pref.setInt('_count', data);

      return data;
    } else {
      print('Error did not return 200');
      return null;
    }
  }

  Future saveSurvey(List<Survey> survey) {
    var newSurveys = survey.toString();
    return Future.wait<dynamic>([
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString("client_surveys", newSurveys);
      }),
      
    ]);
  }


  Future getCategories() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getStringList("_categories");
  }

  getSurveyCount() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    int count = pref.getInt("_count");
    return count;
  }

}

class TempCategory {
  String id;
  dynamic name;

  TempCategory(this.id,this.name);

  TempCategory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    return data;
  }
}