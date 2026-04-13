part of 'mood_mirror_bloc.dart';

sealed class MoodMirrorEvent extends Equatable {
  const MoodMirrorEvent();

  @override
  List<Object?> get props => [];
}

class AddEntry extends MoodMirrorEvent {
  const AddEntry({
    required this.note,
    required this.energy,
    required this.mood,
    required this.context,
  });

  final String note;
  final int energy;
  final MoodType mood;
  final ContextType context;

  @override
  List<Object?> get props => [note, energy, mood, context];
}

class DeleteEntry extends MoodMirrorEvent {
  const DeleteEntry({required this.id});

  final String id;

  @override
  List<Object?> get props => [id];
}

class ApplyFilter extends MoodMirrorEvent {
  const ApplyFilter({required this.filterOptions});

  final FilterOptions filterOptions;

  @override
  List<Object?> get props => [filterOptions];
}

class ClearFilter extends MoodMirrorEvent {
  const ClearFilter();
}
