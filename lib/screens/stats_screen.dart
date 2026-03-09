import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme.dart';
import '../services/storage_service.dart';
import '../widgets/common_widgets.dart';

class StatsScreen extends StatefulWidget {
  final StorageService storage;

  const StatsScreen({super.key, required this.storage});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late int _selectedYear;
  late int _selectedMonth;
  late int _selectedQuarter;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final now = DateTime.now();
    _selectedYear = now.year;
    _selectedMonth = now.month;
    _selectedQuarter = ((now.month - 1) ~/ 3) + 1;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.lavender,
          labelColor: AppTheme.lavender,
          unselectedLabelColor: AppTheme.textMuted,
          tabs: const [
            Tab(text: 'Monthly'),
            Tab(text: 'Quarterly'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMonthlyView(),
          _buildQuarterlyView(),
        ],
      ),
    );
  }

  Widget _buildMonthlyView() {
    final stats = widget.storage.getMonthlyStats(_selectedYear, _selectedMonth);
    final monthLabel = DateFormat('MMMM yyyy')
        .format(DateTime(_selectedYear, _selectedMonth));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Month selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: AppTheme.textSecondary),
                onPressed: () {
                  setState(() {
                    _selectedMonth--;
                    if (_selectedMonth < 1) {
                      _selectedMonth = 12;
                      _selectedYear--;
                    }
                  });
                },
              ),
              Text(
                monthLabel,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
                onPressed: () {
                  setState(() {
                    _selectedMonth++;
                    if (_selectedMonth > 12) {
                      _selectedMonth = 1;
                      _selectedYear++;
                    }
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildStatsGrid(stats),
          const SizedBox(height: 24),
          _buildBreakdowns(stats),
        ],
      ),
    );
  }

  Widget _buildQuarterlyView() {
    final stats =
        widget.storage.getQuarterlyStats(_selectedYear, _selectedQuarter);
    final quarterLabel = 'Q$_selectedQuarter $_selectedYear';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Quarter selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: AppTheme.textSecondary),
                onPressed: () {
                  setState(() {
                    _selectedQuarter--;
                    if (_selectedQuarter < 1) {
                      _selectedQuarter = 4;
                      _selectedYear--;
                    }
                  });
                },
              ),
              Text(
                quarterLabel,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
                onPressed: () {
                  setState(() {
                    _selectedQuarter++;
                    if (_selectedQuarter > 4) {
                      _selectedQuarter = 1;
                      _selectedYear++;
                    }
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildStatsGrid(stats),
          const SizedBox(height: 24),
          _buildBreakdowns(stats),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(Map<String, dynamic> stats) {
    final episodeCount = stats['episodeCount'] as int;
    final avgPain = stats['avgPain'] as double;
    final avgStress = stats['avgStress'] as double;
    final avgHydration = stats['avgHydration'] as double;
    final avgSleepQuality = stats['avgSleepQuality'] as double;
    final avgSleepDuration = stats['avgSleepDuration'] as double;
    final checkinDays = stats['checkinDays'] as int;

    return Column(
      children: [
        // Episode count - featured
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: episodeCount > 0
                ? AppTheme.coral.withOpacity(0.1)
                : AppTheme.sage.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: episodeCount > 0
                  ? AppTheme.coral.withOpacity(0.3)
                  : AppTheme.sage.withOpacity(0.3),
            ),
          ),
          child: Column(
            children: [
              Text(
                '$episodeCount',
                style: TextStyle(
                  color: episodeCount > 0 ? AppTheme.coral : AppTheme.sage,
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                episodeCount == 1 ? 'Episode' : 'Episodes',
                style: TextStyle(
                  color: episodeCount > 0 ? AppTheme.coral : AppTheme.sage,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Stats grid
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.6,
          children: [
            StatCard(
              label: 'AVG PAIN',
              value: episodeCount > 0 ? avgPain.toStringAsFixed(1) : '—',
              accentColor: AppTheme.coral,
              icon: Icons.bolt,
            ),
            StatCard(
              label: 'AVG STRESS',
              value: avgStress > 0 ? avgStress.toStringAsFixed(1) : '—',
              accentColor: AppTheme.amber,
              icon: Icons.psychology,
            ),
            StatCard(
              label: 'AVG HYDRATION',
              value: avgHydration > 0 ? avgHydration.toStringAsFixed(1) : '—',
              accentColor: AppTheme.teal,
              icon: Icons.water_drop,
            ),
            StatCard(
              label: 'AVG SLEEP',
              value: avgSleepDuration > 0
                  ? '${avgSleepDuration.toStringAsFixed(1)}h'
                  : '—',
              accentColor: AppTheme.lavender,
              icon: Icons.bedtime,
            ),
            StatCard(
              label: 'SLEEP QUALITY',
              value:
                  avgSleepQuality > 0 ? avgSleepQuality.toStringAsFixed(1) : '—',
              accentColor: AppTheme.lavender,
              icon: Icons.star,
            ),
            StatCard(
              label: 'CHECK-IN DAYS',
              value: '$checkinDays',
              accentColor: AppTheme.sage,
              icon: Icons.calendar_today,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBreakdowns(Map<String, dynamic> stats) {
    final auraFreq = stats['auraFrequency'] as Map<String, int>;
    final locationFreq = stats['locationFrequency'] as Map<String, int>;
    final symptomFreq = stats['symptomFrequency'] as Map<String, int>;
    final episodeCount = stats['episodeCount'] as int;

    if (episodeCount == 0) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: const Column(
          children: [
            Text('✨', style: TextStyle(fontSize: 32)),
            SizedBox(height: 10),
            Text(
              'No episodes this period',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Keep tracking your daily check-ins!',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (auraFreq.isNotEmpty)
          _buildFrequencySection('Aura Types', auraFreq, AppTheme.lavender),
        if (locationFreq.isNotEmpty)
          _buildFrequencySection(
              'Pain Locations', locationFreq, AppTheme.coral),
        if (symptomFreq.isNotEmpty)
          _buildFrequencySection(
              'Lingering Symptoms', symptomFreq, AppTheme.amber),
      ],
    );
  }

  Widget _buildFrequencySection(
      String title, Map<String, int> freq, Color color) {
    final sorted = freq.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxVal = sorted.first.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 10),
          child: Text(
            title,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        ...sorted.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '${entry.value}×',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: entry.value / maxVal,
                      backgroundColor: AppTheme.border,
                      valueColor: AlwaysStoppedAnimation(color),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            )),
        const SizedBox(height: 10),
      ],
    );
  }
}
