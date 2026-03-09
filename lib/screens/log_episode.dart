import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../theme.dart';
import '../models/data_models.dart';
import '../services/storage_service.dart';
import '../widgets/common_widgets.dart';

class LogEpisodeScreen extends StatefulWidget {
  final StorageService storage;
  final Episode? editEpisode;
  final DateTime? initialDate;

  const LogEpisodeScreen({
    super.key,
    required this.storage,
    this.editEpisode,
    this.initialDate,
  });

  @override
  State<LogEpisodeScreen> createState() => _LogEpisodeScreenState();
}

class _LogEpisodeScreenState extends State<LogEpisodeScreen> {
  int _currentStep = 0;
  final int _totalSteps = 3;

  late final String _episodeId;
  late final DateTime _episodeDate;

  // Step 1: Aura
  DateTime? _auraStartTime;
  int? _auraDuration; // minutes
  final Set<String> _auraTypes = {};
  String? _whichEye;

  // Step 2: Pain
  int? _painSeverity;
  String? _painLocation;
  int? _painDuration; // minutes

  // Step 3: Details
  String? _location;
  int? _menstrualDay;
  String? _notes;

  final _menstrualController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.editEpisode != null) {
      final ep = widget.editEpisode!;
      _episodeId = ep.id;
      _episodeDate = ep.date;
      _auraStartTime = ep.auraStartTime;
      _auraDuration = ep.auraDuration;
      _auraTypes.addAll(ep.visualAuraTypes);
      _whichEye = ep.whichEye;
      _painSeverity = ep.painSeverity > 0 ? ep.painSeverity : null;
      _painLocation = ep.painLocation.isNotEmpty ? ep.painLocation : null;
      _painDuration = ep.painDuration;
      _location = ep.location;
      _menstrualDay = ep.menstrualCycleDay > 0 ? ep.menstrualCycleDay : null;
      if (_menstrualDay != null) {
        _menstrualController.text = _menstrualDay.toString();
      }
      _notes = ep.notes;
      if (_notes != null) {
        _notesController.text = _notes!;
      }
    } else {
      _episodeId = const Uuid().v4();
      _episodeDate = widget.initialDate ?? DateTime.now();
    }
  }

  @override
  void dispose() {
    _menstrualController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  bool get _canProceed {
    switch (_currentStep) {
      case 0:
        return _auraTypes.isNotEmpty && _whichEye != null;
      case 1:
        return _painSeverity != null && _painLocation != null;
      case 2:
        return true; // all optional
      default:
        return false;
    }
  }

  Episode _buildEpisode() {
    return Episode(
      id: _episodeId,
      date: _episodeDate,
      visualAuraTypes: _auraTypes.toList(),
      whichEye: _whichEye ?? 'unsure',
      painSeverity: _painSeverity ?? 0,
      painLocation: _painLocation ?? '',
      painDuration: _painDuration,
      auraStartTime: _auraStartTime,
      auraDuration: _auraDuration,
      location: _location,
      menstrualCycleDay: _menstrualDay ?? 0,
      notes: _notes,
      hasSecondDayLog: widget.editEpisode?.hasSecondDayLog ?? false,
      functionality: widget.editEpisode?.functionality,
      lingeringSymptoms: widget.editEpisode?.lingeringSymptoms,
      whatHelped: widget.editEpisode?.whatHelped,
    );
  }

  Future<void> _savePartial() async {
    await widget.storage.saveEpisode(_buildEpisode());
  }

  Future<void> _nextStep() async {
    await _savePartial();
    setState(() => _currentStep++);
  }

  Future<void> _saveAndClose() async {
    await _savePartial();
    if (mounted) Navigator.pop(context);
  }

  Future<void> _pickTime(String which) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.lavender,
              surface: AppTheme.surface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (time == null) return;
    final base = _episodeDate;
    final dt = DateTime(base.year, base.month, base.day, time.hour, time.minute);
    setState(() {
      if (which == 'aura') {
        _auraStartTime = dt;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editEpisode != null ? 'Edit Episode' : 'Log Episode'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Progress bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: List.generate(_totalSteps, (i) {
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: i < _totalSteps - 1 ? 6 : 0),
                    height: 4,
                    decoration: BoxDecoration(
                      color: i <= _currentStep
                          ? AppTheme.coral
                          : AppTheme.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 8),

          // Step content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _buildStep(),
              ),
            ),
          ),

          // Navigation
          Padding(
            padding: EdgeInsets.fromLTRB(
                20, 12, 20, 12 + MediaQuery.of(context).padding.bottom),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _currentStep--),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.textSecondary,
                        side: const BorderSide(color: AppTheme.border),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Back'),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _canProceed
                        ? () {
                            if (_currentStep < _totalSteps - 1) {
                              _nextStep();
                            } else {
                              _saveAndClose();
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.coral,
                    ),
                    child: Text(
                      _currentStep < _totalSteps - 1 ? 'Next' : 'Save Episode',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep() {
    switch (_currentStep) {
      case 0:
        return _buildAuraStep();
      case 1:
        return _buildPainStep();
      case 2:
        return _buildDetailsStep();
      default:
        return const SizedBox();
    }
  }

  // ── Step 1: Aura ──

  Widget _buildAuraStep() {
    return Column(
      key: const ValueKey('step0'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Aura',
          subtitle: 'Describe the visual disturbance',
          icon: Icons.visibility_outlined,
        ),

        const SizedBox(height: 8),

        // Aura start time
        _buildTimePicker(
          label: 'Aura Started',
          time: _auraStartTime,
          onTap: () => _pickTime('aura'),
          icon: Icons.visibility,
          color: AppTheme.lavender,
        ),

        const SizedBox(height: 16),

        // Aura duration
        const Text(
          'Aura Duration',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        _buildDurationChips(
          selected: _auraDuration,
          onChanged: (v) => setState(() => _auraDuration = v),
          color: AppTheme.lavender,
        ),

        const SizedBox(height: 24),

        // Visual aura types
        const Text(
          'Visual Aura Types',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Select all that apply',
          style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
        ),
        const SizedBox(height: 10),
        ...AuraTypes.options.map((opt) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: OptionCard(
                label: opt['label']!,
                description: opt['desc'],
                icon: opt['icon'],
                selected: _auraTypes.contains(opt['id']),
                onTap: () => setState(() {
                  if (_auraTypes.contains(opt['id'])) {
                    _auraTypes.remove(opt['id']);
                  } else {
                    _auraTypes.add(opt['id']!);
                  }
                }),
              ),
            )),

        const SizedBox(height: 24),

        // Which eye
        const Text(
          'Which Eye',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        ...['left', 'right', 'both', 'unsure'].map((eye) {
          final labels = {
            'left': 'Left Eye',
            'right': 'Right Eye',
            'both': 'Both Eyes',
            'unsure': 'Unsure',
          };
          final icons = {
            'left': '👁',
            'right': '👁',
            'both': '👀',
            'unsure': '❓',
          };
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: OptionCard(
              label: labels[eye]!,
              icon: icons[eye],
              selected: _whichEye == eye,
              onTap: () => setState(() => _whichEye = eye),
            ),
          );
        }),
      ],
    );
  }

  // ── Step 2: Pain ──

  Widget _buildPainStep() {
    return Column(
      key: const ValueKey('step1'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Pain',
          subtitle: 'Describe the headache pain',
          icon: Icons.bolt,
        ),

        const SizedBox(height: 8),

        // Pain severity
        ScaleSelector(
          label: 'Pain Severity',
          value: _painSeverity,
          onChanged: (v) => setState(() => _painSeverity = v),
          showColors: true,
        ),

        const SizedBox(height: 24),

        // Pain location
        const Text(
          'Pain Location',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: PainLocations.options.map((opt) {
            final selected = _painLocation == opt['id'];
            return GestureDetector(
              onTap: () => setState(() => _painLocation = opt['id']),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: BoxDecoration(
                  color: selected
                      ? AppTheme.coral.withOpacity(0.15)
                      : AppTheme.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected ? AppTheme.coral : AppTheme.border,
                    width: selected ? 2 : 1,
                  ),
                ),
                child: Text(
                  opt['label']!,
                  style: TextStyle(
                    color: selected ? AppTheme.coral : AppTheme.textSecondary,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 24),

        // Pain duration
        const Text(
          'Pain Duration',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        _buildDurationChips(
          selected: _painDuration,
          onChanged: (v) => setState(() => _painDuration = v),
          color: AppTheme.coral,
        ),
      ],
    );
  }

  // ── Step 3: Details ──

  Widget _buildDetailsStep() {
    return Column(
      key: const ValueKey('step2'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Details',
          subtitle: 'Additional context (all optional)',
          icon: Icons.info_outline,
        ),

        const SizedBox(height: 8),

        // Location
        const Text(
          'Where Were You?',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        ...['home', 'work', 'transit', 'outdoors', 'other'].map((loc) {
          final labels = {
            'home': 'Home',
            'work': 'Work',
            'transit': 'Transit',
            'outdoors': 'Outdoors',
            'other': 'Other',
          };
          final icons = {
            'home': '🏠',
            'work': '💼',
            'transit': '🚌',
            'outdoors': '🌳',
            'other': '📍',
          };
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: OptionCard(
              label: labels[loc]!,
              icon: icons[loc],
              selected: _location == loc,
              onTap: () => setState(() =>
                  _location = _location == loc ? null : loc),
            ),
          );
        }),

        const SizedBox(height: 24),

        // Menstrual cycle day
        const Text(
          'Menstrual Cycle Day',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: 120,
          child: TextField(
            controller: _menstrualController,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
            decoration: const InputDecoration(
              hintText: 'Day #',
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            onChanged: (v) {
              final parsed = int.tryParse(v);
              setState(() => _menstrualDay = parsed);
            },
          ),
        ),

        const SizedBox(height: 24),

        // Notes
        const Text(
          'Extra Notes',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _notesController,
          maxLines: 4,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 15,
          ),
          decoration: const InputDecoration(
            hintText: 'Anything else worth noting...',
            contentPadding: EdgeInsets.all(16),
          ),
          onChanged: (v) {
            _notes = v.isEmpty ? null : v;
          },
        ),
      ],
    );
  }

  // ── Shared widgets ──

  Widget _buildDurationChips({
    required int? selected,
    required ValueChanged<int?> onChanged,
    required Color color,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [5, 10, 15, 20, 25, 30, 40, 45, 60].map((min) {
        final isSelected = selected == min;
        return GestureDetector(
          onTap: () => onChanged(isSelected ? null : min),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withOpacity(0.2)
                  : AppTheme.card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? color : AppTheme.border,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Text(
              '${min}m',
              style: TextStyle(
                color: isSelected ? color : AppTheme.textSecondary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                fontSize: 14,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTimePicker({
    required String label,
    required DateTime? time,
    required VoidCallback onTap,
    required IconData icon,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: time != null ? color.withOpacity(0.1) : AppTheme.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: time != null ? color.withOpacity(0.4) : AppTheme.border,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: time != null ? color : AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                if (time != null)
                  Text(
                    DateFormat('h:mm a').format(time),
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
              ],
            ),
            const Spacer(),
            Icon(
              time != null ? Icons.edit : Icons.add_circle_outline,
              color: time != null ? color : AppTheme.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
