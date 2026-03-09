import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../theme.dart';
import '../models/data_models.dart';
import '../services/storage_service.dart';
import '../widgets/common_widgets.dart';

class MorningCheckinScreen extends StatefulWidget {
  final StorageService storage;
  final DateTime? date;

  const MorningCheckinScreen({super.key, required this.storage, this.date});

  @override
  State<MorningCheckinScreen> createState() => _MorningCheckinScreenState();
}

class _MorningCheckinScreenState extends State<MorningCheckinScreen> {
  double _sleepDuration = 7.0;
  int? _sleepQuality;

  late final DateTime _date;

  @override
  void initState() {
    super.initState();
    _date = widget.date ?? DateTime.now();
    final existing = widget.storage.getMorningCheckinForDate(_date);
    if (existing != null) {
      _sleepDuration = existing.sleepDuration;
      _sleepQuality = existing.sleepQuality;
    }
  }

  bool get _isValid => _sleepQuality != null;

  Future<void> _save() async {
    if (!_isValid) return;
    final checkin = MorningCheckin(
      id: const Uuid().v4(),
      date: _date,
      sleepDuration: _sleepDuration,
      sleepQuality: _sleepQuality!,
    );
    await widget.storage.saveMorningCheckin(checkin);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Morning Check-in'),
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
            // Greeting
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.amber.withOpacity(0.2)),
              ),
              child: const Row(
                children: [
                  Text('☀️', style: TextStyle(fontSize: 28)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good morning',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'How did you sleep?',
                          style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Sleep Duration
            SleepDurationPicker(
              value: _sleepDuration,
              onChanged: (v) => setState(() => _sleepDuration = v),
            ),

            const SizedBox(height: 28),

            // Sleep Quality
            ScaleSelector(
              label: 'Sleep Quality',
              value: _sleepQuality,
              onChanged: (v) => setState(() => _sleepQuality = v),
              labels: const ['😫', '😣', '😐', '🙂', '😊', '🤩'],
              showColors: true,
            ),

            const SizedBox(height: 40),

            // Save
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isValid ? _save : null,
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
