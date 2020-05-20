import 'package:covid19/services/api.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EndPointCardData {
  EndPointCardData(this.title, this.assetName, this.color);
  final String title;
  final String assetName;
  final Color color;
}

class EndPointCard extends StatelessWidget {
  const EndPointCard({Key key, this.endpoint, this.value}) : super(key: key);
  final Endpoint endpoint;
  final int value;

  static Map<Endpoint, EndPointCardData> _cardsData = {
    Endpoint.cases:
        EndPointCardData('Cases', 'assets/count.png', Color(0xFFFFF492)),
    Endpoint.active: EndPointCardData(
        'Active cases', 'assets/suspect.png', Color(0xFFEEDA28)),
    Endpoint.deaths:
        EndPointCardData('Deaths', 'assets/death.png', Color(0xFFE40000)),
    Endpoint.recovered:
        EndPointCardData('Recovered', 'assets/patient.png', Color(0xFF70A901)),
    Endpoint.todayCases:
        EndPointCardData('Today Cases', 'assets/fever.png', Color(0xFFE99600)),
    Endpoint.todayDeaths:
        EndPointCardData('Today Deaths', 'assets/death.png', Color(0xFFE40000)),
  };

  // from intl package
  String get formattedValue {
    if (value == null) {
      return '';
    }
    return NumberFormat('#,###,###,###').format(value);
  }

  @override
  Widget build(BuildContext context) {
    final cardData = _cardsData[endpoint]; //key value
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                cardData.title,
                //we use TextTheme class
                style: Theme.of(context)
                    .textTheme
                    .headline5
                    .copyWith(color: cardData.color),
              ),
              SizedBox(height: 4),
              SizedBox(
                height: 52, //this makes the card row higher
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Image.asset(cardData.assetName, color: cardData.color),
//              Text(value != null ? value.toString() : ''),
//              //this is the same as:
//              Text(value?.toString() ?? ''),
                    Text(
                      formattedValue,
                      style: Theme.of(context).textTheme.headline4.copyWith(
                          color: cardData.color, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
