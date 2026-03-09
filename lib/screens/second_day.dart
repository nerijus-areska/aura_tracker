import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/data_models.dart';
import '../services/storage_service.dart';
import '../widgets/common_widgets.dart';

class SecondDayScreen extends StatefulWidget {
  final StorageService storage;
  final DateTime? date;

  const SecondDayScreen({
    super.key,
    required this.storage,
    this.date,
  });

  @override
  State<SecondDayScreen> createState() => _SecondDayScreenState();
}

class _SecondDayScreenState extends State<SecondDayScreen> {
  late DateTime _date;
  String? _recoveryStatus;
  List<String> _selectedSymptoms = [];
  String? _functionalImpact;
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _date = widget.date ?? DateTime.now();

    // Load existing log for this date if editing
    final existing = widget.storage.getSecondDayLogForDate(_date);
    if (existing != null) {
      _recoveryStatus = existing.recoveryStatus;
      _selectedSymptoms = List.from(existing.lingeringSymptoms);
      _functionalImpact = existing.functionalImpact;
      _notesController.text = existing.notes ?? '';
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  bool get _isValid => _recoveryStatus != null;

  Future<void> _save() async {
    if (!_isValid) return;

    // Warn if no recent episodes exist
    final episodes = widget.storage.getEpisodes();
    final hasRecentEpisode = episodes.any((e) {
      final diff = _date.difference(e.date).inDays;
      return diff >= 0 && diff <= 7;
    });

    if (!hasRecentEpisode && mounted) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('No Recent Episode',
              style: TextStyle(color: AppTheme.textPrimary)),
          content: const Text(
              'There are no episodes logged in the past week. '
              'Second day logs are typically entered after an episode. Save anyway?',
              style: TextStyle(color: AppTheme.textSecondary)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel',
                  style: TextStyle(color: AppTheme.textMuted)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Save Anyway',
                  style: TextStyle(color: AppTheme.amber)),
            ),
          ],
        ),
      );
      if (proceed != true) return;
    }

    final log = SecondDayLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: _date,
      recoveryStatus: _recoveryStatus!,
      lingeringSymptoms: _selectedSymptoms,
      functionalImpact: _functionalImpact,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );
    await widget.storage.saveSecondDayLog(log);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Day Log'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.amber.withOpacity(0.2)),
              ),
              child: const Row(
                children: [
                  Text('🩹', style: TextStyle(fontSize: 28)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recovery Check-in',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'How are you doing today?',
                          style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Recovery status
            const SectionHeader(
              title: 'How Are You Feeling?',
              icon: Icons.favorite_outline,
            ),
            const SizedBox(height: 4),
            ..._recoveryOptions.map((opt) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: OptionCard(
                    label: opt['label']!,
                    icon: opt['icon'],
                    selected: _recoveryStatus == opt['id'],
                    onTap: () => setState(() => _recoveryStatus = opt['id']),
                  ),
                )),

            const SizedBox(height: 24),

            // Lingering symptoms
            const SectionHeader(
              title: 'Lingering Symptoms',
              subtitle: 'Select all that apply',
              icon: Icons.checklist,
            ),
            const SizedBox(height: 4),
            ChipMultiSelect(
              options: LingeringSymptoms.options,
              selected: _selectedSymptoms,
              onChanged: (v) => setState(() => _selectedSymptoms = v),
            ),

            const SizedBox(height: 24),

            // Functional impact
            const SectionHeader(
              title: 'Could You Work/Function Normally?',
              icon: Icons.work_outline,
            ),
            const SizedBox(height: 4),
            ..._functionalOptions.map((opt) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: OptionCard(
                    label: opt['label']!,
                    icon: opt['icon'],
                    selected: _functionalImpact == opt['id'],
                    onTap: () =>
                        setState(() => _functionalImpact = opt['id']),
                  ),
                )),

            const SizedBox(height: 24),

            // Notes
            const SectionHeader(
              title: 'Notes',
              subtitle: 'Anything else worth noting',
              icon: Icons.edit_note,
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _notesController,
              maxLines: 4,
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15),
              decoration: const InputDecoration(
                hintText: 'How the day went, what helped, triggers you noticed...',
                contentPadding: EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 36),

            // Save
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isValid ? _save : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.amber,
                ),
                child: const Text('Save Second Day Log'),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  static const _recoveryOptions = [
    {'id': 'fully_recovered', 'label': 'Fully Recovered', 'icon': '💚'},
    {'id': 'mostly_recovered', 'label': 'Mostly Recovered', 'icon': '💛'},
    {'id': 'still_affected', 'label': 'Still Affected', 'icon': '🧡'},
    {'id': 'worse', 'label': 'Worse', 'icon': '❤️'},
  ];

  static const _functionalOptions = [
    {'id': 'yes', 'label': 'Yes', 'icon': '✅'},
    {'id': 'partially', 'label': 'Partially', 'icon': '⚠️'},
    {'id': 'no', 'label': 'No', 'icon': '❌'},
  ];
}
