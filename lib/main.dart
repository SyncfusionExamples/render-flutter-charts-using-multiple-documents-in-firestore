import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<ChartData> chartData = [];

  Future<void> getDataFromFireStore() async {
    chartData.clear();
    var snapShotsValue =
        await FirebaseFirestore.instance.collection('chartData').get();
    chartData.addAll(
        snapShotsValue.docs.map((e) => ChartData.fromJson(e.data())).toList());
    return snapShotsValue as dynamic;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Syncfusion Flutter Chart')),
        body: FutureBuilder(
          future: getDataFromFireStore(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return SfCartesianChart(
                plotAreaBorderWidth: 0,
                legend:
                    Legend(isVisible: true, position: LegendPosition.bottom),
                primaryYAxis: NumericAxis(
                  axisLine: const AxisLine(width: 0),
                  rangePadding: ChartRangePadding.round,
                  majorTickLines: const MajorTickLines(width: 0),
                ),
                primaryXAxis: DateTimeAxis(
                  edgeLabelPlacement: EdgeLabelPlacement.shift,
                  dateFormat: DateFormat('dd-MMM'),
                  majorGridLines: const MajorGridLines(width: 0),
                  majorTickLines: const MajorTickLines(width: 0),
                ),
                series: buildLineSeries(chartData),
              );
            } else {
              return const CircularProgressIndicator();
            }
          },
        ));
  }

  List<LineSeries<SalesData, DateTime>> buildLineSeries(
      List<ChartData> chartData) {
    List<LineSeries<SalesData, DateTime>> series = [];
    List<Color> seriesColor = [
      const Color(0XFFd4862f),
      const Color(0XFFc3c2c2),
      const Color(0XFF07cc67)
    ];
    for (var i = 0; i < chartData.length; i++) {
      series.add(LineSeries<SalesData, DateTime>(
          dataSource: chartData[i].data,
          color: seriesColor[i],
          markerSettings:
              MarkerSettings(isVisible: true, color: seriesColor[i]),
          name: chartData[i].seriesName,
          xValueMapper: (SalesData data, _) => data.date,
          yValueMapper: (SalesData data, _) => data.yValue));
    }
    return series;
  }
}

class ChartData {
  final String seriesName;
  final List<SalesData> data;

  ChartData(
    this.seriesName,
    this.data,
  );

  factory ChartData.fromJson(Map<String, dynamic> parsedJson) {
    List<SalesData> dataPoints = [];
    for (int i = 0; i < parsedJson['value'].length; i++) {
      dataPoints.add(SalesData.fromJson(parsedJson['value']['$i']));
    }
    return ChartData(parsedJson['seriesName'], dataPoints);
  }
}

class SalesData {
  SalesData(this.date, this.yValue);

  final DateTime date;
  final int yValue;

  factory SalesData.fromJson(Map<String, dynamic> parsedJson) {
    return SalesData(DateFormat("yyyy-MM-dd").parse(parsedJson['date']),
        parsedJson['yValue']);
  }
}
