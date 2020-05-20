import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'api.dart';
import 'package:http/http.dart' as http;
import 'endpoint_data.dart';

//this file is our domain layer that deals with Dart http package, and get the data we want

//We sent a post request with our key to get accessToken, and with the access
// token, we get then send a get request to get data
class APIService {
  APIService(this.api, {dataCacheService});
  //from API class we created
  final API api;

  //APIService gives us exactly what we want

  Future<String> getAccessToken() async {
    //here we use http post method, and it take argument:
    // dynamic url, {Map<String, String> headers
    final response = await http.post(
      //we get url from this method in api instance
      //https://apigw.nubentos.com:443/token?grant_type=client_credentials
      api.tokenUri().toString(),
      //apiKey is a property from api, not initialized
      headers: {'Authorization': 'Basic ${api.apiKey}'},
    );

    if (response.statusCode == 200) {
      //response.body is a json string, json.decode will parse it and return a map.
      //from .http file, click Send Request(can't do it from this), and then we
      // can see the request result, it's a map:
      //{"access_token": "...", "scope": "...", "token_type": "Bearer", "expires_in": 3600}
      final data = json.decode(response.body);
      //thus we can tap into the key "access_token" to get the value
      final accessToken = data['access_token'];
      if (accessToken != null) {
        return accessToken;
      }
    }
    print(
        'Request ${api.tokenUri()} failed\nResponse: ${response.statusCode} ${response.reasonPhrase}');
    throw response;
  }

//example value:
//{
//  "date": "2020-04-10T17:01:40.000Z",
//  "data": 2425
//}

  Future<EndpointData> getEndpointData({
    @required String accessToken,
    @required Endpoint endpoint,
  }) async {
    //{{baseUrl}}                   /t/nubentos.com/ncovapi/2.0.0/cases
    //https://apigw.nubentos.com:443/t/nubentos.com/ncovapi/2.0.0/cases'
    final uri = api.endpointUri(endpoint);
    final response = await http.get(
      uri.toString(),
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    if (response.statusCode == 200) {
      //data is an array
      final List<dynamic> data = json.decode(response.body);

      if (data.isNotEmpty) {
        //result data is in an array, and only one value
        final Map<String, dynamic> endpointData = data[0];
        //we then go to the key of 'data' to get the result
        //original one also deals with different key, some are called cases, some are called data
        final int value = endpointData['data'];
        final String dateString = endpointData['date'];
        //there're parse and tryParse, tryParse is safer.
        final date = DateTime.tryParse(dateString);
        if (value != null) {
          return EndpointData(value: value, date: date);
        }
//        if (value != null) {
//          return value;
//        }
      }
    }
    print(
        'Request ${api.tokenUri()} failed\nResponse: ${response.statusCode} ${response.reasonPhrase}');
    throw response;
  }

//  //using version   1.0.0 with different key names.
//  static Map<Endpoint, String> _responseJsonKeys = {
//    Endpoint.cases: 'cases',
//    Endpoint.casesSuspected: 'data',
//    Endpoint.casesConfirmed: 'data',
//    Endpoint.deaths: 'data',
//    Endpoint.recovered: 'data',
//  };

}

//class EndpointData {
//  EndpointData({@required this.value, this.date}) : assert(value != null);
//  final int value;
//  final DateTime date;
//
//  @override
//  String toString() => 'date: $date, value: $value';
//}
