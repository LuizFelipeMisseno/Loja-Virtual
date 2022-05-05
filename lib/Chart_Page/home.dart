import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:loja_usuario/Chart_Page/developer_chart.dart';
import 'package:loja_usuario/developer_series.dart';

class ChartPage extends StatefulWidget {
  const ChartPage({Key? key}) : super(key: key);

  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  final List<DeveloperSeries> data = [
    DeveloperSeries(
      ano: 2017,
      desenvolvedores: 30000,
      cor: charts.ColorUtil.fromDartColor(Colors.black),
    ),
    DeveloperSeries(
      ano: 2018,
      desenvolvedores: 5000,
      cor: charts.ColorUtil.fromDartColor(Colors.blue),
    ),
    DeveloperSeries(
      ano: 2019,
      desenvolvedores: 40000,
      cor: charts.ColorUtil.fromDartColor(Colors.red),
    ),
    DeveloperSeries(
      ano: 2020,
      desenvolvedores: 35000,
      cor: charts.ColorUtil.fromDartColor(Colors.pink),
    ),
    DeveloperSeries(
      ano: 2021,
      desenvolvedores: 40000,
      cor: charts.ColorUtil.fromDartColor(Colors.yellow),
    ),
  ];

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gráficos'),
      ),
      body: ListView.builder(
        itemCount: data.length,
        itemBuilder: (BuildContext context, int index) {
          return DeveloperChart(data: data);
        },
      ),
      bottomNavigationBar: bottomBar(),
    );
  }

  bottomBar() {
    return BottomNavigationBar(
      fixedColor: Colors.black,
      currentIndex: selectedIndex, //New
      onTap: _onItemTapped,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Início',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          label: 'Bate-Papo',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ],
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }
}
