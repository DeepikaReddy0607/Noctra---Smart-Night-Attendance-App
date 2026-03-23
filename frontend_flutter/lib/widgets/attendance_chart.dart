import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AttendanceChart extends StatelessWidget {

  final List<int> weeklyData;

  const AttendanceChart({
    super.key,
    required this.weeklyData,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        border: Border.all(
            color: Colors.white10,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text(
            "Weekly Attendance",
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            "1 = Present   0 = Absent",
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 220,

            child: LineChart(
                duration: const Duration(milliseconds: 800),
              LineChartData(

                minY: 0,
                maxY: 1,

                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.white10,
                      strokeWidth: 1,
                    );
                  },
                ),

                borderData: FlBorderData(show: false),

                titlesData: FlTitlesData(

                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {

                        if(value == 0){
                          return const Text(
                            "A",
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                            ),
                          );
                        }

                        if(value == 1){
                          return const Text(
                            "P",
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                            ),
                          );
                        }

                        return const SizedBox();
                      },
                    ),
                  ),

                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),

                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),

                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,

                      getTitlesWidget: (value, meta) {

                        const days = [
                          "Mon","Tue","Wed","Thu","Fri","Sat","Sun"
                        ];

                        if(value.toInt() >= days.length){
                          return const SizedBox();
                        }

                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            days[value.toInt()],
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot)=> const Color(0xFF1E293B),
                    getTooltipItems: (touchedSpots) {

                      return touchedSpots.map((spot){

                        String status =
                            spot.y == 1 ? "Present" : "Absent";

                        return LineTooltipItem(
                          status,
                          const TextStyle(
                            color: Colors.white,
                          ),
                        );

                      }).toList();
                    },
                  ),
                ),

                lineBarsData: [

                  LineChartBarData(

                    spots: List.generate(
                      weeklyData.length,
                      (index) => FlSpot(
                        index.toDouble(),
                        weeklyData[index].toDouble(),
                      ),
                    ),

                    isCurved: true,

                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF6366F1),
                        Color(0xFF3B82F6),
                      ],
                    ),

                    barWidth: 4,

                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) {
                        return FlDotCirclePainter(
                          radius: 3,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: Colors.blueAccent,
                        );
                      },
                    ),

                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          Colors.blueAccent.withOpacity(0.25),
                          Colors.transparent,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}