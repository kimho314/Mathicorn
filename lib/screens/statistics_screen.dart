import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/statistics_provider.dart';
import '../models/statistics.dart';
import '../providers/auth_provider.dart';
import 'package:fl_chart/fl_chart.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.isLoggedIn && auth.user != null) {
        Provider.of<StatisticsProvider>(context, listen: false)
            .fetchStatistics(auth.user!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StatisticsProvider>(
      builder: (context, statisticsProvider, child) {
        if (statisticsProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (statisticsProvider.error != null) {
          return Center(child: Text('에러: \n${statisticsProvider.error}'));
        }
        final stats = statisticsProvider.statistics;
        if (stats == null) {
          return const Center(child: Text('통계 데이터가 없습니다.'));
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('\ud83d\udcca My Statistics'),
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF8ED6FB), // sky blue
                  Color(0xFFA0EACF), // light green
                ],
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 상단 카드
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _StatCard(
                        icon: Icons.psychology,
                        label: 'Total Solved',
                        value: '${stats.totalSolved} problems',
                      ),
                      _StatCard(
                        icon: Icons.check_circle,
                        label: 'Accuracy',
                        value: '${stats.averageAccuracy.toStringAsFixed(1)}%',
                      ),
                      _StatCard(
                        icon: Icons.timer,
                        label: 'Avg. Time',
                        value: '${stats.averageTimePerQuestion.toStringAsFixed(1)}s',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // 일별 학습량 차트 (BarChart)
                  _SectionTitle(title: '📈 Daily Activity'),
                  SizedBox(
                    height: 180,
                    child: _DailyActivityBarChart(dailyActivity: stats.dailyActivity),
                  ),
                  const SizedBox(height: 16),
                  // 연산별 정확도 차트 (PieChart)
                  _SectionTitle(title: '📊 Operation Accuracy'),
                  SizedBox(
                    height: 140,
                    child: _OperationAccuracyPieChart(
                      operationAccuracy: stats.operationAccuracy,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 레벨별 정확도 차트 (LineChart)
                  _SectionTitle(title: '🔢 Level Accuracy'),
                  SizedBox(
                    height: 140,
                    child: _LevelAccuracyLineChart(
                      levelAccuracy: stats.levelAccuracy,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _StatCard({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.25),
            Colors.white.withOpacity(0.10),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(offset: Offset(1,1), blurRadius: 2, color: Colors.black12)])),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16, color: Colors.white)),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _DailyActivityBarChart extends StatelessWidget {
  final Map<String, int> dailyActivity;
  const _DailyActivityBarChart({required this.dailyActivity});

  @override
  Widget build(BuildContext context) {
    if (dailyActivity.isEmpty) {
      return const Center(child: Text('No data'));
    }
    final sortedKeys = dailyActivity.keys.toList()..sort();
    final barGroups = <BarChartGroupData>[];
    int idx = 0;
    for (final date in sortedKeys) {
      barGroups.add(
        BarChartGroupData(
          x: idx,
          barRods: [
            BarChartRodData(
              toY: dailyActivity[date]!.toDouble(),
              color: Theme.of(context).colorScheme.primary,
              width: 18,
              borderRadius: BorderRadius.circular(6),
            ),
          ],
        ),
      );
      idx++;
    }
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.20),
            Colors.white.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (dailyActivity.values.isNotEmpty ? dailyActivity.values.reduce((a, b) => a > b ? a : b) + 2 : 10).toDouble(),
          barGroups: barGroups,
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 28),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= sortedKeys.length) return const SizedBox.shrink();
                  final date = sortedKeys[idx];
                  final label = date.length >= 10 ? date.substring(5) : date;
                  return Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.white)),
                  );
                },
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}

class _OperationAccuracyPieChart extends StatelessWidget {
  final Map<String, double> operationAccuracy;
  const _OperationAccuracyPieChart({required this.operationAccuracy});

  @override
  Widget build(BuildContext context) {
    if (operationAccuracy.isEmpty) {
      return const Center(child: Text('No data'));
    }
    final colors = [
      Colors.blue,
      Colors.orange,
      Colors.green,
      Colors.purple,
      Colors.red,
      Colors.teal,
    ];
    int colorIdx = 0;
    final sections = operationAccuracy.entries.map((e) {
      final section = PieChartSectionData(
        value: e.value,
        title: '${e.key}\n${e.value.toStringAsFixed(1)}%',
        color: colors[colorIdx % colors.length],
        radius: 40,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
      colorIdx++;
      return section;
    }).toList();
    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 0,
        sectionsSpace: 2,
        borderData: FlBorderData(show: false),
      ),
    );
  }
}

class _LevelAccuracyLineChart extends StatelessWidget {
  final Map<int, double> levelAccuracy;
  const _LevelAccuracyLineChart({required this.levelAccuracy});

  @override
  Widget build(BuildContext context) {
    if (levelAccuracy.isEmpty) {
      return const Center(child: Text('No data'));
    }
    final sortedKeys = levelAccuracy.keys.toList()..sort();
    final spots = sortedKeys.map((level) => FlSpot(level.toDouble(), levelAccuracy[level]!)).toList();
    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 100,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Theme.of(context).primaryColor,
            barWidth: 3,
            dotData: FlDotData(show: true),
          ),
        ],
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 28),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                final level = value.toInt();
                if (!sortedKeys.contains(level)) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Text('Lv$level', style: const TextStyle(fontSize: 12)),
                );
              },
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: false),
      ),
    );
  }
} 