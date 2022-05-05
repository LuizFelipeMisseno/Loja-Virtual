import 'package:charts_flutter/flutter.dart' as charts;

class DeveloperSeries {
  final int ano;
  final int desenvolvedores;
  final charts.Color cor;

  DeveloperSeries(
      {required this.ano, required this.desenvolvedores, required this.cor});
}
