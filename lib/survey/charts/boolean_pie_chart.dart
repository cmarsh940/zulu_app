import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:project_z/survey/widgets/question_widget.dart';

class BooleanPieChart extends StatelessWidget {
  final bool boolean;
  final List<charts.Series> seriesList;
  final bool animate;

  BooleanPieChart(this.seriesList, {this.animate, this.boolean});

  factory BooleanPieChart.withData(List<OptionAnswers> options, String dataType) {
    return new BooleanPieChart(
      _createData(options, dataType),
      // Disable animations for image tests.
      animate: false,
    );
  }


  @override
  Widget build(BuildContext context) {
    return new charts.PieChart(
      seriesList,
      animate: animate,
      // Add the series legend behavior to the chart to turn on series legends.
      // By default the legend will display above the chart.
      behaviors: [new charts.DatumLegend()],
    );
  }

  /// Create series list with one series
  static List<charts.Series<ChartData, String>> _createData(List<OptionAnswers> options, String dataType) {
    var data = new List<ChartData>();
    options.forEach((f) {
      if (dataType == 'boolean') {
        if (f.name == 0) {
          data.add(new ChartData('False', f.count));
        } else if (f.name == 1) {
          data.add(new ChartData('True', f.count));
        } else {
          data.add(new ChartData(f.name, f.count));
        }
      } else if (dataType == 'goodbad') {
        if (f.name == 0) {
          data.add(new ChartData('Bad', f.count));
        } else if (f.name == 1) {
          data.add(new ChartData('Good', f.count));
        } else {
          data.add(new ChartData(f.name, f.count));
        }
      } else if (dataType == 'likeunlike') {
        if (f.name == 0) {
          data.add(new ChartData('Unlike', f.count));
        } else if (f.name == 1) {
          data.add(new ChartData('Like', f.count));
        } else {
          data.add(new ChartData(f.name, f.count));
        }
      } else if (dataType == 'yesno') {
        if (f.name == 0) {
          data.add(new ChartData('No', f.count));
        } else if (f.name == 1) {
          data.add(new ChartData('Yes', f.count));
        } else {
          data.add(new ChartData(f.name, f.count));
        }
      } else if (dataType == 'moreless') {
        if (f.name == 0) {
          data.add(new ChartData('Less', f.count));
        } else if (f.name == 1) {
          data.add(new ChartData('More', f.count));
        } else {
          data.add(new ChartData(f.name, f.count));
        }
      } else {
        data.add(new ChartData(f.name, f.count));
      }


    });


    return [
      new charts.Series<ChartData, String>(
        id: 'Boolean_Pie_Data',
        domainFn: (ChartData sales, _) => sales.name,
        measureFn: (ChartData sales, _) => sales.sales,
        data: data,
      )
    ];
  }
}


/// Sample linear data type.
class ChartData {
  final String name;
  final int sales;

  ChartData(this.name, this.sales);
}