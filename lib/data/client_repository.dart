import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:project_z/models/category.dart';
import 'package:project_z/models/client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../constants.dart';
import 'repositories.dart';

class ClientRepository {
  final Api api;

  ClientRepository({@required this.api})
      : assert(api != null);

  Future<ClientModel> authenticate({
    @required String email,
    @required String password,
  }) async {
    var response = await http.post(loginURL, body: {'email': email, 'password': password});
    if (response.statusCode == 200) {
      Map clientMap = jsonDecode(response.body);
      final ClientModel _client = new ClientModel.fromJson(clientMap);
      // ClientModel _client = ClientModel.fromJson(json.decode(response.body));
      if (_client.id == null) {
        print('CLIENT ID IS NULL');
        return null;
      } else {
        final _token = _client.token;
        final _id = _client.id;
        final _count = _client.surveyCount;
        final _subscription = _client.subscription;

        SharedPreferences.getInstance().then((prefs) {
          prefs.setString("client_token", _token);
          prefs.setString("client_id", _id);
          prefs.setBool("is_login", true);
          prefs.setInt("_count", _count);
          prefs.setString("_subscription", _subscription);
        });
        return _client;
      }
    } else {
      return null;
    }
  }


  Future<CategoryApi> getCategory() async {
    var url = getCategoriesURL;
    var response =  await api.get(url);
     if (response.statusCode == 200) {
      CategoryApi _categories = CategoryApi.fromJson(json.decode(response.body));
      return _categories;
     } else {
      return null;
    }
  }

  // Future<List<Survey>> getSurveys(String id) async {
  //   var url = getSurveysURL + '$id';
  //   var response =  await api.get(url);
  //    if (response.statusCode == 200) {
  //      List responseJson = json.decode(response.body);
  //     var _survey = responseJson.map((m) => new Survey.fromJson(m)).toList();
  //     return _survey;
  //    } else {
  //     return null;
  //   }
  // }
  

  Future<void> deleteToken() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.remove("client_token");
    return;
  }

  Future<String> getId() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString("client_id");
  }

  Future<String> getToken() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString("client_token");
  }
  
  Future<bool> isSignedIn() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getBool("is_login");
  }

  Future<dynamic> getClient() async {
    var id = await getId();
    var url = getClientURL + '$id';
    var response =  await http.get(url);
      if (response.statusCode == 200) {
      return response.body;
     } else {
      return null;
    }
  }

  Future<void> signOut() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.clear();
    return ;
  }

  Future signUp({String firstName, String lastName, email, String password}) async {
    var response = await http.post(registerURL, body: {'firstName': firstName, 'lastName': lastName,'email': email, 'password': password});
    if (response.statusCode == 200) {
      print('response is: ${response.body}');
    
      authenticate(email: email, password: password);
      return true;
    } else {
      return null;
    }
  }

  Future updateClient(ClientModel client) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String _token = pref.getString("client_token");
    var id = client.id;
    if (id == null) {
      return null;
    } else {
      var url = updateClientURL + '$id';
      var _body = json.encode(client.toJson());
      final http.Response response = await http.put(
        Uri.encodeFull(url), 
        body: _body, 
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: "Bearer $_token",
        },
      );
      if (response.statusCode == 200) {
        var data = ClientModel.fromJson(json.decode(response.body));
        return data;
      } else {
        print('Error did not return 200');
        return null;
      }
    }
  }
  Future updateSubscription(Payment data) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String _token = pref.getString("client_token");
    var id = pref.getString("client_id");
    if (id == null) {
      return null;
    } else {
      var url = updateSubscriptionURL + '$id';
      var _body = json.encode(data.toJson());
      final http.Response response = await http.put(
        Uri.encodeFull(url), 
        body: _body, 
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: "Bearer $_token",
        },
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        print('Error did not return 200');
        return null;
      }
    }
  }
}

class Payment {
  String id;
  dynamic subscription;

  Payment(this.id,this.subscription);

  Payment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    subscription = json['subscription'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['subscription'] = this.subscription;
    return data;
  }
}