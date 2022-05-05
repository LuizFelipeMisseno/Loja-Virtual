import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:loja_usuario/developer_series.dart';

// ignore: must_be_immutable
class DeveloperChart extends StatelessWidget {
  List<DeveloperSeries> data;

  DeveloperChart({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<charts.Series<DeveloperSeries, String>> series = [
      charts.Series(
          id: "desenvolvedores",
          data: data,
          domainFn: (DeveloperSeries series, _) => series.ano.toString(),
          measureFn: (DeveloperSeries series, _) => series.desenvolvedores,
          colorFn: (DeveloperSeries series, _) => series.cor)
    ];

    return Container(
      height: 300,
      padding: const EdgeInsets.all(25),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(9.0),
          child: Column(
            children: <Widget>[
              Text(
                "Yearly Growth in the Flutter Community",
                style: Theme.of(context).textTheme.bodyText1,
              ),
              Expanded(
                child: charts.BarChart(series, animate: false),
              )
            ],
          ),
        ),
      ),
    );
  }
}
