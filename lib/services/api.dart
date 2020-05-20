import 'package:covid19/services/api_keys.dart';
import 'package:flutter/foundation.dart';

//this file list all the endpoints and Production and Sandbox Endpoints
//Production and Sandbox URLs

//the orders matters because we will loop through it
enum Endpoint {
  cases,
  active,
  recovered,
  deaths,
  todayCases,
  todayDeaths,
}

class API {
  API({@required this.apiKey});
  final String apiKey;

  //this is a little helper when we create instances of this class
  //we name this as API.sandbox()
  factory API.sandbox() => API(apiKey: APIKeys.ncovSandboxKey);

  //then we create initialized static variables
  ////URL Syntax: http/https://host              :port/path?queryParameters
  //  //e.g.          https://apigw.nubentos.com:443/cases
  static final String host = 'apigw.nubentos.com';
  static final int port = 443;
  static final String basePath = 't/nubentos.com/ncovapi/2.0.0';

  //then we create a new method which will return a value with the type Uri
  //we use this to return a new Uri object with the following arguments:
  //Uniform Resource Identifier, it's used to uniquely identify resources on the Web
  //The Uri class provide functions to encode and decode strings for use in URIs (which also known as URLs)
  //so what we are doing here is to define a resource identifier that we will use to get the access token

  //port number is optional, and path is to identify the resources we want from the host
  // we can just use a string, this is safer, we should add .toString() but we will do so in other steps

  //URL Syntax: http/https://host               :port/path?queryParameters
  //https://apigw.nubentos.com:443/token?grant_type=client_credentials
  Uri tokenUri() => Uri(
        scheme: 'https',
        host: host, //'apigw.nubentos.com'
        port: port, //443
        path: 'token',
        queryParameters: {'grant_type': 'client_credentials'},
      );
  //https://apigw.nubentos.com:443/t/nubentos.com/ncovapi/2.0.0/cases'
  Uri endpointUri(Endpoint endpoint) => Uri(
        scheme: 'https',
        host: host,
        port: port,
        path: '$basePath/${_paths[endpoint]}',
      );

  //the orders matters because we will loop through it
  static Map<Endpoint, String> _paths = {
    Endpoint.cases: 'cases',
    Endpoint.active: 'active',
    Endpoint.recovered: 'recovered',
    Endpoint.deaths: 'deaths',
    Endpoint.todayCases: 'todayCases',
    Endpoint.todayDeaths: 'todayDeaths',
  };
}
