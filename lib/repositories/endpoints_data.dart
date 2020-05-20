import 'package:covid19/services/api.dart';
import 'package:covid19/services/endpoint_data.dart';
import 'package:flutter/foundation.dart';

class EndpointsData {
  EndpointsData({@required this.values});
  //Endpoint is enum, EndPointData
  //previously we only return int from api service, now we changed int to EndpointData
  Map<Endpoint, EndpointData> values;

  //this is optional to make EndPointsData easier to query:
  EndpointData get cases => values[Endpoint.cases];
  EndpointData get active => values[Endpoint.active];
  EndpointData get deaths => values[Endpoint.deaths];
  EndpointData get recovered => values[Endpoint.recovered];
  EndpointData get todayCases => values[Endpoint.todayCases];
  EndpointData get todayDeaths => values[Endpoint.todayDeaths];

  //also optional
  @override
  String toString() => 'cases: $cases, active: $active, deaths: $deaths, '
      'recovered: $recovered, todayCases: $todayCases, todayDeaths: $todayDeaths';
}
