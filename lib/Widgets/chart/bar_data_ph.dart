import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mobile_gmf/Models/avarage_ph.dart';


class BarDataPh {
  final List<BarChartGroupData> barData = [];

  BarDataPh();

  void initializeBarData(List<HourlyPh> HourlyPh) {
    barData.clear();

    for (var HourlyPh in HourlyPh) {
      final PhData = HourlyPh.averagePhtanah;
      print(
          'Adding BarData: hour=${HourlyPh.hour}, ph_tanah=$PhData');

      barData.add(
        BarChartGroupData(
          x: HourlyPh.hour,
          barRods: [
            BarChartRodData(
              toY: PhData,
              color: Color.fromRGBO(224, 141, 7, 1),
              width: 14,
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: 100,
                color: Colors.grey.withOpacity(0.2),
              ),
            ),
          ],
        ),
      );
    }
  }
}
