import 'dart:io';

import 'package:covid19/repositories/data_repository.dart';
import 'package:covid19/repositories/endpoints_data.dart';
import 'package:covid19/services/api.dart';
import 'package:covid19/ui/last_updated_status_text.dart';
import 'package:covid19/ui/show_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'endpoint_card.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  //_endpointsData has a property called values and its type is: Map<Endpoint, EndpointData>
  EndpointsData _endpointsData;

  //the following is not good because this requires multi API calls one by one
//  int _cases;
//  int _active;
//  int _deaths;
//  int _recovered;
//  int _todayCases;
//  int _todayDeaths;

  @override
  void initState() {
    super.initState();
    //we first get cached data from shared preference, otherwise we may open with a non-data screen
    final dataRepository = Provider.of<DataRepository>(context, listen: false);
    _endpointsData = dataRepository.getAllEndpointsCachedData();
    //then we call this api method
    _updateData();
  }

  Future<void> _updateData() async {
    //this is to prevent connection problem
    try {
      final dataRepository =
          Provider.of<DataRepository>(context, listen: false);
      final endpointsData = await dataRepository.getAllEndpointsData();
      setState(() => _endpointsData = endpointsData);
      //SocketException from dart:io
      //if we say catch(e) and we don't need to use the e, we can replace as _
    } on SocketException catch (_) {
      showAlertDialog(
        context: context,
        title: 'Connection Error',
        content: 'Could not retrieve data. Please try again later.',
        defaultActionText: 'OK',
      );
    }
    //this is to handle other type of error that are not wifi problem
    catch (_) {
      showAlertDialog(
        context: context,
        title: 'Unknown Error',
        content: 'Please contact support or try again later.',
        defaultActionText: 'OK',
      );
    }
  }

//  Future<void> _updateData() async {
//    //we are inside state class so we can always get the context and
//    // we use listen as false to ensure we don't register our dashboard state
//    final dataRepository = Provider.of<DataRepository>(context, listen: false);
//
//    // await dataRepository.getAllEndPointsData() function returns sth. like this:
//    //return EndPointsData(
//    //      values: {
//    //        Endpoint.cases: values[0],
//    //        Endpoint.active: values[1],
//    //        Endpoint.deaths: values[2],
//    //        Endpoint.recovered: values[3],
//    //        Endpoint.todayCases: values[4],
//    //        Endpoint.todayDeaths: values[5],
//    //      },
//    //    );
//    endpointsData = await dataRepository.getAllEndpointsData();
//
//    //this is not good either, we can only get values, we still have
//    //to create each EndPointCard manually because the endpoint name
//    //is different
//
////    final values = await Future.wait([
////      dataRepository.getEndPointData(Endpoint.cases),
////      dataRepository.getEndPointData(Endpoint.active),
////      dataRepository.getEndPointData(Endpoint.deaths),
////      dataRepository.getEndPointData(Endpoint.recovered),
////      dataRepository.getEndPointData(Endpoint.todayCases),
////      dataRepository.getEndPointData(Endpoint.todayDeaths),
////    ]);
//
//    //this following code is not good because the code is execute sequentially,
//    //so we are waiting one by one.
//
////    _cases = await dataRepository.getEndPointData(Endpoint.cases);
////    _active = await dataRepository.getEndPointData(Endpoint.active);
////    _deaths = await dataRepository.getEndPointData(Endpoint.deaths);
////    _recovered = await dataRepository.getEndPointData(Endpoint.recovered);
////    _todayCases = await dataRepository.getEndPointData(Endpoint.todayCases);
////    _todayDeaths = await dataRepository.getEndPointData(Endpoint.todayDeaths);
//  }

//  void _getEndPointData() async {
//    //APIService(this.api)
//    //API({@required this.apiKey});
//    //factory API.sandbox() => API(apiKey: APIKeys.ncovSandboxKey);
//    DataRepository _dataRepository = DataRepository(
//      apiService: APIService(
//        API.sandbox(),
//      ),
//    );
//
//    final cases = await _dataRepository.getEndPointData(Endpoint.cases);
//    final deaths = await _dataRepository.getEndPointData(Endpoint.deaths);
//    final active = await _dataRepository.getEndPointData(Endpoint.active);
////    final recovered = await _dataRepository.getEndPointData(Endpoint.recovered);
////    final todayCases =
////        await _dataRepository.getEndPointData(Endpoint.todayCases);
////    final todayDeaths =
////        await _dataRepository.getEndPointData(Endpoint.todayDeaths);
////    final totalTests =
////        await _dataRepository.getEndPointData(Endpoint.totalTests);
//
//    setState(() {
//      _cases = cases;
//      _deaths = deaths;
//      _active = active;
////      _recovered = recovered;
////      _todayCases = todayCases;
////      _todayDeaths = todayDeaths;
////      _totalTests = totalTests;
//    });
//  }

  @override
  Widget build(BuildContext context) {
    final formatter = LastUpdatedDateFormatter(
      lastUpdated: _endpointsData != null
          ? _endpointsData.values[Endpoint.cases]?.date
          : null,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text('Coronavirus Tracker'),
      ),
      body: RefreshIndicator(
        onRefresh: _updateData,
        child: ListView(
          children: <Widget>[
            LastUpdatedStatusText(
              text: formatter.lastUpdatedStatusText(),
//              text: endpointsData != null
//                  //endpointsData.values[endpoint] is EndpointData
//                  // ?.date means is to ask if the date is null,
//                  // ?? '' means if it is null, we return ''
//                  ? endpointsData.values[Endpoint.cases].date?.toString() ?? ''
//                  : '',
            ),
            for (var endpoint in Endpoint.values)
              //    //enum Endpoint {
              //            //  cases,
              //            //  active,
              //            //  recovered,
              //            //  deaths,
              //            //  todayCases,
              //            //  todayDeaths,
              //            //}
              EndPointCard(
                endpoint: endpoint,
                value: _endpointsData != null
                    //endpointsData.values[endpoint] is EndpointData
                    //here we add ? in front of .value, meaning only if
                    // _endpointsData.values[endpoint] is not null, we get it's value
                    //otherwise we might get a common error saying getter is null ...
                    ? _endpointsData.values[endpoint]?.value
                    : null,
              ),

            //endPointData is this:
            //class EndPointData {
            //  EndPointData({@required this.value, this.date}) : assert(value != null);
            //  final int value;
            //  final DateTime date;
            //}

            //endPointsData looks like this:
            //return EndPointsData(
            //      values: {
            //        Endpoint.cases: values[0],
            //        Endpoint.active: values[1],
            //        Endpoint.deaths: values[2],
            //        Endpoint.recovered: values[3],
            //        Endpoint.todayCases: values[4],
            //        Endpoint.todayDeaths: values[5],
            //      },
            //    );

//            EndpointCard(
//              endpoint: Endpoint.active,
//              value: _active,
//            ),
//            EndpointCard(
//              endpoint: Endpoint.deaths,
//              value: _deaths,
//            ),
//            EndpointCard(
//              endpoint: Endpoint.recovered,
//              value: _recovered,
//            ),
//            EndpointCard(
//              endpoint: Endpoint.todayCases,
//              value: _todayCases,
//            ),
//            EndpointCard(
//              endpoint: Endpoint.todayDeaths,
//              value: _todayDeaths,
//            ),
          ],
        ),
      ),
    );
  }
}
