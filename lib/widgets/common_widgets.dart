import 'package:flutter/material.dart';
import '../theme.dart';

/// 1-N pill selector (used for 1-6 scales, 1-3 caffeine, etc.)
class ScaleSelector extends StatelessWidget {
  final String label;
  final int min;
  final int max;
  final int? value;
  final ValueChanged<int> onChanged;
  final List<String>? labels; // optional custom labels
  final bool showColors; // use severity colors

  const ScaleSelector({
    super.key,
    required this.label,
    this.min = 1,
    this.max = 6,
    required this.value,
    required this.onChanged,
    this.labels,
    this.showColors = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: List.generate(max - min + 1, (index) {
            final val = min + index;
            final selected = value == val;
            Color pillColor;
            if (showColors && selected) {
              final colorIndex =
                  ((val - min) / (max - min) * 5).round().clamp(0, 5);
              pillColor = AppTheme.severityColors[colorIndex];
            } else {
              pillColor = selected ? AppTheme.lavender : AppTheme.card;
            }

            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(val),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.only(right: index < max - min ? 6 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: pillColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected ? pillColor : AppTheme.border,
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      labels != null && index < labels!.length
                          ? labels![index]
                          : '$val',
                      style: TextStyle(
                        color: selected ? AppTheme.bg : AppTheme.textSecondary,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

/// Section title
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: AppTheme.lavender, size: 20),
            const SizedBox(width: 8),
          ],
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 13,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Option card selector (for aura types, pain location, exercise)
class OptionCard extends StatelessWidget {
  final String label;
  final String? description;
  final String? icon;
  final bool selected;
  final VoidCallback onTap;

  const OptionCard({
    super.key,
    required this.label,
    this.description,
    this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppTheme.lavender.withOpacity(0.15) : AppTheme.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppTheme.lavender : AppTheme.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Text(icon!, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: selected
                          ? AppTheme.lavender
                          : AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  if (description != null)
                    Text(
                      description!,
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle, color: AppTheme.lavender, size: 20),
          ],
        ),
      ),
    );
  }
}

/// Chip-style multi-select (for lingering symptoms)
class ChipMultiSelect extends StatelessWidget {
  final List<String> options;
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;

  const ChipMultiSelect({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = selected.contains(option);
        return GestureDetector(
          onTap: () {
            final newList = List<String>.from(selected);
            if (isSelected) {
              newList.remove(option);
            } else {
              newList.add(option);
            }
            onChanged(newList);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.lavender.withOpacity(0.15)
                  : AppTheme.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppTheme.lavender : AppTheme.border,
              ),
            ),
            child: Text(
              option,
              style: TextStyle(
                color:
                    isSelected ? AppTheme.lavender : AppTheme.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Stat card for the stats screen
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? accentColor;
  final IconData? icon;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.accentColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: accentColor ?? AppTheme.lavender, size: 16),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: accentColor ?? AppTheme.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Sleep duration slider
class SleepDurationPicker extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const SleepDurationPicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Sleep Duration',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.lavender.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${value.toStringAsFixed(1)}h',
                style: const TextStyle(
                  color: AppTheme.lavender,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AppTheme.lavender,
            inactiveTrackColor: AppTheme.border,
            thumbColor: AppTheme.lavender,
            overlayColor: AppTheme.lavender.withOpacity(0.2),
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
          ),
          child: Slider(
            value: value,
            min: 0,
            max: 14,
            divisions: 28,
            onChanged: onChanged,
          ),
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('0h', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
            Text('7h', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
            Text('14h', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
          ],
        ),
      ],
    );
  }
}
