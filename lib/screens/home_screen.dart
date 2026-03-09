import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../theme.dart';
import '../models/data_models.dart';
import '../services/storage_service.dart';
import 'log_episode.dart';
import 'morning_checkin.dart';
import 'evening_checkin.dart';
import 'second_day.dart';

class HomeScreen extends StatefulWidget {
  final StorageService storage;

  const HomeScreen({super.key, required this.storage});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    final episodes = widget.storage.getEpisodes();
    final episodeDates = episodes.map((e) =>
        DateTime(e.date.year, e.date.month, e.date.day)).toSet();

    final mornings = widget.storage.getMorningCheckins();
    final morningDates = mornings.map((c) =>
        DateTime(c.date.year, c.date.month, c.date.day)).toSet();

    final evenings = widget.storage.getEveningCheckins();
    final eveningDates = evenings.map((c) =>
        DateTime(c.date.year, c.date.month, c.date.day)).toSet();

    final secondDayLogs = widget.storage.getSecondDayLogs();
    final secondDayDates = secondDayLogs.map((l) =>
        DateTime(l.date.year, l.date.month, l.date.day)).toSet();

    final today = DateTime.now();
    final selectedNorm = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
    final hasMorning = morningDates.contains(selectedNorm);
    final hasEvening = eveningDates.contains(selectedNorm);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── App Header ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Aura',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.lavender,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          DateFormat('EEEE, MMMM d').format(today),
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    // Episode count badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.bolt, color: AppTheme.coral, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.storage.getEpisodesForMonth(today.year, today.month).length}',
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const Text(
                            ' this month',
                            style: TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Action Cards ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildQuickAction(
                        icon: hasMorning ? Icons.check_circle : Icons.wb_sunny_outlined,
                        iconColor: hasMorning ? AppTheme.sage : AppTheme.amber,
                        label: 'Morning',
                        done: hasMorning,
                        onTap: () => _navigateTo(MorningCheckinScreen(
                          storage: widget.storage,
                          date: _selectedDay,
                        )),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickAction(
                        icon: hasEvening ? Icons.check_circle : Icons.nights_stay_outlined,
                        iconColor: hasEvening ? AppTheme.sage : AppTheme.lavender,
                        label: 'Evening',
                        done: hasEvening,
                        onTap: () => _navigateTo(EveningCheckinScreen(
                          storage: widget.storage,
                          date: _selectedDay,
                        )),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Calendar ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 20, 12, 0),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: TableCalendar(
                    firstDay: DateTime(2020),
                    lastDay: DateTime(2030),
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    calendarFormat: _calendarFormat,
                    onFormatChanged: (format) {
                      setState(() { _calendarFormat = format; });
                    },
                    onDaySelected: (selected, focused) {
                      setState(() {
                        _selectedDay = selected;
                        _focusedDay = focused;
                      });
                    },
                    onPageChanged: (focused) {
                      _focusedDay = focused;
                    },
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, focusedDay) {
                        final n = DateTime(day.year, day.month, day.day);
                        return _buildCalendarCell(day,
                          isEpisode: episodeDates.contains(n),
                          hasMorning: morningDates.contains(n),
                          hasEvening: eveningDates.contains(n),
                          hasSecondDay: secondDayDates.contains(n),
                        );
                      },
                      todayBuilder: (context, day, focusedDay) {
                        final n = DateTime(day.year, day.month, day.day);
                        return _buildCalendarCell(day,
                          isEpisode: episodeDates.contains(n),
                          hasMorning: morningDates.contains(n),
                          hasEvening: eveningDates.contains(n),
                          hasSecondDay: secondDayDates.contains(n),
                          isToday: true,
                        );
                      },
                      selectedBuilder: (context, day, focusedDay) {
                        final n = DateTime(day.year, day.month, day.day);
                        return _buildCalendarCell(day,
                          isEpisode: episodeDates.contains(n),
                          hasMorning: morningDates.contains(n),
                          hasEvening: eveningDates.contains(n),
                          hasSecondDay: secondDayDates.contains(n),
                          selected: true,
                        );
                      },
                    ),
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      leftChevronIcon: Icon(Icons.chevron_left, color: AppTheme.textSecondary),
                      rightChevronIcon: Icon(Icons.chevron_right, color: AppTheme.textSecondary),
                    ),
                    daysOfWeekStyle: const DaysOfWeekStyle(
                      weekdayStyle: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                      weekendStyle: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                    ),
                    calendarStyle: const CalendarStyle(
                      outsideDaysVisible: false,
                      defaultTextStyle: TextStyle(color: AppTheme.textSecondary),
                      weekendTextStyle: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ),
                ),
              ),
            ),

            // ── Selected Day Details ──
            SliverToBoxAdapter(
              child: _buildSelectedDayDetails(episodes),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),

      // ── FAB Row ──
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FloatingActionButton.extended(
              heroTag: 'second_day',
              onPressed: () {
                _navigateTo(SecondDayScreen(
                  storage: widget.storage,
                  date: _selectedDay,
                ));
              },
              backgroundColor: AppTheme.amberDim,
              foregroundColor: AppTheme.textPrimary,
              icon: const Icon(Icons.healing),
              label: const Text(
                'Second Day',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          FloatingActionButton.extended(
            heroTag: 'log_episode',
            onPressed: () => _navigateTo(LogEpisodeScreen(
              storage: widget.storage,
              initialDate: _selectedDay,
            )),
            backgroundColor: AppTheme.coral,
            foregroundColor: AppTheme.bg,
            icon: const Icon(Icons.bolt),
            label: const Text(
              'Log Episode',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarCell(
    DateTime day, {
    bool isEpisode = false,
    bool hasMorning = false,
    bool hasEvening = false,
    bool hasSecondDay = false,
    bool isToday = false,
    bool selected = false,
  }) {
    final dots = <Widget>[];
    if (isEpisode) dots.add(_dot(AppTheme.coral));
    if (hasMorning) dots.add(_dot(AppTheme.sage));
    if (hasEvening) dots.add(_dot(AppTheme.teal));
    if (hasSecondDay) dots.add(_dot(AppTheme.amber));

    return Container(
      margin: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: isEpisode
            ? AppTheme.coral.withOpacity(0.25)
            : selected
                ? AppTheme.lavender.withOpacity(0.2)
                : null,
        borderRadius: BorderRadius.circular(10),
        border: isToday
            ? Border.all(color: AppTheme.lavender, width: 2)
            : null,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${day.day}',
              style: TextStyle(
                color: isEpisode
                    ? AppTheme.coral
                    : selected
                        ? AppTheme.lavender
                        : AppTheme.textSecondary,
                fontWeight: (isEpisode || selected)
                    ? FontWeight.w700
                    : FontWeight.w400,
                fontSize: 14,
              ),
            ),
            if (dots.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: dots,
              ),
          ],
        ),
      ),
    );
  }

  Widget _dot(Color color) => Container(
        margin: const EdgeInsets.only(top: 2, left: 1),
        width: 4,
        height: 4,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );

  Widget _buildQuickAction({
    required IconData icon,
    required Color iconColor,
    required String label,
    required bool done,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: done ? AppTheme.sage.withOpacity(0.3) : AppTheme.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: done ? AppTheme.sage : AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedDayDetails(List<Episode> allEpisodes) {
    final dayEpisodes = allEpisodes.where((e) =>
        e.date.year == _selectedDay.year &&
        e.date.month == _selectedDay.month &&
        e.date.day == _selectedDay.day).toList();

    final morning = widget.storage.getMorningCheckinForDate(_selectedDay);
    final evening = widget.storage.getEveningCheckinForDate(_selectedDay);
    final secondDay = widget.storage.getSecondDayLogForDate(_selectedDay);

    if (dayEpisodes.isEmpty && morning == null && evening == null && secondDay == null) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          'No data for this day',
          style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('MMMM d').format(_selectedDay),
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          if (dayEpisodes.isNotEmpty)
            ...dayEpisodes.map((ep) => _buildEpisodeCard(ep)),
          if (secondDay != null)
            _buildSecondDayCard(secondDay),
          if (morning != null)
            _buildCheckinSummary(
              '☀️ Morning',
              'Sleep: ${morning.sleepDuration}h · Quality: ${morning.sleepQuality}/6',
              onTap: () => _navigateTo(MorningCheckinScreen(
                storage: widget.storage,
                date: _selectedDay,
              )),
            ),
          if (evening != null)
            _buildCheckinSummary(
              '🌙 Evening',
              'Stress: ${evening.stress}/6 · Water: ${evening.hydration}/6 · '
              'Caffeine: ${evening.caffeine} cups · Exercise: ${evening.exercise}',
              onTap: () => _navigateTo(EveningCheckinScreen(
                storage: widget.storage,
                date: _selectedDay,
              )),
            ),
        ],
      ),
    );
  }

  Widget _buildEpisodeCard(Episode ep) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.coral.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.coral.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bolt, color: AppTheme.coral, size: 18),
              const SizedBox(width: 6),
              const Text('Episode', style: TextStyle(
                color: AppTheme.coral,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              )),
              const Spacer(),
              Text('Pain ${ep.painSeverity}/6', style: TextStyle(
                color: ep.painSeverity > 0
                    ? AppTheme.severityColors[ep.painSeverity.clamp(1, 6) - 1]
                    : AppTheme.textMuted,
                fontWeight: FontWeight.w700,
              )),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _navigateTo(LogEpisodeScreen(
                  storage: widget.storage,
                  editEpisode: ep,
                )),
                child: const Icon(Icons.edit_outlined,
                    color: AppTheme.textMuted, size: 18),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => _confirmDeleteEpisode(ep),
                child: const Icon(Icons.delete_outline,
                    color: AppTheme.textMuted, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Aura: ${ep.visualAuraTypes.join(', ')} · Location: ${ep.painLocation} · '
            'Cycle day: ${ep.menstrualCycleDay}',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
          if (ep.auraDuration != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Aura: ${ep.auraDuration}m',
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSecondDayCard(SecondDayLog log) {
    return GestureDetector(
      onTap: () => _navigateTo(SecondDayScreen(
        storage: widget.storage,
        date: _selectedDay,
      )),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.amber.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.amber.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.healing, color: AppTheme.amber, size: 18),
                const SizedBox(width: 6),
                const Text('Second Day Log', style: TextStyle(
                  color: AppTheme.amber,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                )),
                const Spacer(),
                const Icon(Icons.edit_outlined, color: AppTheme.amber, size: 16),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Recovery: ${_recoveryLabel(log.recoveryStatus)}',
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
            if (log.lingeringSymptoms.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  log.lingeringSymptoms.join(', '),
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                ),
              ),
            if (log.functionalImpact != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Could function: ${log.functionalImpact}',
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteEpisode(Episode ep) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Episode',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: const Text('Are you sure you want to delete this episode?',
            style: TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete',
                style: TextStyle(color: AppTheme.coral)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await widget.storage.deleteEpisode(ep.id);
      setState(() {});
    }
  }

  Widget _buildCheckinSummary(String title, String detail, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  )),
                  const SizedBox(height: 4),
                  Text(detail, style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                  )),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(Icons.edit_outlined, color: AppTheme.textMuted, size: 16),
          ],
        ),
      ),
    );
  }

  String _recoveryLabel(String? status) {
    switch (status) {
      case 'fully_recovered':
        return 'Fully recovered';
      case 'mostly_recovered':
        return 'Mostly recovered';
      case 'still_affected':
        return 'Still affected';
      case 'worse':
        return 'Worse';
      default:
        return 'Logged';
    }
  }

  void _navigateTo(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen))
        .then((_) => setState(() {}));
  }
}
