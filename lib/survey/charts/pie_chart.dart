import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:project_z/survey/widgets/question_widget.dart';

class BooleanPieChart extends StatelessWidget {
  final bool boolean;
  final List<charts.Series> seriesList;
  final bool animate;

  BooleanPieChart(this.seriesList, {this.animate, this.boolean});

  factory BooleanPieChart.withData(List<OptionAnswers> options) {
    return new BooleanPieChart(
      _createData(options),
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
  static List<charts.Series<ChartData, String>> _createData(List<OptionAnswers> options) {
    print('options length : ${options.length}');
    var data = new List<ChartData>();
    options.forEach((f) { 
        data.add(new ChartData(f.name, f.count));
    });


    return [
      new charts.Series<ChartData, String>(
        id: 'Pie_Data',
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