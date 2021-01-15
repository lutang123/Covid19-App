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
      //https://stackoverflow.com/questions/55520386/what-is-the-difference-between-json-decode-and-jsondecode-in-flutter
      final List<dynamic> data = json.decode(response.body);
      print('data: $data');
      // flutter: data: [{date: 2021-01-02T04:39:30.000Z, data: 1835287}]
      // flutter: data: [{date: 2021-01-02T04:39:30.000Z, data: 17026}]
      // flutter: data: [{date: 2021-01-02T04:39:30.000Z, data: 22904258}]
      // flutter: data: [{date: 2021-01-02T04:39:30.000Z, data: 84379178}]
      // flutter: data: [{date: 2021-01-02T04:39:30.000Z, data: 59639633}]
      // flutter: data: [{date: 2021-01-02T04:39:30.000Z, data: 801}]
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
      }
    }
    print(
        'Request ${api.tokenUri()} failed\nResponse: ${response.statusCode} ${response.reasonPhrase}');
    throw response;
  }
}

/// notes from payload
/// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:http/http.dart' as http;
// import 'package:tdg_mobile/app/enviroment/EnvironmentConfig.dart';
// import '../app/database/models/documents_model.dart';
//
// Future<List<DocumentModel>> fetchDocuments() async {
//   final storage = FlutterSecureStorage();
//   final token = await storage.read(key: 'jwt');
//   final headers = <String, String>{
//     HttpHeaders.contentTypeHeader: 'application/json',
//     HttpHeaders.authorizationHeader: 'Bearer $token',
//   };
//   final response = await http.get('${EnvironmentConfig.API_URL}/api/documents',
//       headers: headers);
//   print('response: $response');
//   List<DocumentModel> docsList;
//   if (response.statusCode == 200) {
//     print('response.body: ${response.body}');
//     final data = jsonDecode(response.body);
//     print('data: $data');
//     final list = data['documents'] as List;
//     print('list: $list');
//     if (list.isNotEmpty) {
//       docsList = list
//           .map(
//             (element) => DocumentModel.fromJson(element),
//           )
//           .toList();
//       return docsList;
//     }
//   }
//   throw Exception('Could not load data');
// }
//
// //flutter: response: Instance of 'Response'
// //flutter: response.body: {"documents":[{"id":20,"carrierId":2,"externalDocumentId":19,"waybillNumber":"BOL823720","status":0,"recordedAt":"2020-12-26T16:05:08.722Z","consignorId":3,"consignorName":null,"consignedAt":null,"deliveredAt":null,"creatorId":null,"updatedAt":"2020-12-30T17:31:50.647Z","createdAt":"2020-12-30T17:31:50.647Z"},{"id":19,"carrierId":2,"externalDocumentId":18,"waybillNumber":"BOL823719","status":0,"recordedAt":"2020-03-04T10:51:08.436Z","consignorId":3,"consignorName":null,"consignedAt":null,"deliveredAt":null,"creatorId":null,"updatedAt":"2020-12-30T17:31:50.646Z","createdAt":"2020-12-30T17:31:50.646Z"},{"id":18,"carrierId":2,"externalDocumentId":17,"waybillNumber":"BOL823718","status":0,"recordedAt":"2020-12-18T11:56:49.846Z","consignorId":4,"consignorName":null,"consignedAt":null,"deliveredAt":null,"creatorId":null,"updatedAt":"2020-12-30T17:31:50.646Z","createdAt":"2020-12-30T17:31:50.646Z"},{"id":17,"carrierId":2,"externalDocumentId":16,"waybillNumber":"BOL823717","stat<…>
// //flutter: data: {documents: [{id: 20, carrierId: 2, externalDocumentId: 19, waybillNumber: BOL823720, status: 0, recordedAt: 2020-12-26T16:05:08.722Z, consignorId: 3, consignorName: null, consignedAt: null, deliveredAt: null, creatorId: null, updatedAt: 2020-12-30T17:31:50.647Z, createdAt: 2020-12-30T17:31:50.647Z}, {id: 19, carrierId: 2, externalDocumentId: 18, waybillNumber: BOL823719, status: 0, recordedAt: 2020-03-04T10:51:08.436Z, consignorId: 3, consignorName: null, consignedAt: null, deliveredAt: null, creatorId: null, updatedAt: 2020-12-30T17:31:50.646Z, createdAt: 2020-12-30T17:31:50.646Z}, {id: 18, carrierId: 2, externalDocumentId: 17, waybillNumber: BOL823718, status: 0, recordedAt: 2020-12-18T11:56:49.846Z, consignorId: 4, consignorName: null, consignedAt: null, deliveredAt: null, creatorId: null, updatedAt: 2020-12-30T17:31:50.646Z, createdAt: 2020-12-30T17:31:50.646Z}, {id: 17, carrierId: 2, externalDocumentId: 16, waybillNumber: BOL823717, status: 0, recordedAt: 2020-09-15T01:09:2<…>
// //flutter: list: [{id: 20, carrierId: 2, externalDocumentId: 19, waybillNumber: BOL823720, status: 0, recordedAt: 2020-12-26T16:05:08.722Z, consignorId: 3, consignorName: null, consignedAt: null, deliveredAt: null, creatorId: null, updatedAt: 2020-12-30T17:31:50.647Z, createdAt: 2020-12-30T17:31:50.647Z}, {id: 19, carrierId: 2, externalDocumentId: 18, waybillNumber: BOL823719, status: 0, recordedAt: 2020-03-04T10:51:08.436Z, consignorId: 3, consignorName: null, consignedAt: null, deliveredAt: null, creatorId: null, updatedAt: 2020-12-30T17:31:50.646Z, createdAt: 2020-12-30T17:31:50.646Z}, {id: 18, carrierId: 2, externalDocumentId: 17, waybillNumber: BOL823718, status: 0, recordedAt: 2020-12-18T11:56:49.846Z, consignorId: 4, consignorName: null, consignedAt: null, deliveredAt: null, creatorId: null, updatedAt: 2020-12-30T17:31:50.646Z, createdAt: 2020-12-30T17:31:50.646Z}, {id: 17, carrierId: 2, externalDocumentId: 16, waybillNumber: BOL823717, status: 0, recordedAt: 2020-09-15T01:09:20.736Z, cons<…>

//  //using version   1.0.0 with different key names.
//  static Map<Endpoint, String> _responseJsonKeys = {
//    Endpoint.cases: 'cases',
//    Endpoint.casesSuspected: 'data',
//    Endpoint.casesConfirmed: 'data',
//    Endpoint.deaths: 'data',
//    Endpoint.recovered: 'data',
//  };

//class EndpointData {
//  EndpointData({@required this.value, this.date}) : assert(value != null);
//  final int value;
//  final DateTime date;
//
//  @override
//  String toString() => 'date: $date, value: $value';
//}
