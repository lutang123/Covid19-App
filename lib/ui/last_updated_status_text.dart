import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LastUpdatedDateFormatter {
  LastUpdatedDateFormatter({@required this.lastUpdated});
  final DateTime lastUpdated;

  String lastUpdatedStatusText() {
    if (lastUpdated != null) {
      final formatter = DateFormat.yMd().add_Hms(); //hours, minutes, seconds
      final formatted = formatter.format(lastUpdated);
      return 'Last updated: $formatted';
    }
    //this is to handle the case date is not available
    return '';
  }
}

class LastUpdatedStatusText extends StatelessWidget {
  const LastUpdatedStatusText({Key key, @required this.text}) : super(key: key);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
      ),
    );
  }
}
