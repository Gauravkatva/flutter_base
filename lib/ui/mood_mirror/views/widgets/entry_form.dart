import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_appp/domain/data/model/context_type.dart';
import 'package:my_appp/domain/data/model/mood_type.dart';
import 'package:my_appp/ui/mood_mirror/bloc/mood_mirror_bloc.dart';

class EntryForm extends StatefulWidget {
  const EntryForm({super.key});

  @override
  State<EntryForm> createState() => _EntryFormState();
}

class _EntryFormState extends State<EntryForm> {
  final _noteController = TextEditingController();
  int _energy = 3;
  MoodType _selectedMood = MoodType.calm;
  ContextType _selectedContext = ContextType.alone;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _submitEntry() {
    final note = _noteController.text.trim();

    if (note.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a note')),
      );
      return;
    }

    context.read<MoodMirrorBloc>().add(
          AddEntry(
            note: note,
            energy: _energy,
            mood: _selectedMood,
            context: _selectedContext,
          ),
        );

    // Clear form
    _noteController.clear();
    setState(() {
      _energy = 3;
      _selectedMood = MoodType.calm;
      _selectedContext = ContextType.alone;
    });

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Entry added!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Entry',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Note',
                hintText: 'How are you feeling?',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Text(
              'Energy Level: $_energy',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Slider(
              value: _energy.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              label: _energy.toString(),
              onChanged: (value) {
                setState(() {
                  _energy = value.toInt();
                });
              },
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<MoodType>(
              value: _selectedMood,
              decoration: const InputDecoration(
                labelText: 'Mood',
                border: OutlineInputBorder(),
              ),
              items: MoodType.values.map((mood) {
                return DropdownMenuItem(
                  value: mood,
                  child: Text(mood.displayName),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedMood = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ContextType>(
              value: _selectedContext,
              decoration: const InputDecoration(
                labelText: 'Context',
                border: OutlineInputBorder(),
              ),
              items: ContextType.values.map((context) {
                return DropdownMenuItem(
                  value: context,
                  child: Text(context.displayName),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedContext = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submitEntry,
                child: const Text('Add Entry'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
