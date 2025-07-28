import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/statistics_provider.dart';
import '../models/statistics.dart';
import '../providers/auth_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/unicorn_theme.dart';
import 'main_shell.dart';

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
      final statisticsProvider = Provider.of<StatisticsProvider>(context, listen: false);
      
      // 네트워크 에러 콜백 설정
      statisticsProvider.setNetworkErrorCallback(() {
        if (mounted) {
          _showNetworkErrorDialog();
        }
      });
      
      if (auth.isLoggedIn && auth.user != null) {
        statisticsProvider.fetchStatistics(auth.user!.id);
      }
    });
  }

  void _showNetworkErrorDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.25),
                Colors.white.withOpacity(0.1),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.3),
                      Colors.white.withOpacity(0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                ),
                child: const Icon(
                  Icons.wifi_off,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Network Error',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  shadows: [Shadow(offset: Offset(1,1), blurRadius: 2, color: Colors.black12)],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Failed to load statistics data.\nPlease check your internet connection.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // 다이얼로그 닫기
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    MainShell.setTabIndex?.call(0);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.9),
                    foregroundColor: const Color(0xFF8B5CF6),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    shadowColor: Colors.black.withOpacity(0.1),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Back',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
        bool isInitialStats = stats != null &&
          stats.totalSolved == 0 &&
          stats.totalCorrect == 0 &&
          stats.averageAccuracy == 0.0 &&
          stats.averageTimePerQuestion == 0.0 &&
          stats.favoriteOperation == '' &&
          stats.weakestOperation == '' &&
          stats.dailyActivity.isEmpty &&
          stats.operationAccuracy.isEmpty &&
          stats.levelAccuracy.isEmpty;
        if (stats == null || isInitialStats) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0x40FFFFFF),
                      Color(0x20FFFFFF),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0x30FFFFFF)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bar_chart_rounded,
                      size: 64,
                      color: Colors.white,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No statistics data yet.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Play some games to see your stats here!',
                      style: TextStyle(
                        color: Color(0xCCFFFFFF),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('\ud83d\udcca My Statistics'),
          ),
          body: Material(
            color: Colors.transparent,
            child: Container(
              decoration: UnicornDecorations.appBackground,
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
                      height: 180, // 160에서 180으로 증가
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
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [Shadow(offset: Offset(1,1), blurRadius: 2, color: Colors.black12)]
        ),
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
      return const Center(child: Text('No data', style: TextStyle(color: Colors.white)));
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
              sideTitles: SideTitles(showTitles: true, reservedSize: 28, getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: const TextStyle(color: Colors.white))),
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
          gridData: FlGridData(show: true, drawHorizontalLine: true, drawVerticalLine: true, horizontalInterval: 10, verticalInterval: 1, getDrawingHorizontalLine: (value) => FlLine(color: Colors.white24, strokeWidth: 1), getDrawingVerticalLine: (value) => FlLine(color: Colors.white24, strokeWidth: 1)),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}

class _OperationAccuracyPieChart extends StatelessWidget {
  final Map<String, double> operationAccuracy;
  const _OperationAccuracyPieChart({required this.operationAccuracy});

  // 연산명을 기호로 변환하는 함수
  String _operationToSymbol(String operation) {
    switch (operation.toLowerCase()) {
      case 'addition':
      case '더하기':
        return '+';
      case 'subtraction':
      case '빼기':
        return '−';
      case 'multiplication':
      case '곱하기':
        return '×';
      case 'division':
      case '나누기':
        return '÷';
      default:
        return operation;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (operationAccuracy.isEmpty) {
      return const Center(child: Text('No data', style: TextStyle(color: Colors.white)));
    }
    
    // 더 다양한 색상 추가
    final colors = [
      Color(0xFF8B5CF6), // primary.purple
      Color(0xFFD946EF), // primary.magenta
      Color(0xFFEC4899), // primary.pink
      Color(0xFF06B6D4), // secondary.cyan
      Color(0xFF14B8A6), // secondary.teal
      Color(0xFFFDE047), // secondary.yellow
    ];
    
    int colorIdx = 0;
    final sections = operationAccuracy.entries.map((e) {
      final symbol = _operationToSymbol(e.key);
      final section = PieChartSectionData(
        value: e.value,
        title: '', // 텍스트 제거
        color: colors[colorIdx % colors.length],
        radius: 35, // 50에서 35로 줄임
        titleStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold, 
          color: Colors.white,
          shadows: [Shadow(offset: Offset(1,1), blurRadius: 2, color: Colors.black26)],
        ),
      );
      colorIdx++;
      return section;
    }).toList();
    
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
      padding: const EdgeInsets.all(12), // 16에서 12로 줄임
      child: Column(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 15, // 20에서 15로 줄임
                sectionsSpace: 2, // 3에서 2로 줄임
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
          const SizedBox(height: 8), // 12에서 8로 줄임
          // 범례 추가
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: operationAccuracy.entries.map((e) {
              final color = colors[operationAccuracy.keys.toList().indexOf(e.key) % colors.length];
              final symbol = _operationToSymbol(e.key);
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$symbol: ${e.value.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      shadows: [Shadow(offset: Offset(1,1), blurRadius: 2, color: Colors.black26)],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
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
      return const Center(child: Text('No data', style: TextStyle(color: Colors.white)));
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
            sideTitles: SideTitles(showTitles: true, reservedSize: 28, getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: const TextStyle(color: Colors.white))),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                final level = value.toInt();
                if (!sortedKeys.contains(level)) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Text('Lv$level', style: const TextStyle(fontSize: 12, color: Colors.white)),
                );
              },
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: true, drawHorizontalLine: true, drawVerticalLine: true, horizontalInterval: 20, verticalInterval: 1, getDrawingHorizontalLine: (value) => FlLine(color: Colors.white24, strokeWidth: 1), getDrawingVerticalLine: (value) => FlLine(color: Colors.white24, strokeWidth: 1)),
        borderData: FlBorderData(show: false),
      ),
    );
  }
} 