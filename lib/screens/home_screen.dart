import 'package:flutter/material.dart';
import '../models/affirmation.dart';
import '../services/database_helper.dart';
import '../services/notification_service.dart';
import 'add_affirmation_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Affirmation> _affirmations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      // Initialize notification service
      await NotificationService().initialize();
      await NotificationService().requestPermissions();
    } catch (e) {
      // Handle initialization errors gracefully
      print('Error initializing notification service: $e');
    }
    // Load affirmations after service initialization
    await _loadAffirmations();
  }

  Future<void> _loadAffirmations() async {
    setState(() => _isLoading = true);
    try {
      final affirmations = await DatabaseHelper().getAllAffirmations();
      setState(() {
        _affirmations = affirmations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading affirmations: $e')),
        );
      }
    }
  }

  Future<void> _deleteAffirmation(String id) async {
    try {
      await DatabaseHelper().deleteAffirmation(id);
      await _loadAffirmations();
      await NotificationService().scheduleAffirmationNotifications();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Affirmation deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting affirmation: $e')),
        );
      }
    }
  }

  Future<void> _toggleAffirmationStatus(Affirmation affirmation) async {
    try {
      final updatedAffirmation = affirmation.copyWith(isActive: !affirmation.isActive);
      await DatabaseHelper().updateAffirmation(updatedAffirmation);
      await _loadAffirmations();
      await NotificationService().scheduleAffirmationNotifications();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating affirmation: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Affirmations'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () async {
              await NotificationService().showInstantAffirmation();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Instant affirmation sent!')),
                );
              }
            },
            tooltip: 'Send instant affirmation',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
              await _loadAffirmations();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _affirmations.isEmpty
              ? _buildEmptyState()
              : _buildAffirmationsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddAffirmationScreen()),
          );
          await _loadAffirmations();
        },
        tooltip: 'Add new affirmation',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_outline,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No affirmations yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your first affirmation',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAffirmationsList() {
    return RefreshIndicator(
      onRefresh: _loadAffirmations,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _affirmations.length,
        itemBuilder: (context, index) {
          final affirmation = _affirmations[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                affirmation.text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: affirmation.isActive
                      ? Theme.of(context).colorScheme.onSurface
                      : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  decoration: affirmation.isActive ? null : TextDecoration.lineThrough,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Created ${_formatDate(affirmation.createdAt)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                ),
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'toggle':
                      _toggleAffirmationStatus(affirmation);
                      break;
                    case 'delete':
                      _showDeleteConfirmation(affirmation);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'toggle',
                    child: Row(
                      children: [
                        Icon(affirmation.isActive ? Icons.pause : Icons.play_arrow),
                        const SizedBox(width: 8),
                        Text(affirmation.isActive ? 'Deactivate' : 'Activate'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showDeleteConfirmation(Affirmation affirmation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Affirmation'),
        content: const Text('Are you sure you want to delete this affirmation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAffirmation(affirmation.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
