import 'package:flutter/material.dart';
import '../models/affirmation.dart';
import '../services/database_helper.dart';
import '../services/notification_service.dart';

class AddAffirmationScreen extends StatefulWidget {
  final Affirmation? affirmation;

  const AddAffirmationScreen({super.key, this.affirmation});

  @override
  State<AddAffirmationScreen> createState() => _AddAffirmationScreenState();
}

class _AddAffirmationScreenState extends State<AddAffirmationScreen> {
  final _textController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  bool get _isEditing => widget.affirmation != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _textController.text = widget.affirmation!.text;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _saveAffirmation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (_isEditing) {
        final updatedAffirmation = widget.affirmation!.copyWith(
          text: _textController.text.trim(),
        );
        await DatabaseHelper().updateAffirmation(updatedAffirmation);
      } else {
        final affirmation = Affirmation(text: _textController.text.trim());
        await DatabaseHelper().insertAffirmation(affirmation);
      }
      await NotificationService().scheduleAffirmationNotifications();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Affirmation saved successfully!')),
        );
        Navigator.pop(context, true); // Pass true to indicate success
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving affirmation: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Affirmation' : 'Add Affirmation'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _saveAffirmation,
              child: const Text('Save'),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create Your Affirmation',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Write a positive, personal statement that inspires and motivates you.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextFormField(
                      controller: _textController,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: const InputDecoration(
                        hintText: 'I am confident and capable of achieving my goals...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(fontSize: 16),
                      ),
                      style: const TextStyle(fontSize: 16, height: 1.5),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter an affirmation';
                        }
                        if (value.trim().length < 10) {
                          return 'Affirmation should be at least 10 characters long';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ),
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
                            Icons.lightbulb_outline,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Tips for Great Affirmations',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• Use present tense ("I am" instead of "I will")\n'
                        '• Keep it positive and personal\n'
                        '• Make it specific and meaningful to you\n'
                        '• Focus on what you want, not what you don\'t want',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}