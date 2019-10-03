import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_z/models/survey.dart';

class DateTimeComboLinePointChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  DateTimeComboLinePointChart(this.seriesList, {this.animate});

  factory DateTimeComboLinePointChart.withData(Survey survey) {
    return new DateTimeComboLinePointChart(
      _createData(survey),
      animate: false,
    );
  }


  @override
  Widget build(BuildContext context) {
    return new charts.TimeSeriesChart(
      seriesList,
      animate: animate,
      primaryMeasureAxis: new charts.NumericAxisSpec(
        tickProviderSpec: new charts.BasicNumericTickProviderSpec(zeroBound: false),
        renderSpec: charts.GridlineRendererSpec(
          lineStyle: charts.LineStyleSpec(
            dashPattern: [4, 4],
          )
        )
      ),
      domainAxis: new charts.DateTimeAxisSpec(
        tickFormatterSpec: new charts.AutoDateTimeTickFormatterSpec(
          day: new charts.TimeFormatterSpec(
            format: 'd', 
            transitionFormat: 'MM/dd/yyyy'
          )
        )
      )
    );
      // behaviors: [
      //   new charts.ChartTitle(
      //     'Dates',
      //     behaviorPosition: charts.BehaviorPosition.bottom,
      //     titleOutsideJustification: charts.OutsideJustification.middleDrawArea
      //   ),
      //   new charts.ChartTitle(
      //     'Total',
      //     behaviorPosition: charts.BehaviorPosition.start,
      //     titleOutsideJustification: charts.OutsideJustification.middleDrawArea
          
      //   ),
      // ],
      // defaultRenderer: new charts.LineRendererConfig(),
      // customSeriesRenderers: [
      //   new charts.PointRendererConfig(
      //       customRendererId: 'customPoint')
      // ],
      // dateTimeFactory: const charts.LocalDateTimeFactory(),
      // domainAxis: new charts.EndPointsTimeAxisSpec(),
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<SubmissionData, DateTime>> _createData(Survey survey) {
    final date = survey.submissionDates;
    var data = new List<SubmissionData>();
    int count = 0;
    for (var i = 0; i < date.length; i++) {
      var x = date[i];
      DateTime newDate = new DateFormat("yyyy-MM-dd", "en_US").parse(x);
      if (i > 0) {
        for (var j = 0; j < data.length; j++) {
          if (j > 0) {
            if (newDate != data[j-1].time) {
              data.add(new SubmissionData(newDate, count+=1));
            } else {
              var newCount = data[j].sales;
              newCount+=1;
              data[j]= new SubmissionData(newDate, newCount);
            }
          } else if(newDate == data[j].time) {
            var newCount = data[j].sales;
            newCount+=1;
            data[j]= new SubmissionData(newDate, newCount);
          } else {
            data.add(new SubmissionData(newDate, count+=1));
          }
        }
      } else {
        data.add(new SubmissionData(newDate, count+1));
      }
    }

    return [
      new charts.Series<SubmissionData, DateTime>(
        id: 'Sales',
        colorFn: (_, __) => charts.MaterialPalette.white.lighter,
        domainFn: (SubmissionData sales, _) => sales.time,
        measureFn: (SubmissionData sales, _) => sales.sales,
        data: data,
      )
    ];
  }
}

/// Sample time series data type.
class SubmissionData {
  final DateTime time;
  final int sales;

  SubmissionData(this.time, this.sales);
}