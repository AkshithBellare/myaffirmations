import 'package:flutter/material.dart';
import '../models/notification_settings.dart';
import '../services/database_helper.dart';
import '../services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  NotificationSettings _settings = NotificationSettings();
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    try {
      final settings = await DatabaseHelper().getNotificationSettings();
      setState(() {
        _settings = settings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading settings: $e')),
        );
      }
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);
    try {
      await DatabaseHelper().updateNotificationSettings(_settings);
      await NotificationService().scheduleAffirmationNotifications();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings saved successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving settings: $e')),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _addReminderTime() {
    showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
    ).then((time) {
      if (time != null) {
        final hour = time.hour;
        if (!_settings.reminderTimes.contains(hour)) {
          setState(() {
            _settings = _settings.copyWith(
              reminderTimes: [..._settings.reminderTimes, hour]..sort(),
            );
          });
          _saveSettings();
        }
      }
    });
  }

  void _removeReminderTime(int hour) {
    setState(() {
      _settings = _settings.copyWith(
        reminderTimes: _settings.reminderTimes.where((h) => h != hour).toList(),
      );
    });
    _saveSettings();
  }

  String _formatHour(int hour) {
    final time = TimeOfDay(hour: hour, minute: 0);
    return time.format(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notifications',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          title: const Text('Enable Notifications'),
                          subtitle: const Text('Receive daily affirmation reminders'),
                          value: _settings.isEnabled,
                          onChanged: (value) {
                            setState(() {
                              _settings = _settings.copyWith(isEnabled: value);
                            });
                            _saveSettings();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (_settings.isEnabled) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Reminder Times',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              IconButton(
                                onPressed: _addReminderTime,
                                icon: const Icon(Icons.add),
                                tooltip: 'Add reminder time',
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (_settings.reminderTimes.isEmpty)
                            const Text('No reminder times set')
                          else
                            Wrap(
                              spacing: 8,
                              children: _settings.reminderTimes.map((hour) {
                                return Chip(
                                  label: Text(_formatHour(hour)),
                                  onDeleted: () => _removeReminderTime(hour),
                                  deleteIcon: const Icon(Icons.close, size: 18),
                                );
                              }).toList(),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Affirmation Selection',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 16),
                          SwitchListTile(
                            title: const Text('Random Order'),
                            subtitle: const Text('Show affirmations in random order'),
                            value: _settings.randomOrder,
                            onChanged: (value) {
                              setState(() {
                                _settings = _settings.copyWith(randomOrder: value);
                              });
                              _saveSettings();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Card(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'About Notifications',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Notifications will be sent at your chosen times each day. '
                          'Make sure to allow notifications in your device settings for the best experience.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: _isSaving
          ? const FloatingActionButton(
              onPressed: null,
              child: CircularProgressIndicator(),
            )
          : null,
    );
  }
}
