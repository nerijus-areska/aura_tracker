import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../services/notification_service.dart';
import '../services/storage_service.dart';
import '../theme.dart';

class SettingsScreen extends StatefulWidget {
  final StorageService storage;
  final NotificationService notifications;

  const SettingsScreen({
    super.key,
    required this.storage,
    required this.notifications,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with WidgetsBindingObserver {
  bool _exporting = false;
  late TimeOfDay _morningTime;
  late TimeOfDay _eveningTime;
  bool _batteryExempt = true; // optimistic default to avoid flicker

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final times = widget.storage.getNotificationTimes();
    _morningTime = TimeOfDay(hour: times['morningHour']!, minute: times['morningMin']!);
    _eveningTime = TimeOfDay(hour: times['eveningHour']!, minute: times['eveningMin']!);
    _checkBattery();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Re-check when user returns from the system settings screen.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _checkBattery();
  }

  Future<void> _checkBattery() async {
    final exempt = await widget.notifications.isBatteryOptimizationExempt();
    if (mounted) setState(() => _batteryExempt = exempt);
  }

  Future<void> _pickTime({required bool isMorning}) async {
    final initial = isMorning ? _morningTime : _eveningTime;
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return;

    setState(() {
      if (isMorning) {
        _morningTime = picked;
      } else {
        _eveningTime = picked;
      }
    });

    await widget.storage.saveNotificationTimes(
      morningHour: _morningTime.hour,
      morningMinute: _morningTime.minute,
      eveningHour: _eveningTime.hour,
      eveningMinute: _eveningTime.minute,
    );
    await widget.notifications.reschedule(
      morningHour: _morningTime.hour,
      morningMinute: _morningTime.minute,
      eveningHour: _eveningTime.hour,
      eveningMinute: _eveningTime.minute,
    );
  }

  Future<void> _exportData() async {
    setState(() => _exporting = true);
    try {
      final data = await widget.storage.exportAllData();
      final json = const JsonEncoder.withIndent('  ').convert(data);

      final dir = await getTemporaryDirectory();
      final date = DateTime.now().toIso8601String().substring(0, 10);
      final file = File('${dir.path}/aura_backup_$date.json');
      await file.writeAsString(json);

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/json')],
        subject: 'Aura backup $date',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Notifications',
            style: TextStyle(
              color: AppTheme.lavender,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          if (!_batteryExempt) ...[
            ListTile(
              tileColor: const Color(0xFF2A1F0E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              leading: const Icon(Icons.battery_alert_outlined, color: Color(0xFFFBBF24)),
              title: const Text(
                'Battery optimization is blocking reminders',
                style: TextStyle(color: Color(0xFFFBBF24), fontSize: 14),
              ),
              subtitle: const Text(
                'Tap to fix — allow Aura to run unrestricted in the background.',
                style: TextStyle(fontSize: 12),
              ),
              onTap: widget.notifications.requestBatteryOptimizationExemption,
            ),
            const SizedBox(height: 8),
          ],
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Column(
              children: [
                ListTile(
                  tileColor: AppTheme.surface,
                  leading: const Icon(Icons.wb_sunny_outlined, color: AppTheme.teal),
                  title: const Text('Morning reminder'),
                  subtitle: Text(
                    _morningTime.format(context),
                    style: const TextStyle(fontSize: 12),
                  ),
                  onTap: () => _pickTime(isMorning: true),
                ),
                const Divider(height: 1, color: AppTheme.border),
                ListTile(
                  tileColor: AppTheme.surface,
                  leading: const Icon(Icons.nightlight_outlined, color: AppTheme.teal),
                  title: const Text('Evening reminder'),
                  subtitle: Text(
                    _eveningTime.format(context),
                    style: const TextStyle(fontSize: 12),
                  ),
                  onTap: () => _pickTime(isMorning: false),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Data',
            style: TextStyle(
              color: AppTheme.lavender,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            tileColor: AppTheme.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            leading: _exporting
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download_outlined, color: AppTheme.teal),
            title: const Text('Export data'),
            subtitle: const Text(
              'Save all episodes and check-ins as JSON',
              style: TextStyle(fontSize: 12),
            ),
            onTap: _exporting ? null : _exportData,
          ),
        ],
      ),
    );
  }
}
