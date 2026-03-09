import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../theme.dart';
import '../models/data_models.dart';
import '../services/storage_service.dart';
import '../widgets/common_widgets.dart';

class EveningCheckinScreen extends StatefulWidget {
  final StorageService storage;
  final DateTime? date;

  const EveningCheckinScreen({super.key, required this.storage, this.date});

  @override
  State<EveningCheckinScreen> createState() => _EveningCheckinScreenState();
}

class _EveningCheckinScreenState extends State<EveningCheckinScreen> {
  int? _stress;
  int? _hydration;
  int? _caffeine;
  int? _screenTime;
  String? _exercise;
  int _alcohol = 0;
  int _mealsSkipped = 0;
  String _sunExposure = 'none';

  late final DateTime _date;

  @override
  void initState() {
    super.initState();
    _date = widget.date ?? DateTime.now();
    final existing = widget.storage.getEveningCheckinForDate(_date);
    if (existing != null) {
      _stress = existing.stress;
      _hydration = existing.hydration;
      _caffeine = existing.caffeine;
      _screenTime = existing.screenTime;
      _exercise = existing.exercise;
      _alcohol = existing.alcohol;
      _mealsSkipped = existing.mealsSkipped;
      _sunExposure = existing.sunExposure;
    }
  }

  bool get _isValid =>
      _stress != null &&
      _hydration != null &&
      _caffeine != null &&
      _screenTime != null &&
      _exercise != null;

  Future<void> _save() async {
    if (!_isValid) return;
    final checkin = EveningCheckin(
      id: const Uuid().v4(),
      date: _date,
      stress: _stress!,
      hydration: _hydration!,
      caffeine: _caffeine!,
      screenTime: _screenTime!,
      exercise: _exercise!,
      alcohol: _alcohol,
      mealsSkipped: _mealsSkipped,
      sunExposure: _sunExposure,
    );
    await widget.storage.saveEveningCheckin(checkin);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Evening Check-in'),
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
                color: AppTheme.lavender.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.lavender.withOpacity(0.2)),
              ),
              child: const Row(
                children: [
                  Text('🌙', style: TextStyle(fontSize: 28)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good evening',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Quick recap of your day',
                          style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Stress
            ScaleSelector(
              label: 'Perceived Stress',
              value: _stress,
              onChanged: (v) => setState(() => _stress = v),
              showColors: true,
            ),

            const SizedBox(height: 24),

            // Hydration
            ScaleSelector(
              label: 'Hydration (glasses of water)',
              value: _hydration,
              onChanged: (v) => setState(() => _hydration = v),
              labels: const ['1', '2', '3', '4', '5', '6+'],
            ),

            const SizedBox(height: 24),

            // Caffeine
            ScaleSelector(
              label: 'Caffeine (cups)',
              min: 1,
              max: 3,
              value: _caffeine,
              onChanged: (v) => setState(() => _caffeine = v),
              labels: const ['1', '2', '3+'],
            ),

            const SizedBox(height: 24),

            // Screen time
            ScaleSelector(
              label: 'Screen Time Intensity',
              value: _screenTime,
              onChanged: (v) => setState(() => _screenTime = v),
              showColors: true,
            ),

            const SizedBox(height: 24),

            // Exercise
            const Text(
              'Exercise',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            ...ExerciseLevels.options.map((opt) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: OptionCard(
                    label: opt['label']!,
                    icon: opt['icon'],
                    selected: _exercise == opt['id'],
                    onTap: () => setState(() => _exercise = opt['id']),
                  ),
                )),

            const SizedBox(height: 24),

            // Alcohol
            ScaleSelector(
              label: 'Alcohol',
              min: 0,
              max: 2,
              value: _alcohol,
              onChanged: (v) => setState(() => _alcohol = v),
              labels: const ['None', '1 drink', '2+'],
            ),

            const SizedBox(height: 24),

            // Sun Exposure
            const Text(
              'Sun Exposure',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            ...[
              {'id': 'none', 'label': 'None', 'icon': '🌑'},
              {'id': 'little', 'label': 'Little', 'icon': '⛅'},
              {'id': 'medium', 'label': 'Medium', 'icon': '🌤️'},
              {'id': 'high', 'label': 'High', 'icon': '☀️'},
            ].map((opt) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: OptionCard(
                    label: opt['label']!,
                    icon: opt['icon'],
                    selected: _sunExposure == opt['id'],
                    onTap: () => setState(() => _sunExposure = opt['id']!),
                  ),
                )),

            const SizedBox(height: 24),

            // Meals Skipped
            ScaleSelector(
              label: 'Meals Skipped',
              min: 0,
              max: 2,
              value: _mealsSkipped,
              onChanged: (v) => setState(() => _mealsSkipped = v),
              labels: const ['None', '1', '2'],
            ),

            const SizedBox(height: 32),

            // Save
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isValid ? _save : null,
                child: const Text('Save'),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
