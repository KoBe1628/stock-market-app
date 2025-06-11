import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CoinChart extends StatelessWidget {
  final bool isRed;

  const CoinChart({super.key, this.isRed = false});

  @override
  Widget build(BuildContext context) {
    final List<FlSpot> dataPoints = [
      FlSpot(0, isRed ? 1540 : 84100),
      FlSpot(1, isRed ? 1542 : 84250),
      FlSpot(2, isRed ? 1530 : 84000),
      FlSpot(3, isRed ? 1533 : 84150),
      FlSpot(4, isRed ? 1538 : 84300),
      FlSpot(5, isRed ? 1537 : 84220),
      FlSpot(6, isRed ? 1545 : 84450),
      FlSpot(7, isRed ? 1546 : 84500),
      FlSpot(8, isRed ? 1541 : 84146),
    ];

    return LineChart(
      LineChartData(
        minY: isRed ? 1525 : 83900,
        maxY: isRed ? 1550 : 84600,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, _) {
                const times = ['10', '11', '12', '13', '14', '15', '16', '17', '18'];
                if (value >= 0 && value < times.length) {
                  return Text('${times[value.toInt()]}:00', style: const TextStyle(fontSize: 10));
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: dataPoints,
            isCurved: true,
            color: isRed ? Colors.red : Colors.green,
            barWidth: 3,
            belowBarData: BarAreaData(
              show: true,
              color: (isRed ? Colors.red : Colors.green).withOpacity(0.2),
            ),
            dotData: FlDotData(show: true),
          ),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.white,
            tooltipRoundedRadius: 8,
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  isRed
                      ? '\$${spot.y.toStringAsFixed(2)}'
                      : '\$${(spot.y / 1000).toStringAsFixed(2)}K',
                  const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}
