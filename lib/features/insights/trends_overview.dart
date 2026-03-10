import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/models.dart';
import '../export/export_config.dart';
import 'symptom_trends.dart';
import '../../screens/calendar_screen.dart';
import 'package:fl_chart/fl_chart.dart';

class TrendsOverview extends StatelessWidget {
  const TrendsOverview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Trends & Insights', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined, size: 22),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const CalendarScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.ios_share, size: 22),
            onPressed: () {
               Navigator.push(context, MaterialPageRoute(builder: (context) => const ExportConfig()));
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            _buildTimeSegment(),
            const SizedBox(height: 24),
            _buildChartCard(appState),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SymptomTrends())),
                  child: _buildTopSymptomsCard(appState)
                )),
                const SizedBox(width: 16),
                Expanded(child: _buildConsistencyCard()),
              ],
            ),
            const SizedBox(height: 16),
            _buildWellnessInsightCard(),
            const SizedBox(height: 16),
            _buildGenerateReportCard(context),
            const SizedBox(height: 80), // For bottom nav
          ],
        ),
      ),
    );
  }

  Widget _buildGenerateReportCard(BuildContext context) {
     return InkWell(
       onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ExportConfig())),
       child: Container(
         padding: const EdgeInsets.all(20),
         decoration: BoxDecoration(
           color: AppTheme.primaryPink.withValues(alpha: 0.1),
           borderRadius: BorderRadius.circular(24),
           border: Border.all(color: AppTheme.primaryPink.withValues(alpha: 0.3)),
         ),
         child: Row(
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
             Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 const Text('Monthly Summary', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                 const SizedBox(height: 4),
                 Text('Generate exportable health report', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
               ],
             ),
             Container(
               padding: const EdgeInsets.all(10),
               decoration: BoxDecoration(color: AppTheme.primaryPink, shape: BoxShape.circle),
               child: const Icon(Icons.picture_as_pdf, color: Colors.white, size: 20),
             )
           ],
         ),
       ),
     );
  }

  // Other widgets (time segment, chart, symptoms) remain exactly the same as previously defined, just ensuring they use updated .withValues(alpha:)
  Widget _buildTimeSegment() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildSegmentItem('Weekly', false),
          _buildSegmentItem('Monthly', false),
          _buildSegmentItem('Cycle', true),
        ],
      ),
    );
  }

  Widget _buildSegmentItem(String label, bool isSelected) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryPink : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryPink.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textMuted,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildChartCard(AppState appState) {
    final energyData = appState.energyChartData;
    final moodData = appState.moodChartData;
    
    final energySpots = List.generate(28, (i) => FlSpot(i.toDouble(), energyData[i]));
    final moodSpots = List.generate(28, (i) => FlSpot(i.toDouble(), moodData[i]));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('HORMONAL PATTERNS', style: TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  const SizedBox(height: 4),
                  const Text('Energy & Mood', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('+12%', style: TextStyle(color: AppTheme.primaryPink, fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('VS LAST CYCLE', style: TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              )
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildLegendItem(AppTheme.primaryPink, 'Energy'),
              const SizedBox(width: 12),
              _buildLegendItem(AppTheme.phaseOvulatory, 'Mood'),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  drawHorizontalLine: false,
                  verticalInterval: 7,
                  getDrawingVerticalLine: (value) {
                    return FlLine(color: AppTheme.borderSubtle, strokeWidth: 1, dashArray: [4, 4]);
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(),
                  topTitles: const AxisTitles(),
                  leftTitles: const AxisTitles(),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 7,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const Text('Day 1', style: TextStyle(color: AppTheme.textMuted, fontSize: 10));
                        if (value == 13) return const Text('Day 14', style: TextStyle(color: AppTheme.textMuted, fontSize: 10));
                        if (value == 27) return const Text('Day 28', style: TextStyle(color: AppTheme.textMuted, fontSize: 10));
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0, maxX: 27, minY: 0, maxY: 10,
                lineBarsData: [
                  LineChartBarData(
                    spots: moodSpots,
                    isCurved: true, color: AppTheme.phaseOvulatory, barWidth: 4, isStrokeCapRound: true,
                    dotData: const FlDotData(show: false), belowBarData: BarAreaData(show: false), dashArray: [8, 4],
                  ),
                  LineChartBarData(
                    spots: energySpots,
                    isCurved: true, color: AppTheme.primaryPink, barWidth: 4, isStrokeCapRound: true,
                    dotData: const FlDotData(show: false), belowBarData: BarAreaData(show: true, color: AppTheme.primaryPink.withValues(alpha: 0.1)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('MENSTRUAL', style: TextStyle(color: AppTheme.phaseMenstrual, fontSize: 9, fontWeight: FontWeight.bold)),
              Text('FOLLICULAR', style: TextStyle(color: AppTheme.phaseFollicular, fontSize: 9, fontWeight: FontWeight.bold)),
              Text('OVULATORY', style: TextStyle(color: AppTheme.phaseOvulatory, fontSize: 9, fontWeight: FontWeight.bold)),
              Text('LUTEAL', style: TextStyle(color: AppTheme.phaseLuteal, fontSize: 9, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
      ],
    );
  }

  Widget _buildTopSymptomsCard(AppState appState) {
    final topSymptomsList = appState.topSymptoms.take(3).toList();
    final totalLogs = appState.logs.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Top Symptoms', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (topSymptomsList.isEmpty)
             Text("No symptoms logged yet.", style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
          ...topSymptomsList.map((entry) {
             final percent = totalLogs > 0 ? (entry.value / totalLogs) : 0.0;
             final percentText = '${(percent * 100).round()}%';
             return Padding(
               padding: const EdgeInsets.only(bottom: 12),
               child: _buildSymptomBar(entry.key, percent, percentText),
             );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildSymptomBar(String label, double percent, String percentText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
            Text(percentText, style: TextStyle(color: AppTheme.primaryPink, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: percent,
          backgroundColor: AppTheme.background,
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryPink),
          minHeight: 4,
          borderRadius: BorderRadius.circular(2),
        ),
      ],
    );
  }

  Widget _buildConsistencyCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.topLeft,
            child: Text('Consistency', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),
          Stack(
            alignment: Alignment.center,
            children: [
               SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: 0.85,
                  strokeWidth: 8,
                  backgroundColor: AppTheme.background,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.phaseFollicular),
                ),
              ),
              Column(
                children: [
                  const Text('85', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  Text('SCORE', style: TextStyle(color: AppTheme.textMuted, fontSize: 8, fontWeight: FontWeight.bold)),
                ],
              )
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'High predictability for next cycle',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildWellnessInsightCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryPink.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lightbulb, color: AppTheme.primaryPink, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Wellness Insight', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  'Your energy peaks around day 14. This is the optimal time for high-intensity workouts or big projects.',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 13, height: 1.4),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
