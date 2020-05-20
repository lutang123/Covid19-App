import 'package:covid19/repositories/data_repository.dart';
import 'package:covid19/services/api.dart';
import 'package:covid19/services/api_service.dart';
import 'package:covid19/services/data_cache_service.dart';
import 'package:covid19/ui/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //the default is US, we can adjust here
  Intl.defaultLocale = 'en_GB';
//  //there're two initializeDateFormatting() from different package
//  //package:intl/date_symbol_data_http_request.dart Future<void> initializeDateFormatting(String locale, String url)
  //package:intl/date_symbol_data_local.dart Future<void> initializeDateFormatting([String locale, String ignored])
  await initializeDateFormatting();

  final sharedPreferences = await SharedPreferences.getInstance();
  runApp(MyApp(sharedPreferences: sharedPreferences));
}

class MyApp extends StatelessWidget {
  const MyApp({Key key, @required this.sharedPreferences}) : super(key: key);
  final SharedPreferences sharedPreferences;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Provider<DataRepository>(
      //we do not need the context, so we can use _
      create: (_) => DataRepository(
        apiService: APIService(API.sandbox()),
        dataCacheService: DataCacheService(
          sharedPreferences: sharedPreferences,
        ),
      ),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Coronavirus Tracker',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: Color(0xFF101010),
          cardColor: Color(0xFF222222),
        ),
        home: Dashboard(),
      ),
    );
  }
}

//class MyHomePage extends StatefulWidget {
//  MyHomePage({Key key, this.title}) : super(key: key);
//
//  final String title;
//
//  @override
//  _MyHomePageState createState() => _MyHomePageState();
//}
//
//class _MyHomePageState extends State<MyHomePage> {
////  int _endPointData = 0;
////or we not give initial value
//  int _cases;
//  int _deaths;
//
////  void _updateAccessToken() async {
////    //APIService takes API, and API takes apiKey,
////    //factory API.sandbox() => API(apiKey: APIKeys.ncovSandboxKey);
////    final apiService = APIService(API.sandbox());
////    final accessToken = await apiService.getAccessToke();
////    setState(() {
////      _accessToken = accessToken;
////    });
////  }
//
//  void _getEndPointData() async {
//    final apiService = APIService(API.sandbox());
//    final accessToken = await apiService.getAccessToke();
//    final cases = await apiService.getEndPointData(
//      accessToken: accessToken,
//      endpoint: Endpoint.cases,
//    );
//    final deaths = await apiService.getEndPointData(
//      accessToken: accessToken,
//      endpoint: Endpoint.deaths,
//    );
//    setState(() {
//      _cases = cases;
//      _deaths = deaths;
//    });
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    // This method is rerun every time setState is called, for instance as done
//    // by the _incrementCounter method above.
//    //
//    // The Flutter framework has been optimized to make rerunning build methods
//    // fast, so that you can just rebuild anything that needs updating rather
//    // than having to individually change instances of widgets.
//    return Scaffold(
//      appBar: AppBar(
//        // Here we take the value from the MyHomePage object that was created by
//        // the App.build method, and use it to set our appbar title.
//        title: Text(widget.title),
//      ),
//      body: Center(
//        // Center is a layout widget. It takes a single child and positions it
//        // in the middle of the parent.
//        child: Column(
//          mainAxisAlignment: MainAxisAlignment.center,
//          children: <Widget>[
//            Text(
//              'You have pushed the button this many times:',
//            ),
//            //this is collection if, not the regular if
//            if (_cases != null)
//              Text(
//                'cases: $_cases',
//                style: Theme.of(context).textTheme.headline4,
//              ),
//            if (_deaths != null)
//              Text(
//                'deaths: $_deaths',
//                style: Theme.of(context).textTheme.headline4,
//              ),
//          ],
//        ),
//      ),
//      floatingActionButton: FloatingActionButton(
//        onPressed: _getEndPointData,
//        tooltip: 'Increment',
//        child: Icon(Icons.add),
//      ), // This trailing comma makes auto-formatting nicer for build methods.
//    );
//  }
//}
