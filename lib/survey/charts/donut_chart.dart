import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:project_z/survey/widgets/question_widget.dart';

class DonutChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  DonutChart(this.seriesList, {this.animate});

  /// Creates a [PieChart] with sample data and no transition.
  factory DonutChart.withData(List<OptionAnswers> options) {
    return new DonutChart(
      _createData(options),
      // Disable animations for image tests.
      animate: false,
    );
  }


  @override
  Widget build(BuildContext context) {
    return new charts.PieChart(seriesList,
        animate: animate,
        // Configure the width of the pie slices to 60px. The remaining space in
        // the chart will be left as a hole in the center.
        //
        // [ArcLabelDecorator] will automatically position the label inside the
        // arc if the label will fit. If the label will not fit, it will draw
        // outside of the arc with a leader line. Labels can always display
        // inside or outside using [LabelPosition].
        //
        // Text style for inside / outside can be controlled independently by
        // setting [insideLabelStyleSpec] and [outsideLabelStyleSpec].
        //
        // Example configuring different styles for inside/outside:
        //       new charts.ArcLabelDecorator(
        //          insideLabelStyleSpec: new charts.TextStyleSpec(...),
        //          outsideLabelStyleSpec: new charts.TextStyleSpec(...)),
        defaultRenderer: new charts.ArcRendererConfig(
            arcWidth: 60,
            arcRendererDecorators: [new charts.ArcLabelDecorator()]));
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<ChartData, String>> _createData(List<OptionAnswers> options) {
    print('options length : ${options.length}');
    var data = new List<ChartData>();
    options.forEach((f) { 
        data.add(new ChartData(f.name, f.count));
    });

    return [
      new charts.Series<ChartData, String>(
        id: 'Donut_Chart',
        domainFn: (ChartData sales, _) => sales.name,
        measureFn: (ChartData sales, _) => sales.sales,
        data: data,
        // Set a label accessor to control the text of the arc label.
        labelAccessorFn: (ChartData row, _) => '${row.name}: ${row.sales}',
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