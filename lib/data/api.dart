import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:async/async.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart' as inner;
import 'package:meta/meta.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'repositories.dart';


class Api {
  Api({@required this.httpClient}) : assert(httpClient != null);
  final http.Client httpClient;

  ClientRepository clientRepository;

  Future<String> getToken() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var token = pref.getString("client_token");
    print('token is: $token');
    return token;
  }


  Future<dynamic> get(String url) async {
    // if (client == null) throw ('Auth Model Required');
    var _token = clientRepository.getToken();
    final http.Response response = await getHttpResponse(
      url,
      headers: {
              HttpHeaders.authorizationHeader: "Bearer $_token",
            },
      method: HttpMethod.get,
    );

    if (response?.body == null) return null;
    print('*** GET RESPONSE: $response.body');
    return json.decode(response.body);
  }

  Future<dynamic> delete(String url) async {
    var _token = clientRepository.getToken();
    // final String _token = client?.token ?? "";
    http.Response response = await getHttpResponse(
      url,
      headers: {
        HttpHeaders.authorizationHeader: "Bearer $_token",
      },
      method: HttpMethod.delete,
    );

    return json.decode(response.body);
  }

  Future<dynamic> post(String url, dynamic data,
      {String bodyContentType}) async {
    // if (client == null) {
    //   print("CLIENT IS NULL");
    //   throw ('Auth Model Required');
    //   }
    final _token = await getToken();
    // final String _token = client?.token ?? "";
    final http.Response response = await getHttpResponse(
      url,
      body: data,
      headers: {
        HttpHeaders.contentTypeHeader: bodyContentType ?? 'application/json',
        HttpHeaders.authorizationHeader: "Bearer $_token",
      },
      method: HttpMethod.post,
    );

    if (response.headers.containsValue("json"))
      return json.decode(response.body);
    if (response.statusCode == 200) {
      return response.body;
    }
  }

  Future<dynamic> put(String url, dynamic data) async {
    final _token = getToken();
    // final String _token = client?.token ?? "";
    final http.Response response = await getHttpResponse(
      url,
      body: data,
      headers: {
        'Content-Type': 'application/json',
        HttpHeaders.authorizationHeader: "Bearer $_token",
      },
      method: HttpMethod.put,
    );
    print('*** PUT RESPONSE: $response.body');
    return json.decode(response.body);
  }

  Future<http.StreamedResponse> uploadFile(
      String url, File file, String name) async {
    var stream = http.ByteStream(DelegatingStream.typed(file.openRead()));
    var length = await file.length();
    var uri = Uri.parse(url);
    var request = http.MultipartRequest("POST", uri);
    var multipartFile =
        http.MultipartFile(name, stream, length, filename: basename(file.path));
    request.files.add(multipartFile);
    var response = await request.send();
    print(response.statusCode);
    return response;
  }

  Future<http.Response> getHttpResponse(
    String url, {
    dynamic body,
    Map<String, String> headers,
    HttpMethod method = HttpMethod.get,
  }) async {
    final inner.IOClient _client = getClient();
    http.Response response;
    try {
      switch (method) {
        case HttpMethod.post:
          response = await _client.post(
            url,
            body: body,
            headers: headers,
          );
          break;
        case HttpMethod.put:
          response = await _client.put(
            url,
            body: body,
            headers: headers,
          );
          break;
        case HttpMethod.delete:
          response = await _client.delete(
            url,
            headers: headers,
          );
          break;
        case HttpMethod.get:
          response = await _client.get(
            url,
            headers: headers,
          );
      }

      print("URL: $url");
      print("Body: $body");
      print("Response Code: " + response.statusCode.toString());
      print("Response Body: " + response.body.toString());

      // if (response.statusCode >= 400) {
        // if (response.statusCode == 404) return response.body; // Not Found Message
        // if (response.statusCode == 401) {
        //   if (auth != null) {
            // Todo: Refresh Token !
            // await auth.refreshToken();
            // final String _token = auth?.token ?? "";
            // print(" Second Token => $_token");
            // Retry Request
            // response = await getHttpResponse(
            //   url,
            //   headers: {
            //     HttpHeaders.authorizationHeader: "Bearer $_token",
            //   },
            // );
      //     }
      //   } // Not Authorized
      //   if (devMode) throw ('An error occurred: ' + response.body);
      // }
    } catch (e) {
      print('Error with URL: $e');
    }
    return response;
  }

  inner.IOClient getClient() {
    bool trustSelfSigned = true;
    HttpClient httpClient = new HttpClient()
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) => trustSelfSigned);
    inner.IOClient ioClient = new inner.IOClient(httpClient);
    return ioClient;
  }
}

enum HttpMethod { get, post, put, delete }
