import 'dart:convert';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class CovidCount {
  String Tanggal;
  final int Terkonfirmasi;
  final int Kematian;
  final int Sembuh;

  CovidCount(this.Tanggal, this.Terkonfirmasi, this.Kematian, this.Sembuh);
}

class CovidCart extends StatefulWidget {
  @override
  _CovidCartState createState() => _CovidCartState();
}

class _CovidCartState extends State<CovidCart> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: FutureBuilder(
            future: _getData(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  snapshot.hasError == false) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.connectionState == ConnectionState.waiting &&
                  snapshot.hasError == true) {
                return Center(
                  child: Text("Harap Pilih ulang outlet"),
                );
              } else if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasError == true) {
                return Center(
                  child: Text("Harap Pilih ulang outlet"),
                );
              } else if (snapshot.hasError == true) {
                return Center(
                  child: Text("Harap Pilih ulang outlet"),
                );
              } else if (snapshot.hasError == false &&
                  snapshot.data.length < 1) {
                return Center(
                  child: Text("Data Tidak ada"),
                );
              } else {
                return new charts.TimeSeriesChart(
                  dataList(snapshot.data),
                  defaultRenderer:
                      new charts.LineRendererConfig(includePoints: true),
                  selectionModels: [
                    new charts.SelectionModelConfig(
                      type: charts.SelectionModelType.info,
                    )
                  ],
                  layoutConfig: new charts.LayoutConfig(
                      leftMarginSpec: new charts.MarginSpec.fixedPixel(10),
                      topMarginSpec: new charts.MarginSpec.fixedPixel(10),
                      rightMarginSpec: new charts.MarginSpec.fixedPixel(10),
                      bottomMarginSpec: new charts.MarginSpec.fixedPixel(10)),
                  animate: true,
                  behaviors: [
                    new charts.SlidingViewport(),
                    new charts.PanAndZoomBehavior(),
                  ],
                );
              }
            }),
      ),
    );
  }

  static List<charts.Series<CovidCount, DateTime>> dataList(
      List<dynamic> apiData) {
    List<CovidCount> list = new List();
    for (int i = 0; i < apiData.length; i++)
      if (DateFormat("yyyy-MM-dd", "en_US")
          .parse(apiData[i]['Date'])
          .isAfter(DateFormat("yyyy-MM-dd", "en_US").parse('2020-02-01')))
        list.add(new CovidCount(apiData[i]['Date'], apiData[i]['Confirmed'],
            apiData[i]['Deaths'], apiData[i]['Recovered']));
    return [
      new charts.Series<CovidCount, DateTime>(
        id: 'Sembuh',
        domainFn: (CovidCount count, _) =>
            DateFormat("yyyy-MM-dd", "en_US").parse(count.Tanggal).toLocal(),
        measureFn: (CovidCount count, _) => count.Sembuh,
        data: list,
      ),
      new charts.Series<CovidCount, DateTime>(
        id: 'Kematian',
        domainFn: (CovidCount count, _) =>
            DateFormat("yyyy-MM-dd", "en_US").parse(count.Tanggal).toLocal(),
        measureFn: (CovidCount count, _) => count.Kematian,
        data: list,
      ),
      new charts.Series<CovidCount, DateTime>(
        id: 'Terkonfirmasi',
        domainFn: (CovidCount count, _) =>
            DateFormat("yyyy-MM-dd", "en_US").parse(count.Tanggal).toLocal(),
        measureFn: (CovidCount count, _) => count.Terkonfirmasi,
        data: list,
      ),
    ];
  }

  _getData() async {
    final response = await http.get("https://api.covid19api.com/country/ID");
    Iterable data = json.decode(response.body);
    List<dynamic> list = data.toList();
    return list;
  }
}
