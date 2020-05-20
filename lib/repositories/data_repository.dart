import 'package:covid19/services/api.dart';
import 'package:covid19/services/api_service.dart';
import 'package:covid19/services/data_cache_service.dart';
import 'package:covid19/services/endpoint_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'endpoints_data.dart';

//this file is our presentation & logic layer,directly deals with UI

class DataRepository {
  DataRepository({@required this.apiService, @required this.dataCacheService});
  final APIService apiService;
  final DataCacheService dataCacheService;

  String _accessToken;

  //we changed api service to return EndpointData instead of int, so we need to
  //change here too.
  Future<EndpointData> getEndpointData(Endpoint endpoint) async =>
      await _getDataRefreshingToken<EndpointData>(
        onGetData: () => apiService.getEndpointData(
            accessToken: _accessToken, endpoint: endpoint),
      );

//  //this is the function we use in UI
//  Future<EndpointsData> getAllEndpointsData() async =>
//      await _getDataRefreshingToken<EndpointsData>(
//        onGetData: () => _getAllEndPointData(),
//      );

  //change above to below:

  EndpointsData getAllEndpointsCachedData() => dataCacheService.getData();

  Future<EndpointsData> getAllEndpointsData() async {
    final endpointsData = await _getDataRefreshingToken<EndpointsData>(
      onGetData: _getAllEndpointsData,
    );
    // save to cache
    await dataCacheService.setData(endpointsData);
    return endpointsData;
  }

//  //the following is first version:
//  Future<int> getEndPointData(Endpoint endpoint) async {
//    //we want to generate a new accessToken only if previous one expires
//    try {
//      if (_accessToken == null) {
//        //here we use our method in apiService
//        _accessToken = await apiService.getAccessToken();
//      }
//      //here we use our method in apiService
//      return await apiService.getEndPointData(
//        accessToken: _accessToken,
//        endpoint: endpoint,
//      );
//    } on Response catch (response) {
//      //if unauthorized, get access token again
//      if (response.statusCode == 401) {
//        _accessToken = await apiService.getAccessToken();
//        //call getEndPointData method in apiService
//        return await apiService.getEndPointData(
//          accessToken: _accessToken,
//          endpoint: endpoint,
//        );
//      }
//      rethrow;
//    }
//  }

  //create a generic method for all the common code
  //this is a function that return a future of generic type T, and it takes an
  // argument which is a function called onGetData, also return Future<T> type

  //                                             this is a function argument
  Future<T> _getDataRefreshingToken<T>({Future<T> Function() onGetData}) async {
    //we want to generate a new accessToken only if previous one expires
    try {
      if (_accessToken == null) {
        //here we use our method in apiService
        _accessToken = await apiService.getAccessToken();
      }
      return await onGetData();
    } on Response catch (response) {
      // if unauthorized, get access token again
      if (response.statusCode == 401) {
        _accessToken = await apiService.getAccessToken();
        return await onGetData();
      }
      rethrow;
    }
  }

  Future<EndpointsData> _getAllEndpointsData() async {
    //all futures execute in parallel
    //when all futures have completed, results is returned.

    //this returns a List<int>
    final values = await Future.wait([
      apiService.getEndpointData(
          accessToken: _accessToken, endpoint: Endpoint.cases),
      apiService.getEndpointData(
          accessToken: _accessToken, endpoint: Endpoint.active),
      apiService.getEndpointData(
          accessToken: _accessToken, endpoint: Endpoint.deaths),
      apiService.getEndpointData(
          accessToken: _accessToken, endpoint: Endpoint.recovered),
      apiService.getEndpointData(
          accessToken: _accessToken, endpoint: Endpoint.todayCases),
      apiService.getEndpointData(
          accessToken: _accessToken, endpoint: Endpoint.todayDeaths),
    ]);
    //EndPointsData is a class that takes a Map<Endpoint, EndPointsData> values
    return EndpointsData(
      values: {
        Endpoint.cases: values[0],
        Endpoint.active: values[1],
        Endpoint.deaths: values[2],
        Endpoint.recovered: values[3],
        Endpoint.todayCases: values[4],
        Endpoint.todayDeaths: values[5],
      },
    );
  }
}
